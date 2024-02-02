//
//  SettingsWindow.swift
//  p2pClipboard
//
//  Created by Gnattu OC on 1/20/24.
//

import SwiftUI
import LaunchAtLogin

class SettingsWindow: NSWindow {
    convenience init() {
        self.init(contentRect: NSRect(x: 0, y: 0, width: 480, height: 480), styleMask: [.titled, .closable], backing: .buffered, defer: false)
        contentView = NSHostingView(rootView: SettingsView())
        title = "p2pClipboard Settings"
        level = .floating
    }
}

struct SettingsView: View {
    @AppStorage("UseConnect") private var useConnect = false
    @AppStorage("SetListen") private var setListen = false
    @AppStorage("SetPrivateKey") private var setPrivateKey = false
    @AppStorage("DisableMdns") private var disableMdns = false
    @AppStorage("ConnectIP") private var connectIp = ""
    @AppStorage("ConnectPort") private var connectPort = ""
    @AppStorage("ConnectPeerID") private var connectPeerId = ""
    @AppStorage("ListenIP") private var listenIp = ""
    @AppStorage("ListenPort") private var listenPort = ""
    @AppStorage("PrivateKeyPath") private var privateKeyPath = ""
    
    var body: some View {
        VStack {
            Form {
                Toggle("Connect to other node:", isOn: $useConnect)
                HStack {
                    TextField("Address:", text: $connectIp, prompt: Text("IP"))
                        .disabled(!useConnect)
                    Text(":")
                    TextField("Port", text: $connectPort, prompt: Text("Port"))
                        .disabled(!useConnect)
                        .frame(width: 93)
                        .labelsHidden()
                }
                TextField("PeerID:", text: $connectPeerId, prompt: Text("12D3KooWxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"))
                    .disabled(!useConnect)
                Divider()
                Toggle("Set listen address:", isOn: $setListen)
                HStack {
                    TextField("Address:", text: $listenIp, prompt: Text("IP"))
                        .disabled(!setListen)
                    Text(":")
                    TextField("Port", text: $listenPort, prompt: Text("Port"))
                        .disabled(!setListen)
                        .frame(width: 93)
                        .labelsHidden()
                }
                Divider()
                Toggle("Custom private key:", isOn: $setPrivateKey)
                HStack {
                    TextField("Path:", text: $privateKeyPath, prompt: Text("/path/to/key.pem"))
                        .disabled(!setPrivateKey)
                    Button("Select File...")
                    {
                        let panel = NSOpenPanel()
                        panel.allowsMultipleSelection = false
                        panel.canChooseDirectories = false
                        if panel.runModal() == .OK {
                            self.privateKeyPath = panel.url?.path ?? ""
                        }
                    }
                    .frame(width: 93)
                }
                Divider()
                Toggle("Disable mDNS", isOn: $disableMdns)
                LaunchAtLogin.Toggle {
                    Text("Launch at Login")
                }
            }
            Form {
                Button("Apply & Restart") {
                    ActionManager.restart()
                }
            }
        }
        .textFieldStyle(.roundedBorder)
        .padding()
        .frame(width: 480)
        .fixedSize()
    }
}


#Preview {
    SettingsView()
}
