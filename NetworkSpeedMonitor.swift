import Cocoa

class SimpleNetworkMonitor {
    private var statusItem: NSStatusItem
    private var timer: Timer?
    private var lastBytesSent: UInt64 = 0
    private var lastBytesReceived: UInt64 = 0
    private var updateInterval: TimeInterval = 1.0
    
    init() {
        print("Initializing SimpleNetworkMonitor")
        
        // Create status item in menu bar
        statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.variableLength)
        
        // Set up initial values
        if let button = statusItem.button {
            button.title = "Network"
        }
        
        // Set up menu
        let menu = NSMenu()
        
        // Add update frequency submenu
        let updateFrequencyMenu = NSMenu()
        let updateFrequencyItem = NSMenuItem(title: "Update Frequency", action: nil, keyEquivalent: "")
        updateFrequencyItem.submenu = updateFrequencyMenu
        
        // Add frequency options
        let frequencies = [(0.5, "0.5s"), (1.0, "1s"), (2.0, "2s"), (5.0, "5s")]
        for (interval, title) in frequencies {
            let item = NSMenuItem(title: title, action: #selector(updateFrequencyChanged(_:)), keyEquivalent: "")
            item.target = self
            item.tag = Int(interval * 1000) // Store interval in milliseconds
            if interval == updateInterval {
                item.state = .on
            }
            updateFrequencyMenu.addItem(item)
        }
        
        menu.addItem(updateFrequencyItem)
        menu.addItem(NSMenuItem.separator())
        menu.addItem(NSMenuItem(title: "Quit", action: #selector(NSApplication.terminate(_:)), keyEquivalent: "q"))
        statusItem.menu = menu
        
        // Get initial stats
        let (sent, received) = getNetworkStats()
        lastBytesSent = sent
        lastBytesReceived = received
        
        // Start the timer
        startTimer()
        
        // Update immediately
        updateSpeed()
    }
    
    @objc private func updateFrequencyChanged(_ sender: NSMenuItem) {
        // Update all menu items state
        if let menu = sender.menu {
            menu.items.forEach { $0.state = .off }
        }
        sender.state = .on
        
        // Update interval
        updateInterval = TimeInterval(sender.tag) / 1000.0
        
        // Restart timer with new interval
        startTimer()
    }
    
    private func startTimer() {
        // Stop existing timer
        timer?.invalidate()
        
        // Create new timer with current interval
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { [weak self] _ in
            self?.updateSpeed()
        }
        RunLoop.current.add(timer!, forMode: .common)
    }
    
    private func updateSpeed() {
        let (bytesSent, bytesReceived) = getNetworkStats()
        
        // Calculate speeds
        let bytesSentPerSec = bytesSent > lastBytesSent ? bytesSent - lastBytesSent : 0
        let bytesReceivedPerSec = bytesReceived > lastBytesReceived ? bytesReceived - lastBytesReceived : 0
        
        // Update last values
        lastBytesSent = bytesSent
        lastBytesReceived = bytesReceived
        
        // Format speeds
        let uploadSpeed = formatSpeed(bytesPerSec: bytesSentPerSec)
        let downloadSpeed = formatSpeed(bytesPerSec: bytesReceivedPerSec)
        
        // Display speeds in menu bar
        if let button = statusItem.button {
            button.title = "↑\(uploadSpeed)/↓\(downloadSpeed)"
            print("Updated title: \(button.title)")
        }
    }
    
    private func getNetworkStats() -> (UInt64, UInt64) {
        var ifaddr: UnsafeMutablePointer<ifaddrs>?
        var bytesSent: UInt64 = 0
        var bytesReceived: UInt64 = 0
        
        guard getifaddrs(&ifaddr) == 0 else {
            return (0, 0)
        }
        
        var ptr = ifaddr
        while ptr != nil {
            defer { ptr = ptr?.pointee.ifa_next }
            
            let interface = ptr?.pointee
            let addrFamily = interface?.ifa_addr.pointee.sa_family
            
            if addrFamily == UInt8(AF_LINK) {
                let name = String(cString: (interface?.ifa_name)!)
                if name != "lo0" && name != "utun0" { // Exclude loopback and VPN interfaces
                    let data = interface?.ifa_data.assumingMemoryBound(to: if_data.self)
                    bytesSent += UInt64(data?.pointee.ifi_obytes ?? 0)
                    bytesReceived += UInt64(data?.pointee.ifi_ibytes ?? 0)
                }
            }
        }
        
        freeifaddrs(ifaddr)
        return (bytesSent, bytesReceived)
    }
    
    private func formatSpeed(bytesPerSec: UInt64) -> String {
        if bytesPerSec < 1024 {
            return "\(bytesPerSec)B"
        } else if bytesPerSec < 1024 * 1024 {
            let value = Int(Double(bytesPerSec) / 1024.0)
            return "\(value)K"
        } else {
            let value = Int(Double(bytesPerSec) / (1024.0 * 1024.0))
            return "\(value)M"
        }
    }
}

class AppDelegate: NSObject, NSApplicationDelegate {
    private var monitor: SimpleNetworkMonitor?
    
    func applicationDidFinishLaunching(_ notification: Notification) {
        print("Application launched")
        monitor = SimpleNetworkMonitor()
    }
}

// Simple main function instead of using @main attribute
import Foundation

let app = NSApplication.shared
let delegate = AppDelegate()
app.delegate = delegate
app.run() 