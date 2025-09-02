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
                    }
                }
                
                // 🕐 최근 항목 섹션
                Section(header: recentItemsHeader) {
                    if recentItems.isEmpty {
                        Text("최근 항목 없음")
                            .foregroundStyle(.secondary)
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
                        }
                    }
                }
            }
            .navigationTitle("클립보드 히스토리")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: {}) { Image(systemName: "magnifyingglass") }
                    Button(action: {}) { Image(systemName: "camera") }
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
        #if os(iOS)
        switch item.contentType {
        case .text, .url, .otp:
            if let content = item.content {
                UIPasteboard.general.string = content
            }
        case .image:
            if let data = item.imageData {
                UIPasteboard.general.image = UIImage(data: data)
            }
        }
        #elseif os(macOS)
        let pasteboard = NSPasteboard.general
        pasteboard.clearContents()
        switch item.contentType {
        case .text, .url, .otp:
            if let content = item.content {
                pasteboard.setString(content, forType: .string)
            }
        case .image:
            if let data = item.imageData, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        }
        #endif
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
                    .foregroundStyle(.secondary)
                Text(item.contentType.rawValue.capitalized)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Spacer()
            }
            
            // 2. Content
            if item.contentType == .image, let data = item.imageData {
                Image(uiImage: UIImage(data: data) ?? UIImage(systemName: "photo")!)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .clipShape(RoundedRectangle(cornerRadius: 4))
            } else {
                Text(item.content ?? "")
                    .font(.system(.body, design: .monospaced))
                    .lineLimit(4)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            
            Spacer(minLength: 0)
        }
        .padding(12)
        .frame(width: 180, height: 120)
        .background(DesignSystem.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.1), radius: 3, y: 1)
    }
}

private extension ClipboardContentType {
    var iconName: String {
        switch self {
        case .text: return "text.quote"
        case .url: return "link"
        case .image: return "photo"
        case .otp: return "key.radiowaves.forward"
        }
    }
}

// MARK: - Preview

struct ClipboardHistoryView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        let container = try! ModelContainer(for: ClipboardItem.self, configurations: .init(isStoredInMemoryOnly: true))
        
        // Sample Data
        let sampleItems = [
            ClipboardItem(content: "https://google.com", contentType: .url, isPinned: true),
            ClipboardItem(content: "This is a pinned text snippet for preview.", contentType: .text, isPinned: true),
            ClipboardItem(content: "Another one.", contentType: .text, isPinned: true),
            ClipboardItem(content: "Recent item 1", contentType: .text),
            ClipboardItem(content: "Recent item 2", contentType: .text)
        ]
        sampleItems.forEach { container.mainContext.insert($0) }
        
        return ClipboardHistoryView()
            .modelContainer(container)
    }
}