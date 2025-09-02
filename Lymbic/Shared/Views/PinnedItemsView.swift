
import SwiftUI
import SwiftData

struct PinnedItemsView: View {
    @Environment(\.modelContext) private var context
    
    @Query(filter: #Predicate<ClipboardItem> { $0.isPinned }, sort: \.createdAt, order: .reverse)
    private var items: [ClipboardItem]
    
    @State private var searchText = ""
    
    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { 
                $0.content?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    var body: some View {
        NavigationStack {
            Group {
                if items.isEmpty {
                    emptyStateView
                } else {
                    List(filteredItems) { item in
                        // `listRow` 대신 `ClipboardItemRowView`를 직접 사용하도록 구조 변경
                        ClipboardItemRowView(item: item)
                            .swipeActions(edge: .leading) {
                                unpinButton(for: item)
                            }
                            .swipeActions(edge: .trailing) {
                                copyButton(for: item)
                                deleteButton(for: item)
                            }
                    }
                    .listStyle(.plain)
                }
            }
            .navigationTitle("📌 핀된 항목")
            .searchable(text: $searchText, prompt: "핀된 항목 검색")
        }
    }
    
    // MARK: - 하위 뷰 (Subviews)

    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 12) {
            Image(systemName: "pin.slash")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
            Text("핀된 항목 없음")
                .font(.headline)
            Text("기록 탭에서 자주 사용하는 항목을 핀하여\n여기서 빠르게 접근하세요.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
    
    // MARK: - 스와이프 액션 버튼
    
    @ViewBuilder
    private func unpinButton(for item: ClipboardItem) -> some View {
        Button {
            togglePin(item)
        } label: {
            Label("핀 해제", systemImage: "pin.slash.fill")
        }.tint(.orange)
    }
    
    @ViewBuilder
    private func copyButton(for item: ClipboardItem) -> some View {
        Button {
            copyToClipboard(item)
        } label: {
            Label("복사", systemImage: "doc.on.doc")
        }.tint(.blue)
    }
    
    @ViewBuilder
    private func deleteButton(for item: ClipboardItem) -> some View {
        Button(role: .destructive) {
            deleteItem(item)
        } label: {
            Label("삭제", systemImage: "trash")
        }
    }
    
    // MARK: - 로직

    private func togglePin(_ item: ClipboardItem) {
        item.isPinned.toggle()
        saveContext()
    }

    private func deleteItem(_ item: ClipboardItem) {
        context.delete(item)
        saveContext()
    }
    
    private func saveContext() {
        do {
            try context.save()
        } catch {
            print("⚠️ 컨텍스트 저장 실패: \(error)")
        }
    }
    
    private func copyToClipboard(_ item: ClipboardItem) {
        #if os(iOS)
        if let data = item.imageData {
            UIPasteboard.general.image = UIImage(data: data)
        } else if let content = item.content {
            UIPasteboard.general.string = content
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if let data = item.imageData, let image = NSImage(data: data) {
            pasteboard.writeObjects([image])
        } else if let content = item.content {
            pasteboard.setString(content, forType: .string)
        }
        #endif
    }
}


// MARK: - 미리보기

struct PinnedItemsView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ClipboardItem.self, configurations: config)
        
        let sampleItems = [
            ClipboardItem(content: "https://www.apple.com", contentType: .url, isPinned: true),
            ClipboardItem(content: "example@example.com", contentType: .email, isPinned: true),
            ClipboardItem(content: "미리보기용으로 핀된 텍스트입니다.", contentType: .none, isPinned: true)
        ]
        sampleItems.forEach { container.mainContext.insert($0) }
        
        return PinnedItemsView()
            .modelContainer(container)
    }
}
