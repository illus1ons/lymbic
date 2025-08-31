//
//  PinnedItemsView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI
import SwiftData

struct PinnedItemsView: View {
    @Environment(\.modelContext) private var context
    
    // 1. 핀된 항목만 가져오고, 생성일 기준 최신순으로 정렬
    @Query(filter: #Predicate<ClipboardItem> { $0.isPinned }, sort: \.createdAt, order: .reverse)
    private var items: [ClipboardItem]
    
    @State private var searchText = ""
    
    // 2. 검색 텍스트를 기반으로 필터링된 항목
    private var filteredItems: [ClipboardItem] {
        if searchText.isEmpty {
            return items
        } else {
            return items.filter { 
                $0.content?.localizedCaseInsensitiveContains(searchText) ?? false
            }
        }
    }
    
    // 3. 반응형 그리드 레이아웃 정의
    private let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 150, maximum: 200))
    ]

    var body: some View {
        NavigationStack {
            Group {
                // 4. 핀된 항목이 없을 경우 Empty State 표시
                if items.isEmpty {
                    emptyStateView
                } else {
                    // 5. 카드 기반 그리드 뷰
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(filteredItems) { item in
                                itemCard(for: item)
                            }
                        }
                        .padding()
                    }
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
    private func itemCard(for item: ClipboardItem) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            // 카드 상단: 콘텐츠 미리보기
            ClipboardItemView(item: item, isCardStyle: true)
            
            // 카드 하단: 액션 버튼
            HStack {
                Spacer() 
                
                // 복사 버튼
                Button {
                    copyToClipboard(item)
                } label: {
                    Image(systemName: "doc.on.doc")
                }
                .buttonStyle(.borderless)
                .tint(.secondary)
                
                // 컨텍스트 메뉴 (핀 해제, 삭제)
                Menu {
                    Button("핀 해제", systemImage: "pin.slash") {
                        togglePin(item)
                    }
                    Button("삭제", systemImage: "trash", role: .destructive) {
                        deleteItem(item)
                    }
                } label: {
                    Image(systemName: "ellipsis.circle")
                }
                .menuStyle(.borderlessButton)
                .tint(.secondary)
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(.thinMaterial, in: .rect(bottomLeadingRadius: 12, bottomTrailingRadius: 12))
        }
        .background(DesignSystem.cardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(radius: 2, x: 0, y: 1)
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


// MARK: - Previews

struct PinnedItemsView_Previews: PreviewProvider {
    @MainActor static var previews: some View {
        // 미리보기를 위한 인메모리 컨테이너 설정
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        let container = try! ModelContainer(for: ClipboardItem.self, configurations: config)
        
        // 샘플 데이터 추가
        let sampleItems = [
            ClipboardItem(content: "자주 사용하는 텍스트 스니펫", contentType: .text, isPinned: true),
            ClipboardItem(content: "https://google.com", contentType: .url, isPinned: true),
            ClipboardItem(content: "또 다른 중요한 정보", contentType: .text, isPinned: true)
        ]
        sampleItems.forEach { container.mainContext.insert($0) }
        
        return PinnedItemsView()
            .modelContainer(container)
    }
}