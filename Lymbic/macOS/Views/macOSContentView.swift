
#if os(macOS)
import SwiftUI
import AppKit

struct macOSContentView: View {
    // MARK: - 상태
    @State private var selectedCategory: String? = "전체"
    // 'ID' 접근 수준 오류 해결을 위해 'UUID' 직접 사용
    @State private var selectedItems = Set<UUID>()
    @State private var sortOrder = [KeyPathComparator<ClipboardItem>](
        [KeyPathComparator(\ClipboardItem.createdAt, order: .reverse)]
    )

    // UI 개발을 위한 목업 데이터를 중앙 저장소에서 가져옵니다.
    private let mockItems = MockData.sampleItems
    
    private var filteredItems: [ClipboardItem] {
        // 실제 앱에서는 선택된 카테고리에 따른 필터링 로직이 여기에 들어갑니다.
        return mockItems.sorted(using: sortOrder)
    }

    var body: some View {
        NavigationSplitView {
            // --- 사이드바 (좌측 패널) ---
            List(selection: $selectedCategory) {
                Section("스마트 폴더") {
                    Label("전체", systemImage: "tray.full.fill").tag("전체")
                    Label("텍스트", systemImage: "doc.text.fill").tag("텍스트")
                    Label("이미지", systemImage: "photo.fill").tag("이미지")
                    Label("링크", systemImage: "link").tag("링크")
                    Label("핀 고정", systemImage: "pin.fill").tag("핀 고정")
                }
                Section("프로필") {
                    Label("업무", systemImage: "briefcase.fill").tag("업무")
                    Label("개인", systemImage: "house.fill").tag("개인")
                }
            }
            .listStyle(.sidebar)
            .navigationSplitViewColumnWidth(200)

        } detail: {
            // --- 메인 컨텐츠 (우측 패널) ---
            VStack(spacing: 0) {
                // 컴파일러 타입 체크 오류 해결을 위해 Table을 별도 뷰로 분리
                clipboardTableView
                
                // --- 상태 바 (하단) ---
                statusBar
            }
        }
        .navigationTitle("Ephemeral Clipboard")
        .toolbar {
            ToolbarItemGroup {
                Button(action: {}) { Label("검색", systemImage: "magnifyingglass") }
                Button(action: {}) { Label("라이브 텍스트", systemImage: "camera") }
                Button(action: {}) { Label("설정", systemImage: "gear") }
            }
        }
    }
    
    // MARK: - 하위 뷰 (Subviews)
    
    private var clipboardTableView: some View {
        Table(filteredItems, selection: $selectedItems, sortOrder: $sortOrder) {
            // 옵셔널 KeyPath 에러를 해결하기 위해 value 파라미터 제거
            TableColumn("내용") { item in
                HStack {
                    if item.isPinned {
                        Image(systemName: "pin.fill")
                            .foregroundColor(.accentColor)
                            .font(.caption)
                    }
                    if item.imageData != nil {
                        Image(systemName: "photo")
                        Text("이미지")
                    } else {
                        Text(item.content ?? "")
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
            }
            
            TableColumn("타입", value: \.contentType.rawValue) { item in
                Text(item.contentType.rawValue.capitalized)
            }
            .width(min: 60, ideal: 80)
            
            TableColumn("생성 시간", value: \.createdAt) { item in
                Text(item.createdAt, style: .relative)
            }
            .width(min: 80, ideal: 100)
            
            TableColumn("만료 시간") { item in
                if let date = item.expiresAt {
                    CountdownBadge(expirationDate: date)
                } else {
                    Text("-").foregroundColor(.secondary)
                }
            }
            .width(min: 80, ideal: 90)
        }
    }
    
    private var statusBar: some View {
        HStack {
            Text("\(mockItems.count)개 항목")
            Spacer()
            Text("동기화 상태: 정상")
        }
        .padding(8)
        .background(Material.ultraThin)
    }
}

#Preview {
    macOSContentView()
}
#endif
