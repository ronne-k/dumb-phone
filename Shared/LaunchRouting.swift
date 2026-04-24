import Foundation

enum LaunchRouting {
    static let appScheme = "dumbphone"

    static func widgetLaunchURL(for entry: LauncherEntry) -> URL {
        var components = URLComponents()
        components.scheme = appScheme
        components.host = "launch"
        components.queryItems = [
            URLQueryItem(name: "id", value: entry.id.uuidString)
        ]

        return components.url!
    }

    static func shortcutsURL(for shortcutName: String) -> URL? {
        guard !shortcutName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            return nil
        }

        var components = URLComponents()
        components.scheme = "shortcuts"
        components.host = "run-shortcut"
        components.queryItems = [
            URLQueryItem(name: "name", value: shortcutName)
        ]

        return components.url
    }

    static func entryID(from url: URL) -> UUID? {
        guard url.scheme == appScheme, url.host == "launch" else {
            return nil
        }

        guard
            let idString = URLComponents(url: url, resolvingAgainstBaseURL: false)?
                .queryItems?
                .first(where: { $0.name == "id" })?
                .value
        else {
            return nil
        }

        return UUID(uuidString: idString)
    }
}
