import SwiftUI
import SwiftData

/// SwiftData 모델 - 클립보드 항목
@Model
final class ClipboardItem {
    /// 고유 식별자
    @Attribute(.unique) var id: UUID
    
    /// 원본 내용 (텍스트/URL의 경우 문자열로 저장)
    var content: String?
    
    /// 이미지 데이터 (압축 저장 또는 CloudKit Asset 활용 가능)
    var imageData: Data?
    
    /// 스마트 분석을 통해 감지된 콘텐츠 타입
    var contentType: SmartContentType
    
    /// 생성 시간
    var createdAt: Date
    
    /// 만료 시간 (nil일 경우 무기한 유지)
    var expiresAt: Date?
    
    /// 사용자 고정 여부 (핀)
    var isPinned: Bool
    
    /// 원본이 생성된 디바이스 정보
    var sourceDevice: String?
    
    init(
        id: UUID = UUID(),
        content: String? = nil,
        imageData: Data? = nil,
        contentType: SmartContentType,
        createdAt: Date = Date(),
        expiresAt: Date? = nil,
        isPinned: Bool = false,
        sourceDevice: String? = nil
    ) {
        self.id = id
        self.content = content
        self.imageData = imageData
        self.contentType = contentType
        self.createdAt = createdAt
        self.expiresAt = expiresAt
        self.isPinned = isPinned
        self.sourceDevice = sourceDevice
    }
}
