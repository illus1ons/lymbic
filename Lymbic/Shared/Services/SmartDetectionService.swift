import Foundation

/// 문자열 콘텐츠를 분석하여 스마트 타입을 감지하는 서비스
struct SmartDetectionService {
    
    /// 주어진 문자열의 SmartContentType을 감지합니다.
    /// - Parameter content: 분석할 문자열
    /// - Returns: 감지된 SmartContentType (일치하는 항목이 없으면 .none)
    static func detect(from content: String) -> SmartContentType {
        if isEmail(content) {
            return .email
        } else if isPhoneNumber(content) {
            return .phoneNumber
        } else if isURL(content) {
            return .url
        } else {
            return .none
        }
    }
    
    private static func isEmail(_ text: String) -> Bool {
        // 간단한 이메일 정규식
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailTest.evaluate(with: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private static func isPhoneNumber(_ text: String) -> Bool {
        // 숫자, 하이픈, 괄호, 공백을 포함하는 전화번호 패턴 (국가별 형식 고려 필요)
        let phoneRegex = "^[0-9\\s\\-()]{8,15}$"
        let phoneTest = NSPredicate(format: "SELF MATCHES %@", phoneRegex)
        return phoneTest.evaluate(with: text.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    private static func isURL(_ text: String) -> Bool {
        // http 또는 https로 시작하는지 확인하는 간단한 방법
        let lowercasedText = text.lowercased().trimmingCharacters(in: .whitespacesAndNewlines)
        return lowercasedText.hasPrefix("http://") || lowercasedText.hasPrefix("https://")
    }
}
