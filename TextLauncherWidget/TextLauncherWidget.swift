import SwiftUI
import WidgetKit

struct TextLauncherTimelineEntry: TimelineEntry {
    let date: Date
    let entries: [LauncherEntry]
    let page: Int
}

struct TextLauncherProvider: AppIntentTimelineProvider {
    private let store = LauncherStore()

    func placeholder(in context: Context) -> TextLauncherTimelineEntry {
        TextLauncherTimelineEntry(
            date: .now,
            entries: LauncherStoreConfiguration.starterEntries,
            page: 1
        )
    }

    func snapshot(
        for configuration: TextLauncherWidgetConfigurationIntent,
        in context: Context
    ) async -> TextLauncherTimelineEntry {
        TextLauncherTimelineEntry(
            date: .now,
            entries: store.loadEntries(),
            page: normalizedPage(from: configuration)
        )
    }

    func timeline(
        for configuration: TextLauncherWidgetConfigurationIntent,
        in context: Context
    ) async -> Timeline<TextLauncherTimelineEntry> {
        let entry = TextLauncherTimelineEntry(
            date: .now,
            entries: store.loadEntries(),
            page: normalizedPage(from: configuration)
        )

        return Timeline(entries: [entry], policy: .never)
    }

    private func normalizedPage(from configuration: TextLauncherWidgetConfigurationIntent) -> Int {
        max(configuration.page, 1)
    }
}

struct TextLauncherWidget: Widget {
    let kind = "TextLauncherWidget"

    var body: some WidgetConfiguration {
        AppIntentConfiguration(
            kind: kind,
            intent: TextLauncherWidgetConfigurationIntent.self,
            provider: TextLauncherProvider()
        ) { entry in
            TextLauncherWidgetView(entry: entry)
        }
        .configurationDisplayName("DumbPhone")
        .description("Launch shortcuts from a text-only widget. Add multiple widgets to show more pages.")
        .supportedFamilies([.systemMedium, .systemLarge])
    }
}

private struct TextLauncherWidgetView: View {
    let entry: TextLauncherTimelineEntry
    @Environment(\.widgetFamily) private var family

    private var pageSize: Int {
        switch family {
        case .systemLarge:
            7
        default:
            4
        }
    }

    private var displayedEntries: [LauncherEntry] {
        Array(entry.entries.filter { $0.page == entry.page }.prefix(pageSize))
    }

    private var itemFont: Font {
        .system(size: family == .systemLarge ? 32 : 32, weight: .bold, design: .default)
    }

    private func displayLabel(for item: LauncherEntry) -> String {
        item.label.uppercased()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: family == .systemLarge ? 18 : 14) {
            if displayedEntries.isEmpty {
                Text("No items on this page")
                    .font(.system(size: family == .systemLarge ? 24 : 24, weight: .bold, design: .default))
                    .tracking(2.2)
                    .foregroundStyle(.black.opacity(0.55))
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            } else {
                ForEach(displayedEntries) { item in
                    Link(destination: LaunchRouting.widgetLaunchURL(for: item)) {
                        Text(displayLabel(for: item))
                            .font(itemFont)
                            .tracking(2.8)
                            .foregroundStyle(.black)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .lineLimit(1)
                            .minimumScaleFactor(0.8)
                    }
                    .buttonStyle(.plain)
                }
            }

            Spacer(minLength: 0)
        }
        .padding(family == .systemLarge ? 24 : 22)
        .containerBackground(Color.white, for: .widget)
    }
}

struct TextLauncherWidget_Previews: PreviewProvider {
    static var previews: some View {
        TextLauncherWidgetView(
            entry: TextLauncherTimelineEntry(
                date: .now,
                entries: LauncherStoreConfiguration.starterEntries,
                page: 1
            )
        )
        .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
