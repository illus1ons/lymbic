//
//  CountdownBadge.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct CountdownBadge: View {
    let expiresAt: Date
    @State private var now = Date()
    
    var remainingText: String {
        let interval = Int(expiresAt.timeIntervalSince(now))
        if interval > 0 {
            return "⏰ \(interval / 60)분 후"
        } else {
            return "만료됨"
        }
    }
    
    var body: some View {
        Text(remainingText)
            .font(.caption2)
            .padding(6)
            .background(Color.red.opacity(0.1))
            .foregroundColor(.red)
            .clipShape(RoundedRectangle(cornerRadius: 6))
            .onAppear {
                // 1분마다 갱신
                Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                    now = Date()
                }
            }
    }
}
