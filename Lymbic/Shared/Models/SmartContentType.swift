
import Foundation

enum SmartContentType: String, Codable {
    case none // 일반 텍스트
    case url
    case email
    case phoneNumber
    // 향후 확장 가능: .trackingNumber, .hexColor, .address 등
}

// MARK: - 로직 확장
extension SmartContentType {
    /// 콘텐츠 타입에 맞는 SF Symbol 아이콘 이름을 반환합니다.
    var iconName: String {
        switch self {
        case .none: return "text.quote.rtl"
        case .url: return "link"
        case .email: return "envelope.fill"
        case .phoneNumber: return "phone.fill"
        }
    }
}

