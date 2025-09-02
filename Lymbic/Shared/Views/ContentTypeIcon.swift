import SwiftUI

/// 콘텐츠 타입을 나타내는 아이콘 뷰
struct ContentTypeIcon: View {
    let type: SmartContentType
    
    var body: some View {
        Image(systemName: {
            switch type {
            case .none: return "text.quote.rtl"
            case .url: return "link"
            case .email: return "envelope.fill"
            case .phoneNumber: return "phone.fill"
            }
        }())
        .foregroundColor(.accentColor)
    }
}
