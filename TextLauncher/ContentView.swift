import SwiftUI
import UIKit

struct ContentView: View {
    @ObservedObject var viewModel: LauncherViewModel
    @Environment(\.openURL) private var openURL
    @State private var selectedPreviewSize: WidgetPreviewSize = .medium

    var body: some View {
        NavigationStack {
            List {
                Section {
                    VStack(alignment: .leading, spacing: 12) {
                        Text("DumbPhone")
                            .font(.system(size: 28, weight: .bold))
                        Text("Each row maps a visible label to an iOS Shortcut. Add the widget after you save your list.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.vertical, 8)
                    .listRowInsets(EdgeInsets(top: 20, leading: 20, bottom: 20, trailing: 20))
                    .listRowBackground(Color(.secondarySystemBackground))
                }

                Section("Widget Page Boundaries") {
                    Picker("Preview Size", selection: $selectedPreviewSize) {
                        ForEach(WidgetPreviewSize.allCases) { size in
                            Text(size.title).tag(size)
                        }
                    }
                    .pickerStyle(.segmented)

                    ForEach(Array(pageGroups.enumerated()), id: \.offset) { index, pageEntries in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack {
                                Text("Page \(pageNumber(for: index))")
                                    .font(.headline)
                                Spacer()
                                Text(pageRangeText(for: pageNumber(for: index), count: pageEntries.count))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            if pageEntries.isEmpty {
                                Text("No items yet")
                                    .foregroundStyle(.secondary)
                            } else {
                                ForEach(pageEntries) { entry in
                                    HStack {
                                        Text(entry.label.isEmpty ? "Untitled Item" : entry.label)
                                            .lineLimit(1)
                                        Spacer()
                                        Text(entry.shortcutName.isEmpty ? "No Shortcut" : entry.shortcutName)
                                            .font(.caption)
                                            .foregroundStyle(.secondary)
                                            .lineLimit(1)
                                    }
                                }
                            }
                        }
                        .padding(.vertical, 6)
                    }
                }

                Section("Launcher Items") {
                    ForEach(Array($viewModel.entries.enumerated()), id: \.element.id) { index, $entry in
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .firstTextBaseline) {
                                Text(itemPositionText(for: index))
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                                Spacer()
                                Text("Page \(entry.page)")
                                    .font(.caption.weight(.semibold))
                                    .foregroundStyle(.secondary)
                            }

                            TextField("Label", text: $entry.label)
                                .textInputAutocapitalization(.words)
                                .font(.headline)

                            TextField("Shortcut name", text: $entry.shortcutName)
                                .textInputAutocapitalization(.words)
                                .foregroundStyle(.secondary)

                            Stepper(value: $entry.page, in: 1...99) {
                                HStack {
                                    Text("Widget Page")
                                    Spacer()
                                    Text("\(entry.page)")
                                        .foregroundStyle(.secondary)
                                }
                            }

                            Button("Run Shortcut") {
                                runShortcut(named: entry.shortcutName)
                            }
                            .font(.footnote.weight(.semibold))
                            .buttonStyle(.borderless)
                            .tint(.primary)
                        }
                        .padding(.vertical, 6)
                        .onChange(of: entry.label) { _, _ in
                            viewModel.save()
                        }
                        .onChange(of: entry.shortcutName) { _, _ in
                            viewModel.save()
                        }
                        .onChange(of: entry.page) { _, newValue in
                            if newValue < 1 {
                                entry.page = 1
                            }
                            viewModel.save()
                        }
                        .listRowBackground(Color(.secondarySystemBackground))
                    }
                    .onDelete(perform: viewModel.deleteEntries)
                    .onMove(perform: viewModel.moveEntries)
                }

                Section("Tips") {
                    Text("Home Screen widgets can't scroll and iOS doesn't allow custom widget heights.")
                    Text("Assign each app to a widget page in the editor, then add multiple DumbPhone widgets and set each widget to a matching page.")
                    Text("Create Shortcuts with names like “Open Mail” or “Open Notes”, then use those exact names here.")
                    Text("Inside each Shortcut, use the target app's Open App action or URL scheme.")
                    Text("\(selectedPreviewSize.title) widgets show up to \(pageSize) apps from each page.")
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color(.systemGroupedBackground))
            .navigationTitle("DumbPhone")
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    EditButton()
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        viewModel.addEntry()
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
        }
    }

    private var pageSize: Int {
        selectedPreviewSize.pageSize
    }

    private var pageGroups: [[LauncherEntry]] {
        let pages = usedPages
        guard !pages.isEmpty else {
            return [[]]
        }

        return pages.map { page in
            Array(viewModel.entries.filter { $0.page == page }.prefix(pageSize))
        }
    }

    private func itemPositionText(for index: Int) -> String {
        "Item \(index + 1)"
    }

    private var usedPages: [Int] {
        let pages = Set(viewModel.entries.map(\.page))
        return pages.isEmpty ? [1] : pages.sorted()
    }

    private func pageNumber(for previewIndex: Int) -> Int {
        usedPages[previewIndex]
    }

    private func pageRangeText(for page: Int, count: Int) -> String {
        guard count > 0 else {
            return "Empty"
        }

        let totalOnPage = viewModel.entries.filter { $0.page == page }.count
        if totalOnPage > pageSize {
            return "Showing \(pageSize) of \(totalOnPage)"
        }

        return "\(count) item" + (count == 1 ? "" : "s")
    }

    private func runShortcut(named shortcutName: String) {
        guard let url = LaunchRouting.shortcutsURL(for: shortcutName) else {
            return
        }

        openURL(url)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView(viewModel: LauncherViewModel())
    }
}

private enum WidgetPreviewSize: String, CaseIterable, Identifiable {
    case medium
    case large

    var id: String { rawValue }

    var title: String {
        switch self {
        case .medium:
            "Medium"
        case .large:
            "Large"
        }
    }

    var pageSize: Int {
        switch self {
        case .medium:
            4
        case .large:
            7
        }
    }
}
