import AppKit

@MainActor
protocol PreferencesWindowOpening {
    func openSettings(tab: PreferencesTab, selection: PreferencesSelection)
}

struct DefaultPreferencesWindowOpener: PreferencesWindowOpening {
    func openSettings(tab: PreferencesTab, selection: PreferencesSelection) {
        DispatchQueue.main.async {
            selection.tab = tab
            NSApp.activate(ignoringOtherApps: true)
            let didOpen = NSApp.sendAction(Selector(("showPreferencesWindow:")), to: nil, from: nil)
            if !didOpen {
                NotificationCenter.default.post(
                    name: .codexbarOpenSettings,
                    object: nil,
                    userInfo: ["tab": tab.rawValue])
            }
        }
    }
}
