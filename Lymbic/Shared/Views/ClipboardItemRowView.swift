
import SwiftUI

struct ClipboardItemRowView: View {
    let item: ClipboardItem

    var body: some View {
        HStack {
            Image(systemName: icon(for: item.contentType))
                .frame(width: 24)
                .foregroundColor(.accentColor)

            VStack(alignment: .leading) {
                Text(item.content ?? "")
                    .lineLimit(1)
                    .truncationMode(.tail)
                if let source = item.sourceDevice {
                    Text("\(source)에서 \(item.createdAt, style: .relative) 복사됨")
                        .font(.caption)
                        .foregroundColor(.secondary)
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
        .padding(.vertical, 4)
    }
    
    private func icon(for type: SmartContentType) -> String {
        switch type {
        case .none: return "text.quote"
        case .url: return "link"
        case .email: return "envelope"
        case .phoneNumber: return "phone"
        }
    }
}
