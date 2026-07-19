import Foundation

struct ShortcutItem: Identifiable, Hashable {
    let id: String
    let title: String
    let keys: [String]
    let category: ShortcutCategory
    let detail: String
    let keywords: [String]

    init(_ id: String, _ title: String, _ keys: [String], _ category: ShortcutCategory, _ detail: String = "", _ keywords: [String] = []) {
        self.id = id
        self.title = title
        self.keys = keys
        self.category = category
        self.detail = detail
        self.keywords = keywords
    }

    var keyText: String { keys.joined(separator: " ") }

    func matches(_ query: String) -> Bool {
        guard !query.isEmpty else { return true }
        let haystack = ([title, keyText, category.rawValue, detail] + keywords)
            .joined(separator: " ")
            .lowercased()
        return query.lowercased().split(separator: " ").allSatisfy { haystack.contains($0) }
    }
}

enum ShortcutCategory: String, CaseIterable, Identifiable {
    case all = "全部"
    case favorites = "收藏"
    case system = "系统"
    case finder = "访达"
    case text = "文字编辑"
    case screenshot = "截屏"
    case browser = "浏览器"
    case window = "窗口"
    case accessibility = "辅助功能"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .all: return "square.grid.2x2"
        case .favorites: return "star.fill"
        case .system: return "macbook"
        case .finder: return "folder"
        case .text: return "text.cursor"
        case .screenshot: return "camera.viewfinder"
        case .browser: return "globe"
        case .window: return "macwindow.on.rectangle"
        case .accessibility: return "accessibility"
        }
    }
}

