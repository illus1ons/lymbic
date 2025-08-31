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
        let content: (String?, Data?, ClipboardContentType)? = { 
            #if os(iOS)
            let pasteboard = UIPasteboard.general
            if let string = pasteboard.string {
                return (string, nil, .text)
            } else if let url = pasteboard.url {
                return (url.absoluteString, nil, .url)
            } else if let image = pasteboard.image {
                return (nil, image.pngData(), .image)
            }
            #elseif os(macOS)
            let pasteboard = NSPasteboard.general
            if let string = pasteboard.string(forType: .string) {
                 // TODO: Add better URL detection if needed
                return (string, nil, string.contains("://") ? .url : .text)
            }
            // Reading image data from macOS pasteboard can be more complex
            // and might involve checking pasteboard.types
            #endif
            return nil
        }()
        
        if let (contentString, contentData, contentType) = content {
            // Avoid adding duplicate content
            let newItem = ClipboardItem(content: contentString, imageData: contentData, contentType: contentType)
            do {
                let fetchDescriptor = FetchDescriptor<ClipboardItem>()
                let allItems = try context.fetch(fetchDescriptor)
                
                let isDuplicate = allItems.contains { item in
                    if let contentString = contentString, !contentString.isEmpty, item.content == contentString {
                        return true
                    }
                    if let contentData = contentData, item.imageData == contentData {
                        return true
                    }
                    return false
                }
                
                if !isDuplicate {
                    context.insert(newItem)
                }
            } catch {
                print("Failed to check for duplicates: \(error)")
                context.insert(newItem) // Insert anyway if check fails
            }
        }
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
