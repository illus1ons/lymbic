//
//  ClipboardContentType.swift
//  Lymbic
//
//  Created by 유영배 on 8/31/25.
//


import SwiftUI
import SwiftData

/// 클립보드 항목의 타입 정의
enum ClipboardContentType: String, Codable, Identifiable, CaseIterable {
    case text
    case url
    case image
    case otp
    
    var id: String { rawValue }
}

/// SwiftData 모델 - 클립보드 항목
@Model
final class ClipboardItem {
    /// 고유 식별자
    @Attribute(.unique) var id: UUID
    
    /// 원본 내용 (텍스트/URL의 경우 문자열로 저장)
    var content: String?
    
    /// 이미지 데이터 (압축 저장 또는 CloudKit Asset 활용 가능)
    var imageData: Data?
    
    /// 콘텐츠 타입 (텍스트/URL/이미지 구분)
    var contentType: ClipboardContentType
    
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
        contentType: ClipboardContentType,
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
