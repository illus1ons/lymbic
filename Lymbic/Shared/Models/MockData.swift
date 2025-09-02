
import Foundation

/// 미리보기 및 테스트를 위한 중앙 목업 데이터 저장소
enum MockData {
    static let sampleItems: [ClipboardItem] = [
        .init(content: "https://swift.org/blog/swift-6-is-coming/", contentType: .url, sourceDevice: "MacBook Pro"),
        .init(content: "test@example.com", contentType: .email, expiresAt: Date().addingTimeInterval(120), sourceDevice: "iPhone 15 Pro"),
        .init(content: "디자인 시스템 색상", contentType: .none, isPinned: true, sourceDevice: "MacBook Pro"),
        .init(content: "010-1234-5678", contentType: .phoneNumber, expiresAt: Date().addingTimeInterval(300), sourceDevice: "iPhone 15 Pro"),
        .init(imageData: Data(), contentType: .none, sourceDevice: "iPad Pro") // .none for generic image
    ]
}
