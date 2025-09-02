
import Foundation

/// 앱의 클립보드 관련 상태를 메모리에서 관리하는 싱글톤 클래스
/// 데이터베이스 조회를 최소화하여 성능을 향상시키는 데 사용됩니다.
final class ClipboardState {
    /// 공유 인스턴스
    static let shared = ClipboardState()

    /// 마지막으로 데이터베이스에 추가된 텍스트 콘텐츠
    var lastAddedContent: String?
    /// 마지막으로 데이터베이스에 추가된 이미지 데이터
    var lastAddedImageData: Data?

    private init() {}
}
