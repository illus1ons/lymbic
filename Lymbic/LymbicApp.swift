import SwiftUI
import SwiftData

@main
struct LymbicApp: App {
    var body: some Scene {
        WindowGroup {
#if os(iOS)
            iOSContentView()
                .withAppLifecycleObserver()
#elseif os(macOS)
            macOSContentView()
                .withAppLifecycleObserver()
#else
            Text("지원하지 않는 플랫폼")
#endif
        }
        .modelContainer(for: ClipboardItem.self)
    }
}
