//
//  AppDelegate.swift
//  p2pClipboard
//
//  Created by Gnattu OC on 1/20/24.
//

import AppKit
import Cocoa
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate {
    private let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
    private var coreRunningStatusMenuItem = NSMenuItem(title: "Starting...", action: nil, keyEquivalent: "")
    private var statusIcon = NSImage(named: "StatusBarButtonImage")!;
    private var windowController = NSWindowController(window: nil)
    private var alertWindowController = NSWindowController(window: nil)
    private let logFileURL = URL(fileURLWithPath: "/private/tmp/net.gnattu.p2pClipboard.log")
    private var p2pClipboardCoreProcess = Process()
    private var userNotificationGranted = false
    private var isAppQuiting = false
    
    func applicationDidFinishLaunching(_: Notification) {
        DispatchQueue.main.async {
            let center = UNUserNotificationCenter.current()
            center.requestAuthorization(options: [.alert], completionHandler: self.handleUserNotificationAuthorization)
        }
        statusIcon.isTemplate = true
        statusItem.button?.image = getDimmedStatusIcon()
        // Development note: comment out next line to prevent starting too many processes, especially during SwiftUI previewing
        startP2pClipboardCore()
        createStatusBarMenu()
    }
    
    func applicationWillTerminate(_: Notification) {
        isAppQuiting = true
        p2pClipboardCoreProcess.terminate()
        p2pClipboardCoreProcess.waitUntilExit()
    }
    
    func menuWillOpen(_ menu: NSMenu) {
        let title = p2pClipboardCoreProcess.isRunning ? "Running" : "Stopped"
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.controlContentFont(ofSize: 12)]
        let attributedTitle = NSAttributedString(string: title, attributes: attributes)
        DispatchQueue.main.async {
            self.coreRunningStatusMenuItem.attributedTitle = attributedTitle;
        }
    }
    
    private func startP2pClipboardCore() {
        let defaults = UserDefaults.standard
        let useConnect = defaults.object(forKey:"UseConnect") as? Bool ?? false
        let setListen = defaults.object(forKey:"SetListen") as? Bool ?? false
        let setPrivateKey = defaults.object(forKey:"SetPrivateKey") as? Bool ?? false
        let disableMdns = defaults.object(forKey:"DisableMdns") as? Bool ?? false
        let setPsk = defaults.object(forKey:"SetPSK") as? Bool ?? false
        let connectIp = defaults.object(forKey:"ConnectIP") as? String ?? ""
        let connectPort = defaults.object(forKey:"ConnectPort") as? String ?? ""
        let connectPeerId = defaults.object(forKey:"ConnectPeerID") as? String ?? ""
        let listenIp = defaults.object(forKey:"ListenIP") as? String ?? ""
        let listenPort = defaults.object(forKey:"ListenPort") as? String ?? ""
        let privateKeyPath = defaults.object(forKey:"PrivateKeyPath") as? String ?? ""
        
        let p2pClipboardCorePath = Bundle.main.path(forAuxiliaryExecutable: "p2p-clipboard")
        
        guard let p2pClipboardCorePath = p2pClipboardCorePath else {
            present(alert: "Cannot locate p2p-clipboard core binary.", title: nil)
            return
        }
        
        var args = [String]()
        
        if (useConnect) {
            args.append("-c")
            args.append(String(format: "%@:%@", connectIp, connectPort))
            args.append(connectPeerId)
        }
        if (setListen) {
            args.append("-l")
            args.append(String(format: "%@:%@", listenIp, listenPort))
        }
        if (setPrivateKey) {
            args.append("-k")
            args.append(privateKeyPath)
        }
        if (setPsk) {
            let psk = KeychainWrapper.standard.string(forKey: "PSK", withAccessibility: KeychainItemAccessibility.whenUnlocked) ?? ""
            if (!psk.isEmpty) {
                args.append("-p")
                args.append(psk)
            }
        }
        if (disableMdns) {
            args.append("--no-mdns")
        }
        
        let logPipe = Pipe()
        FileManager.default.createFile(atPath: logFileURL.path, contents: nil, attributes: nil)
        let logFileHandle = FileHandle(forWritingAtPath: logFileURL.path)
        let pipeReadHandle = logPipe.fileHandleForReading
        pipeReadHandle.readabilityHandler = { pipeHandle in
            let data = pipeHandle.availableData
            logFileHandle?.write(data)
        }
        
        p2pClipboardCoreProcess.launchPath = p2pClipboardCorePath
        p2pClipboardCoreProcess.arguments = args
        NotificationCenter.default.addObserver(self, selector: #selector(taskDidTerminate(_:)), name: Process.didTerminateNotification, object: p2pClipboardCoreProcess)
        p2pClipboardCoreProcess.standardOutput = logPipe
        p2pClipboardCoreProcess.standardError = logPipe
        
        
        do {
            try p2pClipboardCoreProcess.run()
        } catch {
            present(alert: "Unable to start p2p-clipboard core", title: nil)
        }
        DispatchQueue.main.async {
            if self.p2pClipboardCoreProcess.isRunning {
                self.statusItem.button?.image = self.statusIcon
            }
        }
    }
    
    private func createStatusBarMenu() {
        let menu = NSMenu()
        let statusLabelmenuItem = NSMenuItem()
        let attributes: [NSAttributedString.Key: Any] = [.font: NSFont.systemFont(ofSize: 12, weight: NSFont.Weight.semibold)]
        let attributedTitle = NSAttributedString(string: "p2pClipboard Status:", attributes: attributes)
        statusLabelmenuItem.attributedTitle = attributedTitle
        menu.addItem(statusLabelmenuItem)
        menu.addItem(coreRunningStatusMenuItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Show Logs...", action: #selector(showLogs), keyEquivalent: "")
        menu.addItem(withTitle: "Settings...", action: #selector(openSettings), keyEquivalent: "")
        menu.addItem(NSMenuItem.separator())
        menu.addItem(withTitle: "Restart", action: #selector(restart), keyEquivalent: "")
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: ""))
        
        menu.delegate = self
        statusItem.menu = menu
    }
    
    private func handleUserNotificationAuthorization(granted: Bool, err: Error?) {
        userNotificationGranted = granted
    }
    
    private func getDimmedStatusIcon() -> NSImage {
        return dimImage(statusIcon, alpha: 0.5)
    }
    
    private func dimImage(_ image: NSImage, alpha: CGFloat) -> NSImage {
        let newImage = NSImage(size: image.size)
        newImage.lockFocus()
        
        let imageRect = NSRect(origin: .zero, size: image.size)
        image.draw(in: imageRect, from: imageRect, operation: .sourceOver, fraction: alpha)
        
        newImage.unlockFocus()
        newImage.isTemplate = true
        return newImage
    }
    
    private func present(alert: String, title: String?) {
        if isAppQuiting { return } // Don't present anything if main Application is quitting
        if userNotificationGranted {
            let content = UNMutableNotificationContent()
            content.title = title ?? "p2pClipboard Alert"
            content.body = alert
            let center = UNUserNotificationCenter.current()
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            center.add(request)
        } else {
            let alertWindow = AlertWindow(text: alert)
            alertWindowController.window = alertWindow
            alertWindowController.showWindow(self)
        }
    }
    
    @objc private func restart() {
        ActionManager.restart()
    }
    
    @objc private func showLogs() {
        ActionManager.showlog(logUrl: logFileURL)
    }
    
    @objc private func openSettings() {
        let window = SettingsWindow()
        window.center()
        windowController.window = window
        windowController.showWindow(self)
    }
    
    @objc func taskDidTerminate(_ notification: Notification) {
        guard let task = notification.object as? Process else {
            return
        }
        
        let terminationStatus = task.terminationStatus
        handleTerminationStatus(terminationStatus)
    }
    
    func handleTerminationStatus(_ status: Int32) {
        DispatchQueue.main.async {
            self.statusItem.button?.image = self.getDimmedStatusIcon()
        }
        if status != 0 {
            present(alert: "p2p-clipboard core process failed with status \(status).", title: "p2pClipboard Core Stopped")
        }
    }
}
