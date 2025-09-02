//
//  ClipboardItemView.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//

import SwiftUI

struct ClipboardItemView: View {
    let item: ClipboardItem
    var isCardStyle: Bool = false
    
    // 아이콘
    private var iconName: String {
        switch item.contentType {
        case .text: return "textformat"
        case .url: return "link"
        case .image: return "photo"
        case .otp: return "key"
        }
    }
    
    // 상대 시간
    private var relativeTime: String {
        RelativeDateTimeFormatter()
            .localizedString(for: item.createdAt, relativeTo: Date())
    }
    
    // 자동 삭제 텍스트
    private var expiresText: String? {
        guard let expiresAt = item.expiresAt else { return nil }
        let interval = Int(expiresAt.timeIntervalSinceNow)
        if interval > 0 {
            return "⏰ \(interval / 60)분 후 자동 삭제"
        } else {
            return "만료됨"
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {
            Image(systemName: iconName)
                .foregroundColor(.accentColor)
                .frame(width: 24, height: 24)
            
            VStack(alignment: .leading, spacing: 4) {
                // 텍스트/URL vs 이미지
                if item.contentType == .image, let data = item.imageData {
                    #if os(iOS)
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    } else {
                        Text("[이미지 없음]")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    #elseif os(macOS)
                    if let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    } else {
                        Text("[이미지 없음]")
                            .font(.body)
                            .foregroundColor(.secondary)
                    }
                    #endif
                } else {
                    Text(item.content ?? "[내용 없음]")
                        .lineLimit(3)
                        .font(.body)
                }

                if let expiresText {
                    Text(expiresText)
                        .font(.caption)
                        .foregroundColor(.red)
                } else {
                    Text(relativeTime)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                
                // 스마트 액션 버튼 표시
                if let smartType = item.smartContentType, smartType != .none {
                    smartActionsView(for: item, type: smartType)
                        .padding(.top, 4)
                }
            }
            
            if item.isPinned {
                Spacer()
                Image(systemName: "pin.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(isCardStyle ? 12 : 4)
        .background(isCardStyle ? DesignSystem.cardBackground : Color.clear)
        .clipShape(
            isCardStyle
                ? AnyShape(RoundedRectangle(cornerRadius: 12))
                : AnyShape(Rectangle())
        )

    }
    
    @ViewBuilder
    private func smartActionsView(for item: ClipboardItem, type: SmartContentType) -> some View {
        // 스마트 액션 버튼들을 가로로 나열
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                switch type {
                case .email:
                    if let email = item.content {
                        Button("메일 보내기", systemImage: "envelope") {
                            // Action: open mail client
                        }
                        Button("주소 복사", systemImage: "doc.on.doc") {
                            // Action: copy email address
                        }
                    }
                case .phoneNumber:
                    if let number = item.content {
                        Button("전화 걸기", systemImage: "phone") {
                            // Action: initiate call
                        }
                        Button("메시지 보내기", systemImage: "message") {
                            // Action: open messages app
                        }
                    }
                case .url:
                    if let urlString = item.content, let url = URL(string: urlString) {
                        Button("URL 열기", systemImage: "safari") {
                            // Action: open URL
                        }
                        Button("QR 코드 생성", systemImage: "qrcode") {
                            // Action: generate QR code
                        }
                    }
                case .none:
                    // 아무것도 표시하지 않음
                    EmptyView()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .scrollClipDisabled() // iOS 17+
    }
}
