//
//  ContentView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct iOS_ContentView: View {
    @Environment(\.modelContext) private var context
    
    var body: some View {
        TabView {
            ClipboardHistoryView()
                .tabItem { Label("히스토리", systemImage: "clock") }
            PinnedItemsView()
                .tabItem { Label("핀됨", systemImage: "pin") }
            SettingsView()
                .tabItem { Label("설정", systemImage: "gear") }
        }
    }
}

#Preview {
    iOS_ContentView()
}
