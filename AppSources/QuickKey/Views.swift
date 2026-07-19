import AppKit
import KeyboardShortcuts
import SwiftUI

struct ContentView: View {
    @EnvironmentObject private var store: ShortcutStore
    @EnvironmentObject private var hotKeySettings: HotKeySettings
    @FocusState private var searchFocused: Bool
    @State private var copiedID: String?
    @State private var selectedID: String?
    @State private var showingHotKeySettings = false

    private var selectedItem: ShortcutItem? {
        store.filteredItems.first { $0.id == selectedID }
    }

    var body: some View {
        HStack(spacing: 0) {
            sidebar
            mainContent
        }
        .background(Color(nsColor: .windowBackgroundColor))
        .onReceive(NotificationCenter.default.publisher(for: .quickKeyFocusSearch)) { _ in
            searchFocused = true
        }
        .onChange(of: store.selectedCategory) { _ in selectedID = nil }
        .onChange(of: store.query) { _ in selectedID = nil }
        .sheet(isPresented: $showingHotKeySettings) {
            HotKeySettingsView()
                .environmentObject(hotKeySettings)
        }
        .frame(minWidth: 780, minHeight: 520)
    }

    private var sidebar: some View {
        VStack(alignment: .leading, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "command.square.fill")
                    .font(.system(size: 25, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                VStack(alignment: .leading, spacing: 2) {
                    Text("QuickKey").font(.headline)
                    Text("快捷键随手查").font(.caption).foregroundStyle(.secondary)
                }
            }
            .padding(.horizontal, 18)
            .padding(.top, 22)
            .padding(.bottom, 20)

            Text("分类")
                .font(.caption.weight(.semibold))
                .foregroundStyle(.secondary)
                .padding(.horizontal, 20)
                .padding(.bottom, 7)

            ForEach(ShortcutCategory.allCases) { category in
                Button {
                    store.selectedCategory = category
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: category.icon)
                            .frame(width: 18)
                        Text(category.rawValue)
                        Spacer()
                        if category == .favorites && !store.favorites.isEmpty {
                            Text("\(store.favorites.count)")
                                .font(.caption2.weight(.bold))
                                .foregroundStyle(.secondary)
                        }
                    }
                    .padding(.horizontal, 11)
                    .frame(height: 36)
                    .contentShape(Rectangle())
                }
                .buttonStyle(SidebarButtonStyle(selected: store.selectedCategory == category))
                .padding(.horizontal, 9)
            }

            Spacer()

            Button {
                showingHotKeySettings = true
            } label: {
                HStack(spacing: 9) {
                    Image(systemName: "keyboard.badge.ellipsis")
                        .frame(width: 18)
                    Text("呼出键设置")
                    Spacer()
                    Image(systemName: "chevron.right")
                        .font(.caption2.weight(.bold))
                        .foregroundStyle(.tertiary)
                }
                .padding(.horizontal, 11)
                .frame(height: 36)
                .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.horizontal, 9)
            .padding(.bottom, 8)

