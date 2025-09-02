
import Foundation

/// 클립보드 항목의 내용에 따라 분석된 스마트 콘텐츠 타입
enum SmartContentType: String, Codable {
    case none // 일반 텍스트
    case url
    case email
    case phoneNumber
    // 향후 확장 가능: .trackingNumber, .hexColor, .address 등
}
