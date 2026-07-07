import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var store: Store
    @EnvironmentObject var purchases: PurchaseManager
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationStack {
            Form {
                Section("Preferences") {
                    Toggle("Enable category filters", isOn: $store.categoryFilterEnabled)
                        .accessibilityIdentifier("categoryFilterToggle")
                    Toggle("Reminder notifications", isOn: $store.notificationsEnabled)
                        .accessibilityIdentifier("notificationsToggle")
                }
                Section("Wodcard Pro") {
                    if purchases.isPro {
                        Label("Pro unlocked", systemImage: "checkmark.seal.fill")
                            .foregroundStyle(Theme.accent)
                    } else {
                        Text("Benchmark-WOD trend charts and PR history")
                            .font(Theme.captionFont)
                        Button("Restore Purchases") {
                            Task { await purchases.restore() }
                        }
                        .accessibilityIdentifier("restorePurchasesButton")
                    }
                }
                Section("About") {
                    Link("Privacy Policy", destination: URL(string: "https://shimondeitel.github.io/wodcard-app/privacy.html")!)
                    Link("Terms of Use", destination: URL(string: "https://shimondeitel.github.io/wodcard-app/terms.html")!)
                    Text("Version 1.0")
                        .foregroundStyle(Theme.textSecondary)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") { dismiss() }
                        .accessibilityIdentifier("settingsDoneButton")
                }
            }
        }
    }
}
