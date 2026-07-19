import AppKit
import Combine
import KeyboardShortcuts

extension KeyboardShortcuts.Name {
    static let quickKeyLauncher = Self(
        "quickKeyLauncher",
        default: .init(.k, modifiers: [.control, .shift])
    )
}

final class HotKeySettings: ObservableObject {
    static let shared = HotKeySettings()

    @Published private(set) var shortcut: KeyboardShortcuts.Shortcut?

    private init() {
        shortcut = KeyboardShortcuts.getShortcut(for: .quickKeyLauncher)
    }

    var displayKeys: [String] {
        guard let shortcut else { return [] }
        var keys: [String] = []
        if shortcut.modifiers.contains(.control) { keys.append("⌃") }
        if shortcut.modifiers.contains(.option) { keys.append("⌥") }
        if shortcut.modifiers.contains(.shift) { keys.append("⇧") }
        if shortcut.modifiers.contains(.command) { keys.append("⌘") }
        if let key = shortcut.key, let label = Self.keyLabels[key] { keys.append(label) }
        return keys
    }

    var displayText: String {
        displayKeys.isEmpty ? "未设置" : displayKeys.joined(separator: " ")
    }

    func update(_ shortcut: KeyboardShortcuts.Shortcut?) {
        self.shortcut = shortcut
        NotificationCenter.default.post(name: .quickKeyHotKeyChanged, object: nil)
    }

    func restoreDefault() {
        let shortcut = KeyboardShortcuts.Shortcut(.k, modifiers: [.control, .shift])
        KeyboardShortcuts.setShortcut(shortcut, for: .quickKeyLauncher)
        update(shortcut)
    }

    private static let keyLabels: [KeyboardShortcuts.Key: String] = [
        .a: "A", .b: "B", .c: "C", .d: "D", .e: "E", .f: "F", .g: "G",
        .h: "H", .i: "I", .j: "J", .k: "K", .l: "L", .m: "M", .n: "N",
        .o: "O", .p: "P", .q: "Q", .r: "R", .s: "S", .t: "T", .u: "U",
        .v: "V", .w: "W", .x: "X", .y: "Y", .z: "Z",
        .zero: "0", .one: "1", .two: "2", .three: "3", .four: "4",
        .five: "5", .six: "6", .seven: "7", .eight: "8", .nine: "9",
        .space: "Space", .tab: "Tab", .return: "Return", .delete: "Delete",
        .escape: "Esc", .backtick: "`", .minus: "-", .equal: "=",
        .leftBracket: "[", .rightBracket: "]", .backslash: "\\", .semicolon: ";",
        .quote: "'", .comma: ",", .period: ".", .slash: "/",
        .leftArrow: "←", .rightArrow: "→", .upArrow: "↑", .downArrow: "↓",
        .f1: "F1", .f2: "F2", .f3: "F3", .f4: "F4", .f5: "F5", .f6: "F6",
        .f7: "F7", .f8: "F8", .f9: "F9", .f10: "F10", .f11: "F11", .f12: "F12"
    ]
}

extension Notification.Name {
    static let quickKeyHotKeyChanged = Notification.Name("QuickKey.hotKeyChanged")
}

final class HotKeyManager {
    private var registered = false

    @discardableResult
    func register() -> Bool {
        guard !registered else { return true }

        KeyboardShortcuts.onKeyDown(for: .quickKeyLauncher) {
            DispatchQueue.main.async { AppDelegate.showMainWindow() }
        }
        registered = true
        return true
    }
}
