//
//  UpGoodApp.swift
//  UpGood
//

import IdentifiedCollections
import Sharing
import SwiftUI

@main
struct UpGoodApp: App {
    @NSApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        // Menu-bar-only app — no windows
        Settings { EmptyView() }
    }
}

// MARK: - App Delegate

@MainActor
final class AppDelegate: NSObject, NSApplicationDelegate {
    private var statusItem: NSStatusItem!
    private let uploader = Uploader()
    private var refreshTimer: Timer?

    func applicationDidFinishLaunching(_ notification: Notification) {
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)

        if let button = statusItem.button {
            button.image = NSImage(systemSymbolName: "icloud.and.arrow.up", accessibilityDescription: "UpGood")
            let dropView = DropReceivingView(frame: button.bounds) { [weak self] urls in
                self?.uploader.upload(urls)
            }
            dropView.autoresizingMask = [.width, .height]
            button.addSubview(dropView)
        }

        rebuildMenu()
        NSApp.servicesProvider = self

        refreshTimer = Timer.scheduledTimer(withTimeInterval: 0.5, repeats: true) { [weak self] _ in
            Task { @MainActor in
                self?.rebuildMenu()
                self?.updateIcon()
            }
        }
    }

    // MARK: - Icon

    private func updateIcon() {
        let uploading = uploader.items.filter { $0.state == .uploading }

        if !uploading.isEmpty {
            let totalProgress = uploading.reduce(0.0) { $0 + $1.progress } / Double(uploading.count)
            statusItem.button?.image = NSImage(systemSymbolName: "icloud.and.arrow.up.fill", accessibilityDescription: "Uploading")
            statusItem.button?.title = " \(Int(totalProgress * 100))%"
            statusItem.length = NSStatusItem.variableLength
        } else {
            statusItem.button?.title = ""
            statusItem.length = NSStatusItem.squareLength
            let symbol: String
            if uploader.items.contains(where: { $0.state == .failed }) {
                symbol = "exclamationmark.icloud.fill"
            } else if uploader.items.contains(where: { $0.state == .completed }) {
                symbol = "checkmark.icloud.fill"
            } else {
                symbol = "icloud.and.arrow.up"
            }
            statusItem.button?.image = NSImage(systemSymbolName: symbol, accessibilityDescription: "UpGood")
        }
    }

    // MARK: - Menu

    private func rebuildMenu() {
        let menu = NSMenu()

        // In-flight
        let uploading = uploader.items.filter { $0.state == .uploading }
        for item in uploading {
            let mi = NSMenuItem(title: "\(truncate(item.fileName)) — \(Int(item.progress * 100))%", action: nil, keyEquivalent: "")
            mi.isEnabled = false
            menu.addItem(mi)
        }

        // Failed
        let failed = uploader.items.filter { $0.state == .failed }
        for item in failed {
            let mi = NSMenuItem(title: "\(truncate(item.fileName)) — \(item.errorMessage ?? "Failed")", action: nil, keyEquivalent: "")
            mi.isEnabled = false
            menu.addItem(mi)
        }

        if !uploading.isEmpty || !failed.isEmpty { menu.addItem(.separator()) }

        // Recent 3 (top-level with submenus)
        @Shared(.uploadHistory) var history
        let allRecords = history.filter { !$0.isExpired }
        let recent = Array(allRecords.prefix(3))

        for record in recent {
            menu.addItem(menuItem(for: record))
        }

        // History submenu for older items
        let older = Array(allRecords.dropFirst(3))
        if !older.isEmpty {
            let historyItem = NSMenuItem(title: "History", action: nil, keyEquivalent: "")
            let sub = NSMenu()
            for record in older.prefix(20) {
                sub.addItem(menuItem(for: record))
            }
            historyItem.submenu = sub
            menu.addItem(historyItem)
        }

        if !allRecords.isEmpty { menu.addItem(.separator()) }

        // Mode toggle
        let modeTitle = uploader.mode == .temporary ? "Mode: Temporary" : "Mode: Permanent"
        let modeItem = NSMenuItem(title: modeTitle, action: #selector(toggleMode), keyEquivalent: "m")
        modeItem.target = self
        menu.addItem(modeItem)

        // Expiry submenu
        if uploader.mode == .temporary {
            let expiryItem = NSMenuItem(title: "Expires: \(uploader.expiry.label)", action: nil, keyEquivalent: "")
            let sub = NSMenu()
            for option in ExpiryOption.allCases {
                let mi = NSMenuItem(title: option.label, action: #selector(setExpiry(_:)), keyEquivalent: "")
                mi.target = self
                mi.representedObject = option.rawValue
                if option == uploader.expiry { mi.state = .on }
                sub.addItem(mi)
            }
            expiryItem.submenu = sub
            menu.addItem(expiryItem)
        }

        menu.addItem(.separator())

        menu.addItem(withTitle: "Upload File...", action: #selector(uploadFile), keyEquivalent: "u").target = self

        if !allRecords.isEmpty {
            menu.addItem(withTitle: "Delete All History...", action: #selector(deleteAllHistory), keyEquivalent: "").target = self
        }

        menu.addItem(.separator())
        menu.addItem(withTitle: "Quit UpGood", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q")

        statusItem.menu = menu
    }

    /// Creates a menu item for a history record with Copy/Open/Delete submenu
    private func menuItem(for record: UploadRecord) -> NSMenuItem {
        let item = NSMenuItem(title: "", action: nil, keyEquivalent: "")

        let title = NSMutableAttributedString(
            string: truncate(record.fileName),
            attributes: [.font: NSFont.menuFont(ofSize: 0)]
        )
        title.append(NSAttributedString(
            string: "  \(expiryLabel(record))",
            attributes: [
                .font: NSFont.menuFont(ofSize: NSFont.smallSystemFontSize),
                .foregroundColor: NSColor.secondaryLabelColor,
            ]
        ))
        item.attributedTitle = title

        let sub = NSMenu()

        let copyItem = NSMenuItem(title: "Copy URL", action: #selector(copyURL(_:)), keyEquivalent: "c")
        copyItem.target = self
        copyItem.representedObject = record.url
        sub.addItem(copyItem)

        let openItem = NSMenuItem(title: "Open in Browser", action: #selector(openURL(_:)), keyEquivalent: "o")
        openItem.target = self
        openItem.representedObject = record.url
        sub.addItem(openItem)

        sub.addItem(.separator())

        let deleteItem = NSMenuItem(title: "Delete", action: #selector(deleteSingleRecord(_:)), keyEquivalent: "\u{8}") // backspace
        deleteItem.target = self
        deleteItem.representedObject = record.id.uuidString
        sub.addItem(deleteItem)

        item.submenu = sub
        return item
    }

    // MARK: - Actions

    @objc private func copyURL(_ sender: NSMenuItem) {
        guard let url = sender.representedObject as? String else { return }
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(url, forType: .string)
    }

    @objc private func openURL(_ sender: NSMenuItem) {
        guard let urlString = sender.representedObject as? String,
              let url = URL(string: urlString) else { return }
        NSWorkspace.shared.open(url)
    }

    @objc private func deleteSingleRecord(_ sender: NSMenuItem) {
        guard let idString = sender.representedObject as? String,
              let id = UUID(uuidString: idString) else { return }
        @Shared(.uploadHistory) var history
        $history.withLock { $0.remove(id: id) }
        rebuildMenu()
    }

    @objc private func toggleMode() {
        uploader.mode = uploader.mode == .temporary ? .permanent : .temporary
        rebuildMenu()
        updateIcon()
        reopenMenu()
    }

    @objc private func setExpiry(_ sender: NSMenuItem) {
        guard let raw = sender.representedObject as? String,
              let option = ExpiryOption(rawValue: raw) else { return }
        uploader.expiry = option
        rebuildMenu()
        reopenMenu()
    }

    private func reopenMenu() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) { [weak self] in
            self?.statusItem.button?.performClick(nil)
        }
    }

    @objc private func uploadFile() {
        NSApp.activate(ignoringOtherApps: true)
        let panel = NSOpenPanel()
        panel.canChooseFiles = true
        panel.canChooseDirectories = false
        panel.allowsMultipleSelection = true
        guard panel.runModal() == .OK else { return }
        uploader.upload(panel.urls)
    }

    @objc private func deleteAllHistory() {
        NSApp.activate(ignoringOtherApps: true)
        let alert = NSAlert()
        alert.messageText = "Delete All History?"
        alert.informativeText = "This will remove all upload records from UpGood. Uploaded files on Catbox/Litterbox will remain on the server — anonymous uploads cannot be deleted remotely."
        alert.alertStyle = .warning
        alert.addButton(withTitle: "Delete All")
        alert.addButton(withTitle: "Cancel")

        guard alert.runModal() == .alertFirstButtonReturn else { return }

        @Shared(.uploadHistory) var history
        $history.withLock { $0.removeAll() }
        uploader.items.removeAll()
        rebuildMenu()
        updateIcon()
    }

    // MARK: - Services (Finder context menu)

    @objc func uploadToCatbox(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let urls = pboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty else { return }
        let savedMode = uploader.mode
        uploader.mode = .permanent
        uploader.upload(urls)
        uploader.mode = savedMode
    }

    @objc func uploadToLitterbox(_ pboard: NSPasteboard, userData: String, error: AutoreleasingUnsafeMutablePointer<NSString>) {
        guard let urls = pboard.readObjects(forClasses: [NSURL.self]) as? [URL], !urls.isEmpty else { return }
        let savedMode = uploader.mode
        uploader.mode = .temporary
        uploader.upload(urls)
        uploader.mode = savedMode
    }

    // MARK: - Helpers

    private func truncate(_ name: String, maxLength: Int = 18) -> String {
        guard name.count > maxLength else { return name }
        let half = (maxLength - 1) / 2
        return "\(name.prefix(half))…\(name.suffix(half))"
    }

    private func expiryLabel(_ record: UploadRecord) -> String {
        if let expiresAt = record.expiresAt {
            let formatter = RelativeDateTimeFormatter()
            formatter.unitsStyle = .abbreviated
            return formatter.localizedString(for: expiresAt, relativeTo: Date())
        }
        return "permanent"
    }
}

// MARK: - Drop Receiving View

private class DropReceivingView: NSView {
    let onDrop: ([URL]) -> Void

    init(frame: NSRect, onDrop: @escaping ([URL]) -> Void) {
        self.onDrop = onDrop
        super.init(frame: frame)
        registerForDraggedTypes([.fileURL])
    }

    @available(*, unavailable)
    required init?(coder: NSCoder) { fatalError() }

    override func draggingEntered(_ sender: NSDraggingInfo) -> NSDragOperation { .copy }

    override func performDragOperation(_ sender: NSDraggingInfo) -> Bool {
        guard let urls = sender.draggingPasteboard.readObjects(forClasses: [NSURL.self]) as? [URL],
              !urls.isEmpty else { return false }
        onDrop(urls)
        return true
    }
}
