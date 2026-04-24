import Foundation

enum LauncherStoreConfiguration {
    static let appGroupID = "group.com.example.DumbPhone"
    static let storageKey = "launcher.entries"

    static let starterEntries: [LauncherEntry] = [
        LauncherEntry(label: "Mail", shortcutName: "Open Mail"),
        LauncherEntry(label: "Notes", shortcutName: "Open Notes"),
        LauncherEntry(label: "Browser", shortcutName: "Open Browser"),
        LauncherEntry(label: "Calendar", shortcutName: "Open Calendar"),
        LauncherEntry(label: "Messages", shortcutName: "Open Messages"),
    ]
}

struct LauncherStore {
    private let defaults: UserDefaults

    init(defaults: UserDefaults? = UserDefaults(suiteName: LauncherStoreConfiguration.appGroupID)) {
        self.defaults = defaults ?? .standard
    }

    func loadEntries() -> [LauncherEntry] {
        guard let data = defaults.data(forKey: LauncherStoreConfiguration.storageKey) else {
            return LauncherStoreConfiguration.starterEntries
        }

        do {
            let entries = try JSONDecoder().decode([LauncherEntry].self, from: data)
            return entries.isEmpty ? LauncherStoreConfiguration.starterEntries : entries
        } catch {
            return LauncherStoreConfiguration.starterEntries
        }
    }

    func saveEntries(_ entries: [LauncherEntry]) throws {
        let data = try JSONEncoder().encode(entries)
        defaults.set(data, forKey: LauncherStoreConfiguration.storageKey)
    }

    func seedIfNeeded() {
        guard defaults.data(forKey: LauncherStoreConfiguration.storageKey) == nil else {
            return
        }

        try? saveEntries(LauncherStoreConfiguration.starterEntries)
    }
}
