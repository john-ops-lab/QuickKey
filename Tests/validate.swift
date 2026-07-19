import Foundation

@main
struct ShortcutLibraryValidation {
    static func main() {
        checkUniqueIDs()
        checkCoreData()
        checkChineseSearch()
        checkMultiTermSearch()
        checkCategoryCoverage()
        checkKeyboardCoverage()
        print("QuickKey data validation passed (6 checks, \(ShortcutLibrary.items.count) shortcuts)")
    }

    private static func require(_ condition: @autoclosure () -> Bool, _ message: String) {
        guard condition() else {
            FileHandle.standardError.write("Validation failed: \(message)\n".data(using: .utf8)!)
            exit(1)
        }
    }

    private static func checkUniqueIDs() {
        let ids = ShortcutLibrary.items.map(\.id)
        require(Set(ids).count == ids.count, "shortcut IDs must be unique")
    }

    private static func checkCoreData() {
        for item in ShortcutLibrary.items {
            require(!item.title.isEmpty, "\(item.id) has no title")
            require(!item.keys.isEmpty, "\(item.id) has no keys")
            require(item.category != .all && item.category != .favorites, "\(item.id) has a virtual category")
        }
    }

    private static func checkChineseSearch() {
        let results = ShortcutLibrary.items.filter { $0.matches("录屏") }
        require(results.contains { $0.id == "shot-tools" }, "Chinese keyword search did not find screen recording")
    }

    private static func checkMultiTermSearch() {
        let results = ShortcutLibrary.items.filter { $0.matches("访达 隐藏") }
        require(results.map(\.id) == ["finder-hidden"], "multi-term search returned unexpected results")
    }

    private static func checkCategoryCoverage() {
        let covered = Set(ShortcutLibrary.items.map(\.category))
        let expected = Set(ShortcutCategory.allCases.filter { $0 != .all && $0 != .favorites })
        require(covered == expected, "not every browsable category has content")
    }

    private static func checkKeyboardCoverage() {
        let supported = Set(
            Array("ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789").map(String.init)
            + ["⌘", "⌥", "⌃", "⇧", "Space", "Tab", "Esc", "Delete", "Return", "Power"]
            + ["←", "→", "↑", "↓", "`", "-", "=", "[", "]", "\\", ";", "'", ",", ".", "/"]
            + (1...12).map { "F\($0)" }
        )
        let used = Set(ShortcutLibrary.items.flatMap(\.keys))
        let unmapped = used.subtracting(supported)
        require(unmapped.isEmpty, "keyboard preview is missing keys: \(unmapped.sorted())")
    }
}
