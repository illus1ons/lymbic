//
//  DesignSystem.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

enum DesignSystem {
    #if os(iOS)
    static let cardBackground = Color(.systemGray6)   // UIKit 기반
    #elseif os(macOS)
    static let cardBackground = Color(NSColor.windowBackgroundColor) // AppKit 기반
    #endif
}
