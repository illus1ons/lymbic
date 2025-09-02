import SwiftUI

// 플랫폼별 프레임워크 import
#if canImport(UIKit)
import UIKit
#elseif canImport(AppKit)
import AppKit
#endif

enum DesignSystem {
    // MARK: - Colors
    static let primaryBackground = Color(uiColor: UIColor(dynamicProvider: { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.11, green: 0.11, blue: 0.11, alpha: 1.0) : // Dark: #1C1C1E
            UIColor(red: 0.95, green: 0.95, blue: 0.97, alpha: 1.0)   // Light: #F2F2F7
    }))
    
    static let secondaryBackground = Color(uiColor: UIColor(dynamicProvider: { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.17, green: 0.17, blue: 0.18, alpha: 1.0) : // Dark: #2C2C2E
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)     // Light: #FFFFFF
    }))
    
    static let accentColor = Color(uiColor: UIColor(dynamicProvider: { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.04, green: 0.52, blue: 1.0, alpha: 1.0) :  // Dark: #0A84FF
            UIColor(red: 0.0, green: 0.47, blue: 1.0, alpha: 1.0)    // Light: #007AFF
    }))
    
    static let textColorPrimary = Color(uiColor: UIColor(dynamicProvider: { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0) :  // Dark: #FFFFFF
            UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 1.0)    // Light: #000000
    }))
    
    static let textColorSecondary = Color(uiColor: UIColor(dynamicProvider: { traitCollection in
        return traitCollection.userInterfaceStyle == .dark ?
            UIColor(red: 0.59, green: 0.59, blue: 0.60, alpha: 1.0) : // Dark: #98989A
            UIColor(red: 0.56, green: 0.56, blue: 0.58, alpha: 1.0)   // Light: #8E8E93
    }))
    
    // 기존 cardBackground 유지 (이제 사용되지 않음)
    #if os(iOS)
    static let cardBackground = Color(.systemGray6)
    #elseif os(macOS)
    static let cardBackground = Color(nsColor: NSColor.windowBackgroundColor)
    #endif
    
    // MARK: - Common Modifiers
    /// 카드 스타일을 적용하는 ViewModifier
    struct CardStyle: ViewModifier {
        func body(content: Content) -> some View {
            content
                .background(DesignSystem.secondaryBackground) // secondaryBackground 사용
                .cornerRadius(12)
                .shadow(color: Color.black.opacity(0.15), radius: 8, x: 0, y: 4) // 그림자 강조
        }
    }
    
    /// 카드 스타일을 적용하는 편리한 확장
    static func cardModifier() -> some ViewModifier {
        CardStyle()
    }
    
    /// 툴바 버튼 스타일
    struct ToolbarButtonStyle: ButtonStyle {
        func makeBody(configuration: Configuration) -> some View {
            configuration.label
                .padding(.horizontal, 8)
                .padding(.vertical, 4)
                .background(Material.ultraThin)
                .cornerRadius(8)
                .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
        }
    }
    
    /// 툴바 버튼 스타일을 적용하는 편리한 확장
    static func toolbarButton() -> some ButtonStyle {
        ToolbarButtonStyle()
    }
}

// Assets.xcassets에 정의된 색상을 사용하기 위한 확장 (이제 사용되지 않음)
extension Color {
    static let primaryBackground = DesignSystem.primaryBackground
    static let secondaryBackground = DesignSystem.secondaryBackground
    static let accentColor = DesignSystem.accentColor
    static let textColorPrimary = DesignSystem.textColorPrimary
    static let textColorSecondary = DesignSystem.textColorSecondary
}
