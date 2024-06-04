# Tray
A macOS tray app helper library.

## Install
Open **XCode**, then **File** -> **Add Package Dependencies...**, on the new window, copy `https://github.com/boybeak/Tray.git` and paste it to search input.

## Usage
Import `Tray` before use it.
```swift
import Tray
```
Then, on your `AppDelegate` class, declare a class variable `private let tray = Tray()`. Then set arguments to the tray in `applicationDidFinishLaunching`, after that, install it.
```swift
class AppDelegate: NSObject, NSApplicationDelegate {
    
    private let tray = Tray()
    private let myViewController = MyViewController()
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        let icon = NSImage(systemSymbolName: "note.text", accessibilityDescription: nil)!
        let menu = NSMenu()
        let menuItem = NSMenuItem(title: "Quit", action: #selector(actionQuit(_:)), keyEquivalent: "")
        menu.addItem(menuItem)
        do {
            try tray.setSize(width: 320, height: 480)
                .setLevel(level: .statusBar)
                .install(icon: icon, view: myViewController.view)
        } catch {
            
        }
    }
    
    @objc func actionQuit(_ sender: NSMenuItem) {
        NSApplication.shared.terminate(nil)
    }
}

class MyViewController: NSViewController {
    override func viewDidLoad() {
        self.view.wantsLayer = true
        self.view.layer?.backgroundColor = NSColor.green.cgColor
    }
}
```
