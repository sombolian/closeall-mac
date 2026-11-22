// CloseAll for Mac — tick the open apps you want to close, then press Close.
import SwiftUI
import AppKit

struct RunningItem: Identifiable {
    let id: pid_t
    let app: NSRunningApplication
    let name: String
    let icon: NSImage
    var selected: Bool
}

@MainActor
final class Model: ObservableObject {
    @Published var items: [RunningItem] = []

    // Apps that start unticked so you don't close them by accident.
    private let untickedByDefault: Set<String> = ["com.anthropic.claudefordesktop"]

    init() { reload() }

    func reload() {
        let me = Bundle.main.bundleIdentifier
        let previous = Dictionary(items.map { ($0.id, $0.selected) }, uniquingKeysWith: { a, _ in a })
        items = NSWorkspace.shared.runningApplications
            .filter {
                $0.activationPolicy == .regular && !$0.isTerminated &&
                $0.bundleIdentifier != me && $0.bundleIdentifier != "com.apple.finder"
            }
            .map { app in
                let defaultOn = !untickedByDefault.contains(app.bundleIdentifier ?? "")
                return RunningItem(
                    id: app.processIdentifier,
                    app: app,
                    name: app.localizedName ?? "App",
                    icon: app.icon ?? NSImage(),
                    selected: previous[app.processIdentifier] ?? defaultOn
                )
            }
            .sorted { $0.name.localizedCaseInsensitiveCompare($1.name) == .orderedAscending }
    }

    var selectedCount: Int { items.filter(\.selected).count }
    var allSelected: Bool { !items.isEmpty && items.allSatisfy(\.selected) }
    func setAll(_ on: Bool) { for i in items.indices { items[i].selected = on } }

    // Polite quit: apps with unsaved work still ask you to save.
    func closeSelected() { for item in items where item.selected { item.app.terminate() } }
}

struct Row: View {
    @Binding var item: RunningItem
    @State private var hovering = false

    var body: some View {
        HStack(spacing: 12) {
            Toggle("", isOn: $item.selected)
                .toggleStyle(.checkbox)
                .labelsHidden()
            Image(nsImage: item.icon)
                .resizable()
                .interpolation(.high)
                .frame(width: 30, height: 30)
            Text(item.name)
                .font(.system(size: 14))
                .foregroundStyle(item.selected ? .primary : .secondary)
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            RoundedRectangle(cornerRadius: 8, style: .continuous)
                .fill(hovering ? Color.primary.opacity(0.07) : Color.clear)
        )
        .contentShape(Rectangle())
        .onTapGesture { item.selected.toggle() }
        .onHover { hovering = $0 }
    }
}

struct ContentView: View {
    @StateObject private var model = Model()

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack(spacing: 12) {
                Image(nsImage: NSApp.applicationIconImage)
                    .resizable()
                    .frame(width: 40, height: 40)
                VStack(alignment: .leading, spacing: 2) {
                    Text("Close apps")
                        .font(.system(size: 17, weight: .semibold))
                    Text("\(model.selectedCount) of \(model.items.count) selected")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Toggle("Select all", isOn: Binding(
                    get: { model.allSelected },
                    set: { model.setAll($0) }
                ))
                .toggleStyle(.checkbox)
                .disabled(model.items.isEmpty)
            }
            .padding(.horizontal, 18)
            .padding(.vertical, 14)

            Divider()

            // App list
            if model.items.isEmpty {
                VStack(spacing: 6) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                    Text("No other apps are open")
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                ScrollView {
                    VStack(spacing: 2) {
                        ForEach($model.items) { $item in Row(item: $item) }
                    }
                    .padding(8)
                }
            }

            Divider()

            // Buttons
            HStack(spacing: 10) {
                Button {
                    model.reload()
                } label: {
                    Label("Refresh", systemImage: "arrow.clockwise")
                }
                Spacer()
                Button("Cancel") { NSApp.terminate(nil) }
                    .keyboardShortcut(.cancelAction)
                Button(model.selectedCount == 1 ? "Close 1 app" : "Close \(model.selectedCount) apps") {
                    model.closeSelected()
                    NSApp.terminate(nil)
                }
                .keyboardShortcut(.defaultAction)
                .buttonStyle(.borderedProminent)
                .tint(.red)
                .disabled(model.selectedCount == 0)
            }
            .controlSize(.large)
            .padding(.horizontal, 18)
            .padding(.vertical, 14)
        }
        .frame(width: 400, height: 500)
        .onReceive(NotificationCenter.default.publisher(for: NSApplication.didBecomeActiveNotification)) { _ in
            model.reload()
        }
    }
}

final class AppDelegate: NSObject, NSApplicationDelegate {
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool { true }
    func applicationDidFinishLaunching(_ notification: Notification) {
        NSApp.activate(ignoringOtherApps: true)
    }
}

@main
struct CloseAllApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var delegate

    var body: some Scene {
        Window("CloseAll", id: "main") {
            ContentView()
        }
        .windowResizability(.contentSize)
        .windowStyle(.hiddenTitleBar)
        .defaultPosition(.center)
    }
}
