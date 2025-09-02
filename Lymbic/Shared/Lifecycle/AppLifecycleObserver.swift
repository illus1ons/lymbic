//
//  AppLifecycleObserver.swift
//  Lymbic
//
//  Created by Gemini on 9/1/25.
//

import SwiftUI
import SwiftData

// MARK: - View Modifier

struct AppLifecycleObserver: ViewModifier {
    @Environment(\.modelContext) private var context
    
    func body(content: Content) -> some View {
        content
            .onAppear(perform: setupObserver)
            .onReceive(Timer.publish(every: 60, on: .main, in: .common).autoconnect()) { _ in
                autoDeleteExpiredItems()
            }
    }
    
    private func setupObserver() {
        #if os(iOS)
        NotificationCenter.default.addObserver(forName: UIApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            checkClipboard()
        }
        #elseif os(macOS)
        NotificationCenter.default.addObserver(forName: NSApplication.didBecomeActiveNotification, object: nil, queue: .main) { _ in
            checkClipboard()
        }
        #endif
    }
    
    // MARK: - Actions
    
    private func checkClipboard() {
        // 1. 클립보드에서 현재 내용 가져오기
        guard let (clipboardString, clipboardData, contentType) = getCurrentClipboardContent() else { return }

        do {
            // 2. 가장 최근 항목 1개만 가져오도록 FetchDescriptor 설정
            var descriptor = FetchDescriptor<ClipboardItem>()
            descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
            descriptor.fetchLimit = 1

            // 3. 가장 최근 항목 조회
            let mostRecentItem = try context.fetch(descriptor).first

            // 4. 가장 최근 항목과 현재 클립보드 내용 비교
            var isDuplicateOfLast = false
            if let lastItem = mostRecentItem {
                let stringsMatch = (clipboardString != nil && clipboardString == lastItem.content)
                let dataMatch = (clipboardData != nil && clipboardData == lastItem.imageData)
                if stringsMatch || dataMatch {
                    isDuplicateOfLast = true
                }
            }

            // 5. 가장 최근 항목과 중복되지 않을 경우에만 추가
            if !isDuplicateOfLast {
                // 스마트 타입 감지
                let smartType = SmartDetectionService.detect(from: clipboardString ?? "")
                
                let newItem = ClipboardItem(
                    content: clipboardString, 
                    imageData: clipboardData, 
                    contentType: contentType, 
                    smartContentType: smartType
                )
                context.insert(newItem)
            }
        } catch {
            print("⚠️ Failed to fetch recent item to check for duplicates: \(error)")
        }
    }
    
    private func getCurrentClipboardContent() -> (String?, Data?, ClipboardContentType)? {
        #if os(iOS)
        let pasteboard = UIPasteboard.general
        if let string = pasteboard.string {
            // Basic URL detection
            let isURL = string.lowercased().hasPrefix("http://") || string.lowercased().hasPrefix("https://")
            return (string, nil, isURL ? .url : .text)
        } else if let image = pasteboard.image {
            return (nil, image.pngData(), .image)
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        if let string = pasteboard.string(forType: .string) {
             // Basic URL detection
            let isURL = string.lowercased().hasPrefix("http://") || string.lowercased().hasPrefix("https://")
            return (string, nil, isURL ? .url : .text)
        }
        // Reading image data from macOS pasteboard can be more complex
        #endif
        return nil
    }
    
    private func autoDeleteExpiredItems() {
        do {
            // 1. Fetch items that could be expired (not pinned, has an expiry date)
            let potentialExpiredDescriptor = FetchDescriptor<ClipboardItem>(
                predicate: #Predicate { !$0.isPinned && $0.expiresAt != nil }
            )
            let potentialExpiredItems = try context.fetch(potentialExpiredDescriptor)

            let now = Date()
            var itemsToDelete: [ClipboardItem] = []

            // 2. Filter in memory
            for item in potentialExpiredItems {
                if let expiresAt = item.expiresAt, expiresAt <= now {
                    itemsToDelete.append(item)
                }
            }

            // 3. Delete expired items
            if !itemsToDelete.isEmpty {
                for item in itemsToDelete {
                    context.delete(item)
                }
                print("✅ Auto-deleted \(itemsToDelete.count) expired items.")
            }
        } catch {
            print("⚠️ Auto-deletion failed: \(error)")
        }
    }
}

// MARK: - View Extension

extension View {
    func withAppLifecycleObserver() -> some View {
        self.modifier(AppLifecycleObserver())
    }
}
