import Foundation
import Combine
import WidgetKit

final class LauncherViewModel: ObservableObject {
    private let store = LauncherStore()
    @Published var entries: [LauncherEntry] = []

    init() {
        store.seedIfNeeded()
        entries = store.loadEntries()
    }

    func save() {
        do {
            try store.saveEntries(entries)
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            assertionFailure("Failed to save entries: \(error)")
        }
    }

    func addEntry() {
        let nextPage = max(entries.map(\.page).max() ?? 0, 1)
        entries.append(LauncherEntry(label: "New Item", shortcutName: "Shortcut Name", page: nextPage))
        save()
    }

    func deleteEntries(at offsets: IndexSet) {
        entries.remove(atOffsets: offsets)
        save()
    }

    func moveEntries(from source: IndexSet, to destination: Int) {
        entries.move(fromOffsets: source, toOffset: destination)
        save()
    }
}