            VStack(alignment: .leading, spacing: 5) {
                Text("快速呼出")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                HStack(spacing: 5) {
                    if hotKeySettings.displayKeys.isEmpty {
                        Text("未设置")
                            .font(.caption.weight(.medium))
                            .foregroundStyle(.secondary)
                    } else {
                        ForEach(hotKeySettings.displayKeys, id: \.self) { key in
                            KeyCap(text: key, compact: true)
                        }
                    }
                }
            }
            .padding(18)
        }
        .frame(width: 210)
        .background(.regularMaterial)
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            header
            Divider().opacity(0.5)
            if store.filteredItems.isEmpty {
                emptyState
            } else {
                ScrollView {
                    LazyVStack(spacing: 10) {
                        ForEach(store.filteredItems) { item in
                            ShortcutRow(
                                item: item,
                                selected: selectedItem?.id == item.id,
                                isFavorite: store.isFavorite(item),
                                copied: copiedID == item.id,
                                onSelect: { selectedID = selectedID == item.id ? nil : item.id },
                                onFavorite: { store.toggleFavorite(item) },
                                onCopy: { copy(item) }
                            )
                        }
                    }
                    .padding(22)
                }
                .scrollIndicators(.hidden)

                if let selectedItem {
                    Divider().opacity(0.55)
                    KeyboardPreview(item: selectedItem)
                        .id(selectedItem.id)
                        .transition(.opacity)
                }
            }
        }
        .background(
            LinearGradient(
                colors: [Color(nsColor: .windowBackgroundColor), Color.indigo.opacity(0.035)],
                startPoint: .top,
                endPoint: .bottom
            )
        )
    }

    private var header: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 3) {
                Text(store.selectedCategory.rawValue)
                    .font(.title2.weight(.bold))
                Text("找到 \(store.filteredItems.count) 个快捷键")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Spacer()
            HStack(spacing: 8) {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("搜索操作、应用或按键…", text: $store.query)
                    .textFieldStyle(.plain)
                    .focused($searchFocused)
                    .onExitCommand { store.query = "" }
                if !store.query.isEmpty {
                    Button { store.query = "" } label: {
                        Image(systemName: "xmark.circle.fill").foregroundStyle(.tertiary)
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 13)
            .frame(width: 330, height: 40)
            .background(.quaternary.opacity(0.7), in: RoundedRectangle(cornerRadius: 11, style: .continuous))
        }
        .padding(.horizontal, 22)
        .padding(.top, 24)
        .padding(.bottom, 18)
    }

    private var emptyState: some View {
        VStack(spacing: 10) {
            Spacer()
            Image(systemName: store.selectedCategory == .favorites ? "star" : "magnifyingglass")
                .font(.system(size: 32, weight: .light))
                .foregroundStyle(.secondary)
            Text(store.selectedCategory == .favorites ? "还没有收藏" : "没有找到相关快捷键")
                .font(.headline)
            Text(store.selectedCategory == .favorites ? "点一下快捷键右侧的星标即可收藏" : "换个关键词试试，比如「截图」或「窗口」")
                .font(.subheadline)
                .foregroundStyle(.secondary)
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func copy(_ item: ShortcutItem) {
        store.copy(item)
        withAnimation(.easeOut(duration: 0.18)) { copiedID = item.id }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.25) {
            if copiedID == item.id { copiedID = nil }
        }
    }
}

private struct ShortcutRow: View {
    let item: ShortcutItem
    let selected: Bool
    let isFavorite: Bool
    let copied: Bool
    let onSelect: () -> Void
    let onFavorite: () -> Void
    let onCopy: () -> Void

    @State private var hovering = false

    var body: some View {
        HStack(spacing: 15) {
            Image(systemName: item.category.icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundStyle(.indigo)
                .frame(width: 36, height: 36)
                .background(Color.indigo.opacity(0.09), in: RoundedRectangle(cornerRadius: 10, style: .continuous))

            VStack(alignment: .leading, spacing: 4) {
                Text(item.title)
                    .font(.system(size: 15, weight: .semibold))
                if !item.detail.isEmpty {
                    Text(item.detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
            }
            Spacer(minLength: 14)
            HStack(spacing: 6) {
                ForEach(Array(item.keys.enumerated()), id: \.offset) { _, key in
                    KeyCap(text: key)
                }
            }
            .onTapGesture(perform: onCopy)
            .help("点击复制快捷键")

            Button(action: onCopy) {
                Image(systemName: copied ? "checkmark" : "doc.on.doc")
                    .foregroundStyle(copied ? .green : .secondary)
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .help(copied ? "已复制" : "复制")

            Button(action: onFavorite) {
                Image(systemName: isFavorite ? "star.fill" : "star")
                    .foregroundStyle(isFavorite ? .yellow : .secondary)
                    .frame(width: 26, height: 26)
            }
            .buttonStyle(.plain)
            .help(isFavorite ? "取消收藏" : "收藏")
        }
        .padding(.horizontal, 15)
        .frame(minHeight: 68)
        .background(
            selected ? Color.accentColor.opacity(0.10) : (hovering ? Color.primary.opacity(0.055) : Color.primary.opacity(0.025)),
            in: RoundedRectangle(cornerRadius: 14, style: .continuous)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(selected ? Color.accentColor.opacity(0.45) : Color.primary.opacity(hovering ? 0.09 : 0.055), lineWidth: 1)
        )
        .contentShape(Rectangle())
        .onTapGesture(perform: onSelect)
        .onHover { hovering = $0 }
        .animation(.easeOut(duration: 0.12), value: hovering)
        .animation(.easeOut(duration: 0.16), value: selected)
    }
}

struct KeyCap: View {
    let text: String
    var compact = false

    var body: some View {
        Text(text)
            .font(.system(size: compact ? 10 : 12, weight: .semibold, design: .rounded))
            .foregroundStyle(.primary.opacity(0.82))
            .padding(.horizontal, compact ? 6 : (text.count > 2 ? 9 : 7))
            .frame(height: compact ? 23 : 29)
            .background(Color(nsColor: .controlBackgroundColor), in: RoundedRectangle(cornerRadius: compact ? 5 : 7, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: compact ? 5 : 7, style: .continuous)
                    .stroke(Color.primary.opacity(0.12), lineWidth: 1)
            )
            .shadow(color: .black.opacity(0.07), radius: 0, y: 1)
    }
}

private struct SidebarButtonStyle: ButtonStyle {
    let selected: Bool

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .foregroundStyle(selected ? Color.accentColor : Color.primary.opacity(0.82))
            .background(
                selected ? Color.accentColor.opacity(0.13) : Color.clear,
                in: RoundedRectangle(cornerRadius: 9, style: .continuous)
            )
            .contentShape(Rectangle())
            .opacity(configuration.isPressed ? 0.7 : 1)
    }
}

private struct HotKeySettingsView: View {
    @EnvironmentObject private var hotKeySettings: HotKeySettings
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                Image(systemName: "keyboard.badge.ellipsis")
                    .font(.system(size: 21, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 42, height: 42)
                    .background(
                        LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing),
                        in: RoundedRectangle(cornerRadius: 12, style: .continuous)
                    )
                VStack(alignment: .leading, spacing: 3) {
                    Text("快速呼出设置")
                        .font(.title2.weight(.bold))
                    Text("点击录制框，再按下新的组合键")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
                Spacer()
                Button("完成") { dismiss() }
                    .keyboardShortcut(.defaultAction)
            }
            .padding(22)

            Divider()

            VStack(spacing: 16) {
                HStack(spacing: 14) {
                    KeyboardShortcuts.Recorder(
                        "快速呼出",
                        name: .quickKeyLauncher,
                        onChange: { shortcut in
                            DispatchQueue.main.async {
                                hotKeySettings.update(shortcut)
                            }
                        }
                    )
                    Spacer()
                    Label("冲突组合键不会保存", systemImage: "checkmark.shield.fill")
                        .font(.caption.weight(.medium))
                        .foregroundStyle(.green)
                    Button("恢复默认") { hotKeySettings.restoreDefault() }
                }
                .padding(14)
                .background(Color.primary.opacity(0.035), in: RoundedRectangle(cornerRadius: 12, style: .continuous))

                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("键盘位置")
                            .font(.caption.weight(.semibold))
                            .foregroundStyle(.secondary)
                        Text(hotKeySettings.displayText)
                            .font(.headline)
                    }
                    Spacer()
                    if hotKeySettings.displayKeys.isEmpty {
                        Text("尚未设置快捷键")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    } else {
                        HStack(spacing: 5) {
                            ForEach(hotKeySettings.displayKeys, id: \.self) { key in
                                KeyCap(text: key, compact: true)
                            }
                        }
                    }
                }

                KeyboardMapView(highlightedKeys: Set(hotKeySettings.displayKeys))
            }
            .padding(22)
        }
        .frame(width: 760, height: 390)
        .background(Color(nsColor: .windowBackgroundColor))
    }
}

