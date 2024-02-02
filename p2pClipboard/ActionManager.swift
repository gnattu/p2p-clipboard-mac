//
//  ActionManager.swift
//  p2pClipboard
//
//  Created by Gnattu OC on 1/20/24.
//

import AppKit
import Foundation

enum ActionManager {
    
    static func showlog(logUrl: URL) {
        let task = Process()
        task.launchPath = "/usr/bin/open"
        task.arguments = ["\(logUrl)", "-a", "/System/Applications/Utilities/Console.app"]
        task.launch()
    }

    static func restart() {
        let task = Process()
        task.launchPath = "/bin/sh"
        task.arguments = ["-c", "sleep 2; open \"\(Bundle.main.bundlePath)\""]
        task.launch()

        NSApp.terminate(self)
        exit(0)
    }

    static func terminateWithError() {
        NSApp.terminate(self)
        exit(1)
    }
}
