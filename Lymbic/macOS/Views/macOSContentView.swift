//
//  ContentView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct macOS_ContentView: View {
    var body: some View {
        NavigationView {
            List {
                NavigationLink(destination: ClipboardHistoryView()) {
                    Label("히스토리", systemImage: "clock")
                }
                NavigationLink(destination: PinnedItemsView()) {
                    Label("핀됨", systemImage: "pin")
                }
            }
            .listStyle(SidebarListStyle())
            
            // 기본 콘텐츠 뷰
            Text("클립보드 내용을 선택하세요")
        }
        .frame(minWidth: 300, idealWidth: 500, minHeight: 400, idealHeight: 600)
    }
}

#Preview {
    macOS_ContentView()
}