private struct KeyboardPreview: View {
    let item: ShortcutItem

    private var highlightedKeys: Set<String> { Set(item.keys) }

    var body: some View {
        VStack(spacing: 9) {
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 2) {
                    Text("键盘位置")
                        .font(.caption.weight(.semibold))
                        .foregroundStyle(.secondary)
                    Text(item.title)
                        .font(.headline)
                }
                Spacer()
                HStack(spacing: 5) {
                    ForEach(Array(item.keys.enumerated()), id: \.offset) { _, key in
                        KeyCap(text: key, compact: true)
                    }
                }
                Text("高亮键位")
                    .font(.caption2)
                    .foregroundStyle(.secondary)
            }

            KeyboardMapView(highlightedKeys: highlightedKeys)
        }
        .padding(.horizontal, 22)
        .padding(.vertical, 12)
        .frame(height: 228)
        .background(.regularMaterial)
    }
}

private struct KeyboardMapView: View {
    let highlightedKeys: Set<String>

    var body: some View {
        VStack(spacing: 4) {
            ForEach(KeyboardLayout.rows) { row in
                KeyboardRow(keys: row.keys, highlightedKeys: highlightedKeys, height: row.height)
            }
        }
        .padding(8)
        .background(Color.black.opacity(0.035), in: RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

private struct KeyboardRow: View {
    let keys: [KeyboardKey]
    let highlightedKeys: Set<String>
    let height: CGFloat

    var body: some View {
        GeometryReader { proxy in
            let spacing: CGFloat = 4
            let totalUnits = keys.reduce(0) { $0 + $1.width }
            let availableWidth = proxy.size.width - CGFloat(max(keys.count - 1, 0)) * spacing
            let unitWidth = max(1, availableWidth / totalUnits)

            HStack(spacing: spacing) {
                ForEach(keys) { key in
                    KeyboardKeyView(
                        key: key,
                        highlighted: key.shortcutKey.map(highlightedKeys.contains) ?? false
                    )
                    .frame(width: unitWidth * key.width, height: height)
                }
            }
        }
        .frame(height: height)
    }
}

private struct KeyboardKeyView: View {
    let key: KeyboardKey
    let highlighted: Bool

    var body: some View {
        Text(key.label)
            .font(.system(size: key.label.count > 4 ? 7 : 9, weight: highlighted ? .bold : .medium, design: .rounded))
            .foregroundStyle(highlighted ? .white : .secondary)
            .lineLimit(1)
            .minimumScaleFactor(0.55)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                highlighted
                    ? AnyShapeStyle(LinearGradient(colors: [.indigo, .purple], startPoint: .topLeading, endPoint: .bottomTrailing))
                    : AnyShapeStyle(Color(nsColor: .controlBackgroundColor)),
                in: RoundedRectangle(cornerRadius: 5, style: .continuous)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 5, style: .continuous)
                    .stroke(highlighted ? Color.white.opacity(0.35) : Color.primary.opacity(0.10), lineWidth: 1)
            )
            .shadow(color: highlighted ? Color.indigo.opacity(0.28) : Color.black.opacity(0.05), radius: highlighted ? 4 : 0, y: 1)
            .animation(.easeOut(duration: 0.18), value: highlighted)
    }
}

private struct KeyboardKey: Identifiable {
    let id: String
    let label: String
    let shortcutKey: String?
    let width: CGFloat

