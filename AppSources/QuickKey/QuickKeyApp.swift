import AppKit
import SwiftUI

@main
@MainActor
enum QuickKeyMain {
    static func main() {
        let application = NSApplication.shared
        let delegate = AppDelegate()
        application.delegate = delegate
        withExtendedLifetime(delegate) {
            application.run()
        }
    }
}

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var window: NSWindow?
    private let hotKeyManager = HotKeyManager()
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private let statusPopover = NSPopover()

    func applicationDidFinishLaunching(_ notification: Notification) {
        // Keep a normal Dock presence so first-time users can always find and
        // reopen the app, while MenuBarExtra still provides quick access.
        NSApp.setActivationPolicy(.regular)
        configureMainMenu()

        let content = ContentView()
            .environmentObject(ShortcutStore.shared)
            .environmentObject(HotKeySettings.shared)
        let window = NSWindow(contentViewController: NSHostingController(rootView: content))
        window.title = "QuickKey"
        window.setContentSize(NSSize(width: 980, height: 640))
        window.minSize = NSSize(width: 780, height: 520)
        window.center()
        window.titlebarAppearsTransparent = true
        window.titleVisibility = .hidden
        window.styleMask.insert(.fullSizeContentView)
        window.isReleasedWhenClosed = false
        window.collectionBehavior = [.moveToActiveSpace]
        self.window = window

        configureStatusItem()

        DispatchQueue.main.async { [weak self] in
            guard let self else { return }
            self.presentMainWindow()
            if !self.hotKeyManager.register() {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
                    self?.hotKeyManager.register()
                }
            }
        }
    }

    private func configureMainMenu() {
        let mainMenu = NSMenu()

        let appMenuItem = NSMenuItem()
        mainMenu.addItem(appMenuItem)
        let appMenu = NSMenu()
        appMenu.addItem(withTitle: "关于 QuickKey", action: #selector(NSApplication.orderFrontStandardAboutPanel(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "隐藏 QuickKey", action: #selector(NSApplication.hide(_:)), keyEquivalent: "h")
        let hideOthers = appMenu.addItem(withTitle: "隐藏其他应用", action: #selector(NSApplication.hideOtherApplications(_:)), keyEquivalent: "h")
        hideOthers.keyEquivalentModifierMask = [.command, .option]
        appMenu.addItem(withTitle: "全部显示", action: #selector(NSApplication.unhideAllApplications(_:)), keyEquivalent: "")
        appMenu.addItem(.separator())
        appMenu.addItem(withTitle: "退出 QuickKey", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")
        appMenuItem.submenu = appMenu

        let editMenuItem = NSMenuItem()
        mainMenu.addItem(editMenuItem)
        let editMenu = NSMenu(title: "编辑")
        editMenu.addItem(withTitle: "撤销", action: Selector(("undo:")), keyEquivalent: "z")
        let redo = editMenu.addItem(withTitle: "重做", action: Selector(("redo:")), keyEquivalent: "z")
        redo.keyEquivalentModifierMask = [.command, .shift]
        editMenu.addItem(.separator())
        editMenu.addItem(withTitle: "剪切", action: #selector(NSText.cut(_:)), keyEquivalent: "x")
        editMenu.addItem(withTitle: "拷贝", action: #selector(NSText.copy(_:)), keyEquivalent: "c")
        editMenu.addItem(withTitle: "粘贴", action: #selector(NSText.paste(_:)), keyEquivalent: "v")
        editMenu.addItem(withTitle: "全选", action: #selector(NSText.selectAll(_:)), keyEquivalent: "a")
        editMenuItem.submenu = editMenu

        let windowMenuItem = NSMenuItem()
        mainMenu.addItem(windowMenuItem)
        let windowMenu = NSMenu(title: "窗口")
        windowMenu.addItem(withTitle: "关闭窗口", action: #selector(NSWindow.performClose(_:)), keyEquivalent: "w")
        windowMenu.addItem(withTitle: "最小化", action: #selector(NSWindow.performMiniaturize(_:)), keyEquivalent: "m")
        windowMenu.addItem(withTitle: "缩放", action: #selector(NSWindow.performZoom(_:)), keyEquivalent: "")
        windowMenuItem.submenu = windowMenu
        NSApp.windowsMenu = windowMenu

        NSApp.mainMenu = mainMenu
    }

    private func configureStatusItem() {
        statusPopover.behavior = .transient
        statusPopover.contentSize = NSSize(width: 290, height: 220)
        statusPopover.contentViewController = NSHostingController(
            rootView: MenuBarContent()
                .environmentObject(ShortcutStore.shared)
                .environmentObject(HotKeySettings.shared)
        )

        guard let button = statusItem.button else { return }
        button.image = NSImage(systemSymbolName: "command.square.fill", accessibilityDescription: "QuickKey")
        button.target = self
        button.action = #selector(toggleStatusPopover)
        updateStatusItemTooltip()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(updateStatusItemTooltip),
            name: .quickKeyHotKeyChanged,
            object: nil
        )
    }

    @objc private func updateStatusItemTooltip() {
        statusItem.button?.toolTip = "QuickKey · \(HotKeySettings.shared.displayText)"
    }

    @objc private func toggleStatusPopover() {
        guard let button = statusItem.button else { return }
        if statusPopover.isShown {
            statusPopover.performClose(nil)
        } else {
            statusPopover.show(relativeTo: button.bounds, of: button, preferredEdge: .minY)
            statusPopover.contentViewController?.view.window?.makeKey()
        }
    }

    func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
        presentMainWindow()
        return true
    }

    static func showMainWindow() {
        (NSApp.delegate as? AppDelegate)?.presentMainWindow()
    }

    private func presentMainWindow() {
        guard let window else { return }
        NSApp.activate(ignoringOtherApps: true)
        window.centerIfNeeded()
        window.makeKeyAndOrderFront(nil)
        NotificationCenter.default.post(name: .quickKeyFocusSearch, object: nil)
    }
}

private extension NSWindow {
    func centerIfNeeded() {
        if !isVisible { center() }
    }
}

extension Notification.Name {
    static let quickKeyFocusSearch = Notification.Name("QuickKey.focusSearch")
}
