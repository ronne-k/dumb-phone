import SwiftUI
import UIKit

@main
struct TextLauncherApp: App {
    @StateObject private var viewModel = LauncherViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView(viewModel: viewModel)
                .onOpenURL { url in
                    handleIncoming(url: url)
                }
        }
    }

    private func handleIncoming(url: URL) {
        guard let id = LaunchRouting.entryID(from: url) else {
            return
        }

        guard let entry = viewModel.entries.first(where: { $0.id == id }) else {
            return
        }

        runShortcut(named: entry.shortcutName)
    }

    private func runShortcut(named shortcutName: String) {
        guard let shortcutURL = LaunchRouting.shortcutsURL(for: shortcutName) else {
            return
        }

        UIApplication.shared.open(shortcutURL)
    }
}
