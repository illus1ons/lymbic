import SwiftUI

// MARK: - Placeholder Data Models

struct AutoDeleteRule: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var icon: String
    var interval: TimeInterval
    
    var displayInterval: String {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.allowedUnits = [.hour, .minute, .day]
        return formatter.string(from: interval) ?? ""
    }
}

struct UserProfile: Identifiable, Hashable {
    let id = UUID()
    var name: String
    var icon: String
}

// MARK: - Placeholder Detail Views

struct RuleDetailView: View {
    let rule: AutoDeleteRule
    var body: some View { Text("\(rule.name) 설정 편집") .navigationTitle(rule.name) }
}

struct ProfileDetailView: View {
    let profile: UserProfile
    var body: some View { Text("\(profile.name) 프로필 편집") .navigationTitle(profile.name) }
}

// MARK: - Main Settings View

struct SettingsView: View {
    // MARK: - State Variables (Placeholders)
    
    @State private var isICloudEnabled = true
    @State private var syncedDeviceCount = 2
    
    @State private var autoDeleteRules: [AutoDeleteRule] = [
        .init(name: "OTP 코드", icon: "key.radiowaves.forward", interval: TimeInterval(3 * 60)),
        .init(name: "계좌 정보", icon: "creditcard", interval: TimeInterval(5 * 60)),
        .init(name: "임시 링크", icon: "link", interval: TimeInterval(60 * 60))
    ]
    
    @State private var userProfiles: [UserProfile] = [
        .init(name: "업무용 프로필", icon: "briefcase"),
        .init(name: "개인용 프로필", icon: "house")
    ]
    
    private var appVersion: String {
        Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "N/A"
    }

    // MARK: - Body
    
    var body: some View {
        NavigationStack {
            Form {
                syncSection
                autoDeleteSection
                profileSection
                appInfoSection
            }
            .scrollContentBackground(.hidden) // iOS 16+ 폼 배경 투명화
            .background(Color.primaryBackground) // 폼 전체 배경
            .navigationTitle("설정")
            .toolbar {
                ToolbarItemGroup(placement: .automatic) {
                    Button(action: {}) { Label("피드백", systemImage: "bubble.left.and.bubble.right") }.buttonStyle(DesignSystem.toolbarButton())
                    Button(action: {}) { Label("도움말", systemImage: "questionmark.circle") }.buttonStyle(DesignSystem.toolbarButton())
                }
            }
            // MARK: - Navigation Destinations
            .navigationDestination(for: AutoDeleteRule.self) { rule in
                RuleDetailView(rule: rule)
            }
            .navigationDestination(for: UserProfile.self) { profile in
                ProfileDetailView(profile: profile)
            }
            .navigationDestination(for: String.self) { value in
                switch value {
                case "add_rule":
                    Text("새 규칙 추가 화면")
                case "add_profile":
                    Text("새 프로필 추가 화면")
                default:
                    Text("알 수 없는 링크: \(value)")
                }
            }
        }
    }
    
    // MARK: - Sections

    @ViewBuilder
    private var syncSection: some View {
        Section(header: Text("동기화")) {
            Toggle(isOn: $isICloudEnabled) {
                Label("iCloud 연결됨", systemImage: "icloud")
            }
            Label("\(syncedDeviceCount)개 기기 동기화됨", systemImage: "macbook.and.iphone")
                .foregroundStyle(.secondary)
        }
    }
    
    @ViewBuilder
    private var autoDeleteSection: some View {
        Section(header: Text("자동 삭제 설정")) {
            ForEach(autoDeleteRules) { rule in
                NavigationLink(value: rule) {
                    Label(rule.name, systemImage: rule.icon)
                        .badge(Text("\(rule.displayInterval) 후 삭제"))
                }
            }
            NavigationLink(value: "add_rule") {
                Label("사용자 정의 규칙 추가", systemImage: "plus.circle.fill")
            }
        }
    }
    
    @ViewBuilder
    private var profileSection: some View {
        Section(header: Text("프로필")) {
            ForEach(userProfiles) { profile in
                NavigationLink(value: profile) {
                    Label(profile.name, systemImage: profile.icon)
                }
            }
            NavigationLink(value: "add_profile") {
                Label("새 프로필 생성", systemImage: "plus.circle.fill")
            }
        }
    }
    
    @ViewBuilder
    private var appInfoSection: some View {
        Section(header: Text("앱 정보")) {
            Label("버전 \(appVersion)", systemImage: "info.circle")
            
            if let url = URL(string: "https://www.example.com/privacy") {
                Link(destination: url) {
                    Label("개인정보처리방침", systemImage: "lock.shield")
                }
            }
            
            if let url = URL(string: "mailto:support@example.com") {
                Link(destination: url) {
                    Label("고객 지원", systemImage: "envelope")
                }
            }
        }
        .foregroundStyle(.primary) // Ensure links are tappable
    }
}

// MARK: - Preview

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
    }
}