enum ShortcutLibrary {
    static let items: [ShortcutItem] = [
        .init("spotlight", "打开聚焦搜索", ["⌘", "Space"], .system, "快速搜索 App、文件和答案", ["spotlight", "搜索"]),
        .init("app-switch", "切换应用", ["⌘", "Tab"], .system, "按住 ⌘，连续按 Tab 选择", ["程序", "app"]),
        .init("app-switch-back", "反向切换应用", ["⌘", "⇧", "Tab"], .system),
        .init("force-quit", "强制退出应用", ["⌥", "⌘", "Esc"], .system, "打开强制退出窗口", ["卡死", "结束"]),
        .init("lock-screen", "锁定屏幕", ["⌃", "⌘", "Q"], .system, "立即返回登录界面", ["安全", "锁屏"]),
        .init("sleep-display", "关闭显示器", ["⌃", "⇧", "Power"], .system, "外接键盘可使用电源键", ["睡眠"]),
        .init("emoji", "表情与符号", ["⌃", "⌘", "Space"], .system, "打开字符检视器", ["emoji", "颜文字"]),
        .init("settings", "打开当前应用设置", ["⌘", ","], .system, "适用于绝大多数 macOS 应用", ["偏好设置"]),
        .init("hide-app", "隐藏当前应用", ["⌘", "H"], .system),
        .init("hide-others", "隐藏其他应用", ["⌥", "⌘", "H"], .system),
        .init("quit-app", "退出当前应用", ["⌘", "Q"], .system),
        .init("open", "打开所选项目", ["⌘", "O"], .finder),
        .init("new-folder", "新建文件夹", ["⇧", "⌘", "N"], .finder),
        .init("finder-search", "搜索当前文件夹", ["⌘", "F"], .finder),
        .init("finder-info", "显示简介", ["⌘", "I"], .finder, "查看文件大小、权限等信息", ["属性", "详情"]),
        .init("finder-preview", "快速查看", ["Space"], .finder, "无需打开应用即可预览文件", ["预览", "quick look"]),
        .init("finder-rename", "重命名", ["Return"], .finder),
        .init("finder-trash", "移到废纸篓", ["⌘", "Delete"], .finder, "可从废纸篓恢复", ["删除"]),
        .init("finder-empty-trash", "清倒废纸篓", ["⇧", "⌘", "Delete"], .finder, "删除后通常无法恢复", ["永久删除"]),
        .init("finder-duplicate", "制作副本", ["⌘", "D"], .finder, "复制当前选中的文件", ["复制文件"]),
        .init("finder-home", "前往个人文件夹", ["⇧", "⌘", "H"], .finder, "打开用户主目录", ["home", "用户目录"]),
        .init("finder-downloads", "前往下载文件夹", ["⌥", "⌘", "L"], .finder, "打开下载目录", ["download"]),
        .init("finder-desktop", "前往桌面", ["⇧", "⌘", "D"], .finder),
        .init("finder-airdrop", "打开隔空投送", ["⇧", "⌘", "R"], .finder, "在访达中打开 AirDrop", ["airdrop"]),
        .init("finder-path", "前往文件夹", ["⇧", "⌘", "G"], .finder, "输入路径直接跳转", ["路径"]),
        .init("finder-hidden", "显示或隐藏隐藏文件", ["⇧", "⌘", "."], .finder, "在访达窗口中切换", ["隐藏文件"]),
        .init("copy", "拷贝", ["⌘", "C"], .text, "复制所选内容", ["复制"]),
        .init("paste", "粘贴", ["⌘", "V"], .text),
        .init("paste-style", "粘贴并匹配样式", ["⌥", "⇧", "⌘", "V"], .text, "忽略来源格式", ["纯文本", "格式"]),
        .init("cut", "剪切", ["⌘", "X"], .text),
        .init("undo", "撤销", ["⌘", "Z"], .text),
        .init("redo", "重做", ["⇧", "⌘", "Z"], .text),
        .init("select-all", "全选", ["⌘", "A"], .text),
        .init("find", "查找", ["⌘", "F"], .text),
        .init("find-next", "查找下一个", ["⌘", "G"], .text),
        .init("line-start", "移动到行首", ["⌘", "←"], .text),
        .init("line-end", "移动到行尾", ["⌘", "→"], .text),
        .init("doc-start", "移动到文稿开头", ["⌘", "↑"], .text),
        .init("doc-end", "移动到文稿结尾", ["⌘", "↓"], .text),
        .init("delete-word", "删除前一个词", ["⌥", "Delete"], .text),
        .init("select-word", "向左选择一个词", ["⌥", "⇧", "←"], .text),
        .init("shot-area", "截取所选区域", ["⇧", "⌘", "4"], .screenshot, "拖动选择范围；按 Space 可改选窗口", ["截图", "区域"]),
        .init("shot-screen", "截取整个屏幕", ["⇧", "⌘", "3"], .screenshot, "保存到默认截屏位置", ["截图", "全屏"]),
        .init("shot-tools", "打开截屏工具栏", ["⇧", "⌘", "5"], .screenshot, "可截屏或录制屏幕", ["录屏", "录像"]),
        .init("shot-clipboard", "截屏并复制到剪贴板", ["⌃", "⇧", "⌘", "4"], .screenshot, "选择区域后不生成文件", ["截图", "粘贴板"]),
        .init("browser-new-tab", "新建标签页", ["⌘", "T"], .browser),
        .init("browser-close-tab", "关闭当前标签页", ["⌘", "W"], .browser),
        .init("browser-reopen", "恢复关闭的标签页", ["⇧", "⌘", "T"], .browser, "可连续恢复多个标签页", ["撤销关闭"]),
        .init("browser-next", "切换到下一个标签页", ["⌃", "Tab"], .browser),
        .init("browser-previous", "切换到上一个标签页", ["⌃", "⇧", "Tab"], .browser),
        .init("browser-location", "聚焦地址栏", ["⌘", "L"], .browser, "输入网址或搜索内容", ["网址", "url"]),
        .init("browser-reload", "重新载入页面", ["⌘", "R"], .browser, "刷新当前网页", ["刷新"]),
        .init("browser-hard-reload", "忽略缓存重新载入", ["⌥", "⌘", "R"], .browser, "Safari 常用", ["强制刷新", "缓存"]),
        .init("browser-history", "显示浏览历史", ["⌘", "Y"], .browser),
        .init("browser-download", "显示下载项", ["⌥", "⌘", "L"], .browser),
        .init("minimize", "最小化窗口", ["⌘", "M"], .window),
        .init("close-window", "关闭窗口", ["⌘", "W"], .window, "通常不会退出应用", ["关闭"]),
        .init("close-all", "关闭应用的所有窗口", ["⌥", "⌘", "W"], .window),
        .init("cycle-window", "切换同一应用的窗口", ["⌘", "`"], .window, "在当前应用的多个窗口间切换", ["窗口切换"]),
        .init("fullscreen", "进入或退出全屏幕", ["⌃", "⌘", "F"], .window, "适用于支持全屏的应用", ["全屏"]),
        .init("mission-control", "调度中心", ["⌃", "↑"], .window, "查看所有窗口和桌面", ["mission control"]),
        .init("app-expose", "应用窗口总览", ["⌃", "↓"], .window, "查看当前应用的所有窗口", ["app expose"]),
        .init("desktop-left", "切换到左侧桌面", ["⌃", "←"], .window, "需要有多个桌面空间", ["空间"]),
        .init("desktop-right", "切换到右侧桌面", ["⌃", "→"], .window, "需要有多个桌面空间", ["空间"]),
        .init("voiceover", "开启或关闭旁白", ["⌘", "F5"], .accessibility, "部分键盘需同时按 Fn", ["voiceover"]),
        .init("zoom-in", "辅助缩放放大", ["⌥", "⌘", "="], .accessibility, "需先在辅助功能中开启缩放", ["放大"]),
        .init("zoom-out", "辅助缩放缩小", ["⌥", "⌘", "-"], .accessibility, "需先在辅助功能中开启缩放", ["缩小"]),
        .init("invert", "反转屏幕颜色", ["⌃", "⌥", "⌘", "8"], .accessibility, "需先在辅助功能中开启相应快捷键", ["颜色反转"]),
        .init("accessibility-panel", "辅助功能快捷键面板", ["⌥", "⌘", "F5"], .accessibility, "部分键盘需同时按 Fn", ["面板"])
    ]
}
