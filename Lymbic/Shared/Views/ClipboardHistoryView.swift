//
//  ClipboardHistoryView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI
import SwiftData

struct ClipboardHistoryView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \ClipboardItem.createdAt, order: .reverse) private var items: [ClipboardItem]

    private var pinnedItems: [ClipboardItem] { items.filter { $0.isPinned } }
    private var recentItems: [ClipboardItem] { items.filter { !$0.isPinned } }
    
    var body: some View {
        NavigationStack {
            List {
                // 📌 핀된 항목 섹션
                Section("📌 핀된 항목 (\(pinnedItems.count))") {
                    if pinnedItems.isEmpty {
                        Text("고정된 항목 없음")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(pinnedItems) { item in
                            ClipboardItemView(item: item, isCardStyle: false)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        togglePin(item)
                                    } label: {
                                        Label("Unpin", systemImage: "pin.slash.fill")
                                    }
                                    .tint(.orange)
                                }
                                .swipeActions(edge: .trailing) {
                                    copyButton(for: item)
                                    deleteButton(for: item)
                                }
                        }
                    }
                }
                
                // 🕐 최근 항목 섹션
                Section("🕐 최근 항목 (\(recentItems.count))") {
                    if recentItems.isEmpty {
                        Text("최근 항목 없음")
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(recentItems) { item in
                            ClipboardItemView(item: item, isCardStyle: false)
                                .swipeActions(edge: .leading) {
                                    Button {
                                        togglePin(item)
                                    } label: {
                                        Label("Pin", systemImage: "pin.fill")
                                    }.tint(.orange)
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

    private func togglePin(_ item: ClipboardItem) {
        item.isPinned.toggle()
        do {
            try context.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save context after toggling pin: \(error)")
            // Optionally, revert the change in memory if the save fails.
            item.isPinned.toggle()
        }
    }

    private func deleteItem(_ item: ClipboardItem) {
        context.delete(item)
        do {
            try context.save()
        } catch {
            // Handle the error appropriately.
            print("Failed to save context after deletion: \(error)")
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
            // NSPasteboard doesn't directly take Data for an image.
            // You might need to create an NSImage first.
            if let data = item.imageData, let image = NSImage(data: data) {
                pasteboard.writeObjects([image])
            }
        }
        #endif
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
}

struct ClipboardHistoryView_Previews: PreviewProvider {
    static var previews: some View {
        ClipboardHistoryView()
            .modelContainer(for: ClipboardItem.self, inMemory: true)
    }
}
