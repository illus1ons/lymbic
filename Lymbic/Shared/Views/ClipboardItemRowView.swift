
import SwiftUI

struct ClipboardItemRowView: View {
    let item: ClipboardItem

    var body: some View {
        HStack {
            Image(systemName: item.contentType.iconName)
                .frame(width: 24)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading) {
                Text(item.content ?? "")
                    .lineLimit(1)
                    .truncationMode(.tail)
                    .foregroundColor(.textColorPrimary)
                if let source = item.sourceDevice {
                    Text("\(source)에서 \(item.createdAt, style: .relative) 복사됨")
                        .font(.caption)
                        .foregroundColor(Color.textColorSecondary)
                }
            }

            Spacer()

            if let date = item.expiresAt {
                CountdownBadge(expirationDate: date)
            }
            
            if item.isPinned {
                Image(systemName: "pin.fill")
                    .foregroundColor(.yellow)
            }
        }
        .padding(12) // 카드 내부 패딩
        .modifier(DesignSystem.cardModifier()) // DesignSystem의 카드 스타일 적용
    }
}
