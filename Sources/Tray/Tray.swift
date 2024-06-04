// The Swift Programming Language
// https://docs.swift.org/swift-book

import AppKit
import SwiftUI

@available(macOS 10.15, *)
public class Tray: NSObject, NSPopoverDelegate {
    
    @Published var statusItem: NSStatusItem?
    @Published var popover = NSPopover()
    
    private(set) var width: Int = 0
    private(set) var height: Int = 0
    private(set) var level: NSWindow.Level = .floating
    
    private var rightMenu: NSMenu? = nil
    
    public override init(){}
    
    public func setSize(width: Int, height: Int)-> Tray {
        self.width = width
        self.height = height
        return self
    }
    
    public func setLevel(level: NSWindow.Level)-> Tray {
        self.level = level
        return self
    }
    
    public func install(icon: NSImage, view: NSView, menu: NSMenu? = nil) throws {
        
        if self.width <= 0 || self.height <= 0 {
            throw InvalidSizeError(width: self.width, height: self.height)
        }
        
        self.rightMenu = menu
        
        popover.animates = true
        popover.behavior = .transient
        popover.delegate = self
        
        popover.contentViewController = NSViewController()
        popover.contentViewController?.view = view
        popover.contentViewController?.view.frame = NSRect(x: 0, y: 0, width: self.width, height: self.height)
        popover.contentViewController?.view.window?.makeKey()
        
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)

        if let menuBtn = statusItem?.button {
            icon.isTemplate = true
            menuBtn.image = icon
            menuBtn.target = self
            menuBtn.action = #selector(menuBtnAction)
            menuBtn.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
    }
    
    public func popoverDidShow(_ notification: Notification) {
        popover.contentViewController?.view.window?.level = self.level
    }
    
    @objc func menuBtnAction(sender: AnyObject) {
        guard let event = NSApp.currentEvent else { return }
        switch event.type {
        case .rightMouseUp:
            if rightMenu != nil {
                statusItem?.popUpMenu(rightMenu!)
            } else {
                togglePopover(sender: sender)
            }
        default:
            togglePopover(sender: sender)
        }
    }
    
    private func togglePopover(sender: AnyObject) {
        if popover.isShown {
            popover.performClose(sender)
        } else {
            if let menuBtn = statusItem?.button {
                popover.show(relativeTo: menuBtn.bounds, of: menuBtn, preferredEdge: .minY)
            }
        }
    }
    
}

struct InvalidSizeError: Error {
    let width: Int
    let height: Int
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
    }
}
