import SwiftUI
import SwiftData

// MARK: - 뷰 수정자 (View Modifier)

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
    
    // MARK: - 로직
    
    private func checkClipboard() {
        // 1. 클립보드에서 현재 내용 가져오기
        guard let (clipboardString, clipboardData) = getCurrentClipboardContent() else { return }

        do {
            // 2. 가장 최근 항목 1개만 가져오도록 FetchDescriptor 설정
            var descriptor = FetchDescriptor<ClipboardItem>()
            descriptor.sortBy = [SortDescriptor(\.createdAt, order: .reverse)]
            descriptor.fetchLimit = 1

            // 3. 가장 최근 항목 조회
            let mostRecentItem = try context.fetch(descriptor).first

            // 4. 가장 최근 항목과 현재 클립보드 내용 비교 (중복 방지)
            var isDuplicateOfLast = false
            if let lastItem = mostRecentItem {
                let stringsMatch = (clipboardString != nil && clipboardString == lastItem.content)
                let dataMatch = (clipboardData != nil && clipboardData == lastItem.imageData)
                if stringsMatch || dataMatch {
                    isDuplicateOfLast = true
                }
            }

            // 5. 중복되지 않을 경우에만 새 항목 추가
            if !isDuplicateOfLast {
                let smartType = SmartDetectionService.detect(from: clipboardString ?? "")
                
                let newItem = ClipboardItem(
                    content: clipboardString, 
                    imageData: clipboardData, 
                    contentType: smartType
                )
                context.insert(newItem)
            }
        } catch {
            print("⚠️ 최근 항목 조회 실패 (중복 검사): \(error)")
        }
    }
    
    private func getCurrentClipboardContent() -> (String?, Data?)? {
        #if os(iOS)
        let pasteboard = UIPasteboard.general
        if let string = pasteboard.string {
            return (string, nil)
        } else if let image = pasteboard.image {
            return (nil, image.pngData())
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        if let string = pasteboard.string(forType: .string) {
            return (string, nil)
        }
        // macOS에서 이미지 데이터 읽기는 더 복잡할 수 있음
        #endif
        return nil
    }
    
    private func autoDeleteExpiredItems() {
        do {
            // 1. 만료될 가능성이 있는 항목 조회 (핀 고정 안됨, 만료 날짜 있음)
            let potentialExpiredDescriptor = FetchDescriptor<ClipboardItem>(
                predicate: #Predicate { !$0.isPinned && $0.expiresAt != nil }
            )
            let potentialExpiredItems = try context.fetch(potentialExpiredDescriptor)

            let now = Date()
            var itemsToDelete: [ClipboardItem] = []

            // 2. 메모리에서 필터링
            for item in potentialExpiredItems {
                if let expiresAt = item.expiresAt, expiresAt <= now {
                    itemsToDelete.append(item)
                }
            }

            // 3. 만료된 항목 삭제
            if !itemsToDelete.isEmpty {
                for item in itemsToDelete {
                    context.delete(item)
                }
                print("✅ 만료된 항목 \(itemsToDelete.count)개 자동 삭제 완료.")
            }
        } catch {
            print("⚠️ 자동 삭제 실패: \(error)")
        }
    }
}

// MARK: - 뷰 확장 (View Extension)

extension View {
    func withAppLifecycleObserver() -> some View {
        self.modifier(AppLifecycleObserver())
    }
}
