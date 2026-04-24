import Foundation

struct LauncherEntry: Codable, Identifiable, Equatable {
    var id: UUID
    var label: String
    var shortcutName: String
    var page: Int

    init(id: UUID = UUID(), label: String, shortcutName: String, page: Int = 1) {
        self.id = id
        self.label = label
        self.shortcutName = shortcutName
        self.page = max(page, 1)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case label
        case shortcutName
        case page
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        label = try container.decode(String.self, forKey: .label)
        shortcutName = try container.decode(String.self, forKey: .shortcutName)
        page = try container.decodeIfPresent(Int.self, forKey: .page) ?? 1
        page = max(page, 1)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(label, forKey: .label)
        try container.encode(shortcutName, forKey: .shortcutName)
        try container.encode(page, forKey: .page)
    }
}
