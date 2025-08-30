//
//  ContentView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        #if os(iOS)
        // iOS (iPhone, iPad) 전용 레이아웃
        TabView {
            ClipboardHistoryView()
                .tabItem { Label("히스토리", systemImage: "clock") }
            PinnedItemsView()
                .tabItem { Label("핀됨", systemImage: "pin") }
            SettingsView()
                .tabItem { Label("설정", systemImage: "gear") }
        }
        #elseif os(macOS)
        // macOS 전용 레이아웃
        // Sidebar와 ContentView를 갖는 NavigationView를 사용
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
        #else
        // 다른 플랫폼을 위한 기본 뷰
        Text("지원하지 않는 플랫폼")
        #endif
    }
}

#Preview {
    ContentView()
}
