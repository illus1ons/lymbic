
import SwiftUI

struct ClipboardItemCardView: View {
    let item: ClipboardItem

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                // 콘텐츠 타입 아이콘
                Image(systemName: item.contentType.iconName)
                    .font(.title3)
                    .foregroundColor(.accentColor)
                Spacer()
                if item.isPinned {
                    Image(systemName: "pin.fill")
                        .foregroundColor(.yellow)
                }
            }

            // 콘텐츠 미리보기
            if let _ = item.imageData {
                Image(systemName: "photo")
                    .font(.largeTitle)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Text(item.content ?? "")
                    .font(.body)
                    .lineLimit(2)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .foregroundColor(Color.textColorPrimary)
            }

            Spacer()

            // 메타데이터 푸터
            HStack {
                Text(item.createdAt, style: .relative)
                    .font(.caption)
                    .foregroundColor(Color.textColorSecondary)
                Spacer()
                if let date = item.expiresAt {
                    CountdownBadge(expirationDate: date)
                }
            }
        }
        .padding() // 카드 내부 패딩
        .frame(minWidth: 150, idealHeight: 120)
        .modifier(DesignSystem.cardModifier()) // DesignSystem의 카드 스타일 적용
    }
}

#Preview {
    ClipboardItemCardView(item: .init(content: "미리보기 콘텐츠", contentType: .none, sourceDevice: "Mac"))
}
