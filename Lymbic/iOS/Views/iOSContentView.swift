
#if os(iOS)
import SwiftUI

struct iOSContentView: View {
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass

    // UI 개발을 위한 목업 데이터를 중앙 저장소에서 가져옵니다.
    private let mockItems = MockData.sampleItems
    
    var body: some View {
        if horizontalSizeClass == .compact {
            // --- iPhone 레이아웃: TabView 복원 ---
            TabView {
                ClipboardHistoryView()
                    .tabItem {
                        Label("기록", systemImage: "clock.arrow.circlepath")
                    }
                
                PinnedItemsView()
                    .tabItem {
                        Label("핀 고정", systemImage: "pin.fill")
                    }
                
                SettingsView()
                    .tabItem {
                        Label("설정", systemImage: "gearshape.fill")
                    }
            }
            .background(Color.primaryBackground) // iPhone 탭뷰 전체 배경
            .tint(Color.accentColor) // 탭바 아이템 색상
        } else {
            // --- iPad 레이아웃 ---
            NavigationSplitView {
                List {
                    Section("스마트 폴더") {
                        Label("전체", systemImage: "tray.full.fill")
                        Label("텍스트", systemImage: "doc.text.fill")
                        Label("이미지", systemImage: "photo.fill")
                        Label("링크", systemImage: "link")
                        Label("핀 고정", systemImage: "pin.fill")
                    }
                    Section("프로필") {
                        Label("업무", systemImage: "briefcase.fill")
                        Label("개인", systemImage: "house.fill")
                    }
                }
                .listStyle(.sidebar)
                .navigationTitle("클립보드")
                .background(Color.primaryBackground) // iPad 사이드바 배경
                .scrollContentBackground(.hidden) // iOS 16+ 리스트 배경 투명화
            } detail: {
                ScrollView {
                    // 검색 및 라이브 텍스트 바
                    HStack {
                        TextField("검색...", text: .constant(""))
                            .textFieldStyle(.plain) // 기본 스타일 제거
                            .padding(8)
                            .background(Material.ultraThin)
                            .cornerRadius(8)
                        Button(action: {}) { Image(systemName: "camera") }
                    }
                    .padding()

                    // 아이템 그리드 레이아웃
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 150))], spacing: 20) {
                        ForEach(mockItems) { item in
                            ClipboardItemCardView(item: item)
                        }
                    }
                    .padding(.horizontal)
                }
                .background(Color.primaryBackground) // iPad 상세 뷰 배경
            }
        }
    }
}

#Preview {
    iOSContentView()
}
#endif
