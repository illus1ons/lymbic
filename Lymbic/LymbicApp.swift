//
//  LymbicApp.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

@main
struct LymbicApp: App {
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            ContentView()
#elseif os(macOS)
            macOS_ContentView()
#else
            Text("지원하지 않는 플랫폼")
#endif
        }
    }
}
