import SwiftUI

struct ClipboardItemView: View {
    let item: ClipboardItem
    var isCardStyle: Bool = false
    
    // 아이콘
    private var iconName: String {
        // 이제 SmartContentType을 직접 사용합니다.
        switch item.contentType {
        case .none: return "text.quote.rtl"
        case .url: return "link"
        case .email: return "envelope.fill"
        case .phoneNumber: return "phone.fill"
        }
    }
    
    // 상대 시간
    private var relativeTime: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.localizedString(for: item.createdAt, relativeTo: Date())
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
                // 이미지 vs 텍스트/URL
                if let data = item.imageData {
                    #if canImport(UIKit)
                    if let uiImage = UIImage(data: data) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
                    }
                    #elseif canImport(AppKit)
                    if let nsImage = NSImage(data: data) {
                        Image(nsImage: nsImage)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 100)
                            .cornerRadius(8)
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
                if item.contentType != .none {
                    smartActionsView(for: item, type: item.contentType)
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
                    // 경고 해결: 변수를 사용하지 않으므로 nil 체크만 수행
                    if item.content != nil {
                        Button("메일 보내기", systemImage: "envelope") { /* 액션 */ }
                        Button("주소 복사", systemImage: "doc.on.doc") { /* 액션 */ }
                    }
                case .phoneNumber:
                    // 경고 해결: 변수를 사용하지 않으므로 nil 체크만 수행
                    if item.content != nil {
                        Button("전화 걸기", systemImage: "phone") { /* 액션 */ }
                        Button("메시지 보내기", systemImage: "message") { /* 액션 */ }
                    }
                case .url:
                    if let urlString = item.content, let _ = URL(string: urlString) {
                        Button("URL 열기", systemImage: "safari") { /* 액션 */ }
                        Button("QR 코드 생성", systemImage: "qrcode") { /* 액션 */ }
                    }
                case .none:
                    EmptyView()
                }
            }
            .buttonStyle(.bordered)
            .controlSize(.small)
        }
        .scrollClipDisabled() // iOS 17+
    }
}