    init(_ id: String, _ label: String, key: String? = nil, width: CGFloat = 1) {
        self.id = id
        self.label = label
        self.shortcutKey = key ?? label
        self.width = width
    }
}

private struct KeyboardLayoutRow: Identifiable {
    let id: String
    let keys: [KeyboardKey]
    let height: CGFloat
}

private enum KeyboardLayout {
    static let rows: [KeyboardLayoutRow] = [
        .init(id: "functions", keys: [
            .init("esc", "esc", key: "Esc", width: 1.25),
            .init("f1", "F1"), .init("f2", "F2"), .init("f3", "F3"), .init("f4", "F4"),
            .init("f5", "F5"), .init("f6", "F6"), .init("f7", "F7"), .init("f8", "F8"),
            .init("f9", "F9"), .init("f10", "F10"), .init("f11", "F11"), .init("f12", "F12"),
            .init("power", "Touch ID", key: "Power", width: 1.55)
        ], height: 20),
        .init(id: "numbers", keys: [
            .init("backtick", "`"), .init("1", "1"), .init("2", "2"), .init("3", "3"), .init("4", "4"),
            .init("5", "5"), .init("6", "6"), .init("7", "7"), .init("8", "8"), .init("9", "9"),
            .init("0", "0"), .init("minus", "-"), .init("equals", "="),
            .init("delete", "delete", key: "Delete", width: 1.8)
        ], height: 24),
        .init(id: "qwerty", keys: [
            .init("tab", "tab", key: "Tab", width: 1.45),
            .init("q", "Q"), .init("w", "W"), .init("e", "E"), .init("r", "R"), .init("t", "T"),
            .init("y", "Y"), .init("u", "U"), .init("i", "I"), .init("o", "O"), .init("p", "P"),
            .init("left-bracket", "["), .init("right-bracket", "]"), .init("backslash", "\\", width: 1.35)
        ], height: 24),
        .init(id: "home", keys: [
            .init("caps", "caps", key: nil, width: 1.7),
            .init("a", "A"), .init("s", "S"), .init("d", "D"), .init("f", "F"), .init("g", "G"),
            .init("h", "H"), .init("j", "J"), .init("k", "K"), .init("l", "L"),
            .init("semicolon", ";"), .init("quote", "'"),
            .init("return", "return", key: "Return", width: 1.9)
        ], height: 24),
        .init(id: "shift", keys: [
            .init("left-shift", "⇧", key: "⇧", width: 2.15),
            .init("z", "Z"), .init("x", "X"), .init("c", "C"), .init("v", "V"), .init("b", "B"),
            .init("n", "N"), .init("m", "M"), .init("comma", ","), .init("period", "."), .init("slash", "/"),
            .init("right-shift", "⇧", key: "⇧", width: 2.45)
        ], height: 24),
        .init(id: "modifiers", keys: [
            .init("fn", "fn", key: nil), .init("control", "⌃", key: "⌃"),
            .init("left-option", "⌥", key: "⌥"), .init("left-command", "⌘", key: "⌘", width: 1.25),
            .init("space", "space", key: "Space", width: 4.7),
            .init("right-command", "⌘", key: "⌘", width: 1.25), .init("right-option", "⌥", key: "⌥"),
            .init("left-arrow", "←"), .init("up-arrow", "↑"), .init("down-arrow", "↓"), .init("right-arrow", "→")
        ], height: 24)
    ]
}

struct MenuBarContent: View {
    @EnvironmentObject private var store: ShortcutStore
    @EnvironmentObject private var hotKeySettings: HotKeySettings

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("QuickKey").font(.headline)
                    Text("快捷键随手查").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                Button { NSApp.terminate(nil) } label: {
                    Image(systemName: "power").foregroundStyle(.secondary)
                }
                .buttonStyle(.plain)
                .help("退出")
            }

            Button {
                AppDelegate.showMainWindow()
            } label: {
                Label("打开快捷键搜索", systemImage: "magnifyingglass")
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 11)
                    .frame(height: 38)
                    .background(Color.accentColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 9))
            }
            .buttonStyle(.plain)

            if !store.favorites.isEmpty {
                Divider()
                Text("收藏").font(.caption.weight(.semibold)).foregroundStyle(.secondary)
                ForEach(store.favorites.prefix(4)) { item in
                    Button { store.copy(item) } label: {
                        HStack {
                            Text(item.title).lineLimit(1)
                            Spacer()
                            Text(item.keyText)
                                .font(.caption.monospaced())
                                .foregroundStyle(.secondary)
                        }
                        .contentShape(Rectangle())
                    }
                    .buttonStyle(.plain)
                }
            }

            Text("\(hotKeySettings.displayText) 快速呼出")
                .font(.caption2)
                .foregroundStyle(.tertiary)
                .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(14)
        .frame(width: 290)
    }
}
