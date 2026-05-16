import AppKit
import CodexBarCore
import Testing
@testable import CodexBar

@MainActor
@Suite(.serialized)
struct StatusMenuPreferencesActionTests {
    final class RecordingPreferencesWindowOpener: PreferencesWindowOpening {
        private(set) var openedTabs: [PreferencesTab] = []

        func openSettings(tab: PreferencesTab, selection: PreferencesSelection) {
            selection.tab = tab
            self.openedTabs.append(tab)
        }
    }

    func makeSettings() -> SettingsStore {
        let suite = "StatusMenuPreferencesActionTests-\(UUID().uuidString)"
        let defaults = UserDefaults(suiteName: suite)!
        defaults.removePersistentDomain(forName: suite)
        let configStore = testConfigStore(suiteName: suite)
        return SettingsStore(
            userDefaults: defaults,
            configStore: configStore,
            zaiTokenStore: NoopZaiTokenStore(),
            syntheticTokenStore: NoopSyntheticTokenStore())
    }

    func makeCodexStore(settings: SettingsStore) -> UsageStore {
        let now = Date()
        let fetcher = UsageFetcher()
        let store = UsageStore(fetcher: fetcher, browserDetection: BrowserDetection(cacheTTL: 0), settings: settings)
        store._setSnapshotForTesting(
            UsageSnapshot(
                primary: RateWindow(
                    usedPercent: 22,
                    windowMinutes: 300,
                    resetsAt: now.addingTimeInterval(1800),
                    resetDescription: nil),
                secondary: nil,
                tertiary: nil,
                updatedAt: now,
                identity: ProviderIdentitySnapshot(
                    providerID: .codex,
                    accountEmail: "codex@example.com",
                    accountOrganization: nil,
                    loginMethod: "Plus Plan")),
            provider: .codex)
        return store
    }

    @Test
    func `settings and about actions open the requested preferences tab`() {
        StatusItemController.menuCardRenderingEnabled = false
        StatusItemController.setMenuRefreshEnabledForTesting(false)

        let settings = self.makeSettings()
        let store = self.makeCodexStore(settings: settings)
        let selection = PreferencesSelection()
        let opener = RecordingPreferencesWindowOpener()
        let controller = StatusItemController(
            store: store,
            settings: settings,
            account: store.accountInfo(for: .codex),
            updater: DisabledUpdaterController(),
            preferencesSelection: selection,
            statusBar: .system,
            preferencesWindowOpener: opener)

        controller.showSettingsGeneral()
        controller.showSettingsAbout()

        #expect(opener.openedTabs == [.general, .about])
        #expect(selection.tab == .about)
    }
}
