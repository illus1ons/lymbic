
import SwiftUI
import SwiftData

// MARK: - Main View

struct ClipboardHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ClipboardItem.createdAt, order: .reverse) private var items: [ClipboardItem]

    private var pinnedItems: [ClipboardItem] { items.filter { $0.isPinned } }
    private var recentItems: [ClipboardItem] { items.filter { !$0.isPinned } }
    
    var body: some View {
        NavigationStack {
            List {
                // 📌 핀된 항목 섹션 (가로 스크롤)
                if !pinnedItems.isEmpty {
                    Section("📌 핀된 항목 (\(pinnedItems.count))") {
                        ScrollView(.horizontal, showsIndicators: false) {
                            LazyHStack(spacing: 12) {
                                ForEach(pinnedItems) { item in
                                    PinnedItemCard(item: item)
                                        .contextMenu {
                                            contextMenuItems(for: item)
                                        }
                                }
                            }
                            .padding(.horizontal)
                            .padding(.vertical, 4)
                        }
                        .listRowInsets(EdgeInsets())
                        .listRowBackground(Color.clear) // 행 배경 투명화
                    }
                }
                
                // 🕐 최근 항목 섹션
                Section(header: recentItemsHeader) {
                    if recentItems.isEmpty {
                        ContentUnavailableView(
                            "클립보드가 비어있습니다",
                            systemImage: "doc.on.clipboard",
                            description: Text("다른 기기에서 복사하거나 앱 내에서 직접 추가한 항목이 여기에 표시됩니다."))
                        .padding(.vertical, 40)
                        .listRowBackground(Color.clear) // 행 배경 투명화
                    } else {
                        ForEach(recentItems) { item in
                            ClipboardItemView(item: item, isCardStyle: false)
                                .swipeActions(edge: .leading) {
                                    pinButton(for: item)
                                }
                                .swipeActions(edge: .trailing) {
                                    copyButton(for: item)
                                    deleteButton(for: item)
                                }
                                .listRowBackground(Color.clear) // 행 배경 투명화
                        }
                    }
                }
            }
            .scrollContentBackground(.hidden) // iOS 16+ 리스트 배경 투명화
            .background(Color.primaryBackground) // 리스트 전체 배경
            .navigationTitle("클립보드 히스토리")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: {}) { Image(systemName: "magnifyingglass") }.buttonStyle(DesignSystem.toolbarButton())
                    Button(action: {}) { Image(systemName: "camera") }.buttonStyle(DesignSystem.toolbarButton())
                }
            }
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private var recentItemsHeader: some View {
        // 핀된 항목이 있을 때만 최근 항목 개수를 표시하여 깔끔하게 보이도록 함
        if pinnedItems.isEmpty {
            Text("🕐 최근 항목")
        } else {
            Text("🕐 최근 항목 (\(recentItems.count))")
        }
    }
    
    @ViewBuilder
    private func contextMenuItems(for item: ClipboardItem) -> some View {
        Button("복사", systemImage: "doc.on.doc") {
            copyToClipboard(item)
        }
        Button("핀 해제", systemImage: "pin.slash") {
            togglePin(item)
        }
        Divider()
        Button("삭제", systemImage: "trash", role: .destructive) {
            deleteItem(item)
        }
    }
    
    @ViewBuilder
    private func pinButton(for item: ClipboardItem) -> some View {
        Button {
            togglePin(item)
        } label: {
            Label(item.isPinned ? "Unpin" : "Pin", systemImage: item.isPinned ? "pin.slash.fill" : "pin.fill")
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
        // This function needs to be updated to handle SmartContentType
        // For now, we focus on fixing the build error.
    }
}

// MARK: - Pinned Item Card View

private struct PinnedItemCard: View {
    let item: ClipboardItem
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 1. Header: Icon & Content Type
            HStack {
                                Image(systemName: item.contentType.iconName)
                    .font(.caption)
                    .foregroundStyle(Color.textColorSecondary)
                Text(item.contentType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(Color.textColorSecondary)
                Spacer()
            }
            
            // 2. Content
            if let data = item.imageData {
                #if canImport(UIKit)
                Image(uiImage: UIImage(data: data) ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
                #elseif canImport(AppKit)
                if let nsImage = NSImage(data: data) {
                    Image(nsImage: nsImage)
                        .resizable()
                        .scaledToFit()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .clipShape(RoundedRectangle(cornerRadius: 4))
                } else {
                    Image(systemName: "photo")
                }
                #endif
            } else {
                Text(item.content ?? "")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(.textColorPrimary)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 180, height: 120)
        .modifier(DesignSystem.cardModifier()) // DesignSystem의 카드 스타일 적용
    }
}


// MARK: - 미리보기

struct ClipboardHistoryView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        let container = try! ModelContainer(for: ClipboardItem.self, configurations: .init(isStoredInMemoryOnly: true))
        
        // Sample Data
        let sampleItems = [
            ClipboardItem(content: "https://google.com", contentType: .url, isPinned: true),
            ClipboardItem(content: "This is a pinned text snippet for preview.", contentType: .none, isPinned: true),
            ClipboardItem(content: "Another one.", contentType: .none, isPinned: true),
            ClipboardItem(content: "Recent item 1", contentType: .none),
            ClipboardItem(content: "Recent item 2", contentType: .none)
        ]
        sampleItems.forEach { container.mainContext.insert($0) }
        
        return ClipboardHistoryView()
            .modelContainer(container)
    }
}
