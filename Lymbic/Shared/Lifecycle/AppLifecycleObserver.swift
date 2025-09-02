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

        // --- 성능 개선 리팩토링 --- //
        // 이전 로직: 앱이 활성화될 때마다 DB에서 마지막 아이템을 fetch하여 비교. (데이터가 많아지면 비효율적)
        // 개선 로직: 마지막으로 '추가된' 아이템을 메모리(ClipboardState)에 저장하고, 현재 클립보드 내용과 비교.
        //           이를 통해 불필요한 DB 조회를 없애고 앱 활성화 시 반응성을 높임.
        
        // 2. 메모리에 저장된 마지막 상태와 현재 클립보드 내용 비교 (중복 방지)
        let isDuplicateOfLast: Bool = {
            if let clipboardString {
                return clipboardString == ClipboardState.shared.lastAddedContent
            } else if let clipboardData {
                return clipboardData == ClipboardState.shared.lastAddedImageData
            } else {
                return false
            }
        }()

        // 3. 중복되지 않을 경우에만 새 항목 추가
        if !isDuplicateOfLast {
            let smartType = SmartDetectionService.detect(from: clipboardString ?? "")
            
            let newItem = ClipboardItem(
                content: clipboardString, 
                imageData: clipboardData, 
                contentType: smartType
            )
            context.insert(newItem)
            
            // 4. 마지막으로 추가된 상태를 메모리에 업데이트
            ClipboardState.shared.lastAddedContent = clipboardString
            ClipboardState.shared.lastAddedImageData = clipboardData
            
            print("✅ 새 클립보드 항목 추가: \(smartType.rawValue)")
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
