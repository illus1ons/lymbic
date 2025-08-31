//
//  ContentTypeIcon.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct ContentTypeIcon: View {
    let type: ClipboardContentType
    
    var body: some View {
        Image(systemName: {
            switch type {
            case .text: return "textformat"
            case .url: return "link"
            case .image: return "photo"
            case .otp: return "key"
            }
        }())
        .foregroundColor(.accentColor)
    }
}
