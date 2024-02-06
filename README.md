# p2p-clipboard-mac

p2p-clipboard-mac is a macOS menu bar application wrapper for the command-line based [p2p-clipboard](https://github.com/gnattu/p2p-clipboard), allowing for easy configuration and usage of the clipboard synchronization tool. 

This application supports macOS 12 and above, and it is compatible with both Intel and Apple Silicon Macs.

## Features

This menu bar application allows you to:

- Start p2p-clipboard in the background
- Modify all command line options in GUI
- Show Running Log using Console.app
- Set the app to Launch at Login

## Build instructions

1. Ensure Xcode is installed and ready for use.
2. Clone or download this repository:
```
git clone https://github.com/gnattu/p2p-clipboard-mac.git
```
3. Place the pre-built [p2p-clipboard](https://github.com/gnattu/p2p-clipboard) binary into the `bin` folder.
4. Open `p2pClipboard.xcodeproj` then build.

## Caveats

- Due to macOS limitations, if you update or reinstall the application, you may need to:
	-  Re-enable the "Launch at Login" option.
	-  Re-enter your user password for keychain access.
- macOS may present warnings about the app, such as "App needs to be updated" or "App is damaged", depending on your macOS version.
  - For macOS 13+ users, navigate to `System Settings -> Security & Privacy` and then scroll down to allow this app.
  - macOS 12 users may need to manually execute `xattr -r -d com.apple.quarantine /Applications/p2pClipboard.app` in the command line.
- If something bad happens and you need to kill the app, please make sure you kill both the wrapper and the core process in Activity Monitor. There will be one with an icon named `p2pClipboard` and one named `p2p-clipboard` without an icon. Both need to be killed.

## Cleanup

If you want to remove this from your Mac, you may want also want to remove the following:

- The recorded entry in `System Settings -> General -> Login Items`.
- The configs in `UserDefaults` database.
	- You can check them with `defaults read net.gnattu.p2pClipboard` command.
	- You can remove them with `defaults delete net.gnattu.p2pClipboard` command.
- The stored Pre-Shared Key in macOS Keychain.
	- You can manage it by searching `net.gnattu.p2pClipboard` in the Keychain Access App.

## License

This project is licensed under the [MIT License](LICENSE).
