import AppIntents
import WidgetKit

struct TextLauncherWidgetConfigurationIntent: WidgetConfigurationIntent {
    static var title: LocalizedStringResource = "Widget Page"
    static var description = IntentDescription("Choose which slice of your launcher list this widget should display.")

    @Parameter(title: "Page")
    var page: Int

    init() {
        self.page = 1
    }

    init(page: Int) {
        self.page = page
    }

    static var parameterSummary: some ParameterSummary {
        Summary("Show page \(\.$page)")
    }
}

