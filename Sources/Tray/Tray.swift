// The Swift Programming Language
// https://docs.swift.org/swift-book

import AppKit
import SwiftUI

public class Tray: NSObject {
    
    public static func install(icon: NSImage, onConfig: (_ tray: Tray) -> Void)-> Tray {
        let tray = Tray()
        tray.setIcon(icon: icon)
        onConfig(tray)
        return tray
    }
    
    @available(macOS 11.0, *)
    public static func install(systemSymbolName: String, onConfig: (_ tray: Tray) -> Void)-> Tray {
        let tray = Tray()
        tray.setIcon(systemSymbolName: systemSymbolName)
        onConfig(tray)
        return tray
    }

    public static func install(named: String, onConfig: (_ tray: Tray) -> Void)-> Tray {
        let tray = Tray()
        tray.setIcon(named: named)
        onConfig(tray)
        return tray
    }
    
    private(set) public var statusItem: NSStatusItem?
    private(set) public var popover: NSPopover? = nil
    
    private(set) var width: Int = 0
    private(set) var height: Int = 0
    
    private(set) var viewController: NSViewController? = nil
    private var level: NSWindow.Level = .floating
    private var rightMenu: NSMenu? = nil
    
    private var onLeftClick: (() -> Bool)? = nil
    private var onRightClick: (() -> Bool)? = nil
    
    private override init() {}
    
    @available(macOS 11.0, *)
    public func setIcon(systemSymbolName: String) {
        let icon = NSImage(systemSymbolName: systemSymbolName, accessibilityDescription: nil)!
        self.setIcon(icon: icon)
    }
    
    public func setIcon(named: String) {
        let icon = NSImage(named: named)!
        self.setIcon(icon: icon)
    }
    
    public func setIcon(icon: NSImage) {
        if statusItem == nil {
            statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        }
        if let menuBtn = statusItem?.button {
            icon.isTemplate = true
            menuBtn.image = icon
            menuBtn.target = self
            menuBtn.action = #selector(menuBtnAction)
            menuBtn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    public func setView(viewController: NSViewController, behavior: NSPopover.Behavior = .transient, level: NSWindow.Level = .floating, size: CGSize? = nil) {
        self.viewController = viewController
        if popover == nil {
            popover = NSPopover()
            popover?.animates = true
            popover?.behavior = behavior
        }
        popover?.contentViewController = viewController
        self.level = level
        if size != nil {
            popover?.contentViewController?.view.frame = NSRect(x: 0, y: 0, width: size!.width, height: size!.height)
        }
        
    }
        
    public func setView(view: NSView, behavior: NSPopover.Behavior = .transient, level: NSWindow.Level = .floating, size: CGSize? = nil) {
        let viewController = NSViewController()
        viewController.view = view
        self.setView(viewController: viewController, behavior: behavior, level: level, size: size)
    }
    
    @available(macOS 10.15, *)
    public func setView<Content: View>(content: Content, behavior: NSPopover.Behavior = .transient, level: NSWindow.Level = .floating, size: CGSize? = nil) {
        self.setView(view: NSHostingView(rootView: content), behavior: behavior, level: level, size: size)
    }
    
    public func setMenu(menu: NSMenu) {
        self.rightMenu = menu
    }
    
    public func setOnLeftClick(onClick: @escaping () -> Bool) {
        self.onLeftClick = onClick
    }
    public func setOnRightClick(onClick: @escaping () -> Bool) {
        self.onRightClick = onClick
    }
    
    @objc private func menuBtnAction(sender: AnyObject) {
        guard let event = NSApp.currentEvent else { return }
        switch event.type {
        case .rightMouseUp:
            if let rightClick = self.onRightClick {
                if (rightClick()) {
                    return
                }
            }
            if rightMenu != nil {
                statusItem?.popUpMenu(rightMenu!)
            } else {
                togglePopover(sender: sender)
            }
        default:
            if let leftClick = self.onLeftClick {
                if (leftClick()) {
                    return
                }
            }
            togglePopover(sender: sender)
        }
    }
    
    private func togglePopover(sender: AnyObject) {
        if popover?.isShown == true {
            popover?.performClose(sender)
        } else {
            if let menuBtn = statusItem?.button {
                popover?.show(relativeTo: menuBtn.bounds, of: menuBtn, preferredEdge: .minY)
                popover?.contentViewController?.view.window?.level = self.level
                popover?.contentViewController?.view.window?.makeKey()
            }
        }
    }
    
}
