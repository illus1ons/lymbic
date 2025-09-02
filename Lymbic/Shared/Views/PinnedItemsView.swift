
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
                    // 그리드 뷰에서 리스트 뷰로 변경
                    List(filteredItems) { item in
                        listRow(for: item)
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
    
    // MARK: - Subviews

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

    @ViewBuilder
    private func listRow(for item: ClipboardItem) -> some View {
        // ClipboardItemView가 스마트 액션을 포함하여 모든 것을 렌더링합니다.
        ClipboardItemView(item: item, isCardStyle: false)
    }
    
    // MARK: - Swipe Action Buttons
    
    @ViewBuilder
    private func unpinButton(for item: ClipboardItem) -> some View {
        Button {
            togglePin(item)
        } label: {
            Label("Unpin", systemImage: "pin.slash.fill")
        }.tint(.orange)
    }
    
    @ViewBuilder
    private func copyButton(for item: ClipboardItem) -> some View {
        Button {
            copyToClipboard(item)
        } label: {
            Label("Copy", systemImage: "doc.on.doc")
        }.tint(.blue)
    }
    
    @ViewBuilder
    private func deleteButton(for item: ClipboardItem) -> some View {
        Button(role: .destructive) {
            deleteItem(item)
        } label: {
            Label("Delete", systemImage: "trash")
        }
    }
    
    // MARK: - Actions

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
            print("⚠️ Failed to save context: \(error)")
        }
    }
    
    private func copyToClipboard(_ item: ClipboardItem) {
        var stringToCopy: String? = nil
        #if os(iOS)
        if item.contentType == .image, let data = item.imageData {
            UIPasteboard.general.image = UIImage(data: data)
            return
        } else {
            stringToCopy = item.content
        }
        UIPasteboard.general.string = stringToCopy
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        if item.contentType == .image, let data = item.imageData, let image = NSImage(data: data) {
            pasteboard.writeObjects([image])
        } else if let content = item.content {
            pasteboard.setString(content, forType: .string)
        }
        #endif
    }
}


// MARK: - Previews

struct PinnedItemsView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ClipboardItem.self, configurations: config)
        
        let sampleItems = [
            ClipboardItem(content: "https://www.apple.com", contentType: .url, smartContentType: .url, isPinned: true),
            ClipboardItem(content: "example@example.com", contentType: .text, smartContentType: .email, isPinned: true),
            ClipboardItem(content: "This is a pinned text snippet for preview.", contentType: .text, isPinned: true)
        ]
        sampleItems.forEach { container.mainContext.insert($0) }
        
        return PinnedItemsView()
            .modelContainer(container)
    }
}
