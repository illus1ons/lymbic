import SwiftUI

struct CountdownBadge: View {
    let expirationDate: Date
    @State private var timeRemaining: TimeInterval
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    init(expirationDate: Date) {
        self.expirationDate = expirationDate
        _timeRemaining = State(initialValue: expirationDate.timeIntervalSinceNow)
    }

    var body: some View {
        Text(timeString(time: timeRemaining))
            .font(.caption.monospacedDigit())
            .padding(.horizontal, 6)
            .padding(.vertical, 2)
            .background(Material.ultraThin)
            .clipShape(Capsule())
            .foregroundColor(timeRemaining < 60 ? .red : .secondary)
            .onReceive(timer) { _ in
                self.timeRemaining = expirationDate.timeIntervalSinceNow
            }
            .onDisappear {
                timer.upstream.connect().cancel()
            }
    }

    private func timeString(time: TimeInterval) -> String {
        if time <= 0 {
            return "0:00"
        }
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}