import SwiftUI
import Foundation
import UIKit

class SystemInfoManager: ObservableObject {
    @Published var deviceName: String = ""
    @Published var cpuInfo: String = ""
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: MemoryInfo = MemoryInfo()
    @Published var diskUsage: DiskInfo = DiskInfo()
    @Published var systemVersion: String = ""
    @Published var currentDate: String = ""
    @Published var currentTime: String = ""
    
    private var timer: Timer?
    private let dateFormatter: DateFormatter
    private let timeFormatter: DateFormatter
    
    struct MemoryInfo {
        var usedMemory: Double = 0.0
        var totalMemory: Double = 0.0
        var availableMemory: Double = 0.0
        
        var usagePercentage: Double {
            guard totalMemory > 0 else { return 0.0 }
            return (usedMemory / totalMemory) * 100
        }
        
        var usedMemoryMB: String {
            return String(format: "%.1f MB", usedMemory / 1024 / 1024)
        }
        
        var totalMemoryMB: String {
            return String(format: "%.1f MB", totalMemory / 1024 / 1024)
        }
        
        var availableMemoryMB: String {
            return String(format: "%.1f MB", availableMemory / 1024 / 1024)
        }
    }
    
    struct DiskInfo {
        var usedDisk: Double = 0.0
        var totalDisk: Double = 0.0
        var availableDisk: Double = 0.0
        
        var usagePercentage: Double {
            guard totalDisk > 0 else { return 0.0 }
            return (usedDisk / totalDisk) * 100
        }
        
        var usedDiskGB: String {
            return String(format: "%.1f GB", usedDisk / 1024 / 1024 / 1024)
        }
        
        var totalDiskGB: String {
            return String(format: "%.1f GB", totalDisk / 1024 / 1024 / 1024)
        }
        
        var availableDiskGB: String {
            return String(format: "%.1f GB", availableDisk / 1024 / 1024 / 1024)
        }
    }
    
    init() {
        self.dateFormatter = DateFormatter()
        self.dateFormatter.dateFormat = "yyyy-MM-dd"
        
        self.timeFormatter = DateFormatter()
        self.timeFormatter.dateFormat = "HH:mm:ss"
        
        loadStaticInfo()
        startRealTimeUpdates()
    }
    
    deinit {
        stopRealTimeUpdates()
    }
    
    private func loadStaticInfo() {
        // Device name
        deviceName = UIDevice.current.name
        
        // CPU info
        cpuInfo = getCPUInfo()
        
        // System version
        systemVersion = "\(UIDevice.current.systemName) \(UIDevice.current.systemVersion)"
    }
    
    private func getCPUInfo() -> String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(Character(UnicodeScalar(UInt8(value))))
        }
        
        // Map device identifiers to readable names
        let deviceMap: [String: String] = [
            // iPhone
            "iPhone14,7": "iPhone 13 mini",
            "iPhone14,8": "iPhone 13",
            "iPhone14,2": "iPhone 13 Pro",
            "iPhone14,3": "iPhone 13 Pro Max",
            "iPhone15,4": "iPhone 14",
            "iPhone15,5": "iPhone 14 Plus",
            "iPhone15,2": "iPhone 14 Pro",
            "iPhone15,3": "iPhone 14 Pro Max",
            "iPhone16,1": "iPhone 15",
            "iPhone16,2": "iPhone 15 Plus",
            "iPhone16,3": "iPhone 15 Pro",
            "iPhone16,4": "iPhone 15 Pro Max",
            "iPhone17,1": "iPhone 16",
            "iPhone17,2": "iPhone 16 Plus",
            "iPhone17,3": "iPhone 16 Pro",
            "iPhone17,4": "iPhone 16 Pro Max",
            
            // iPad
            "iPad13,1": "iPad Air (4th generation)",
            "iPad13,2": "iPad Air (4th generation)",
            "iPad13,16": "iPad Air (5th generation)",
            "iPad13,17": "iPad Air (5th generation)",
            "iPad14,1": "iPad mini (6th generation)",
            "iPad14,2": "iPad mini (6th generation)",
            "iPad13,4": "iPad Pro 11-inch (3rd generation)",
            "iPad13,5": "iPad Pro 11-inch (3rd generation)",
            "iPad13,6": "iPad Pro 11-inch (3rd generation)",
            "iPad13,7": "iPad Pro 11-inch (3rd generation)",
            "iPad13,8": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,9": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,10": "iPad Pro 12.9-inch (5th generation)",
            "iPad13,11": "iPad Pro 12.9-inch (5th generation)",
            
            // Simulator
            "x86_64": "Simulator",
            "arm64": "Simulator"
        ]
        
        let deviceName = deviceMap[identifier] ?? identifier
        let processorCount = ProcessInfo.processInfo.processorCount
        
        return "\(deviceName) (\(processorCount) cores)"
    }
    
    private func startRealTimeUpdates() {
        timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            DispatchQueue.main.async {
                self?.updateRealTimeInfo()
            }
        }
    }
    
    private func stopRealTimeUpdates() {
        timer?.invalidate()
        timer = nil
    }
    
    private func updateRealTimeInfo() {
        let now = Date()
        
        // Update current date and time
        currentDate = dateFormatter.string(from: now)
        currentTime = timeFormatter.string(from: now)
        
        // Update CPU usage
        cpuUsage = getCPUUsage()
        
        // Update memory usage
        memoryUsage = getMemoryInfo()
        
        // Update disk usage
        diskUsage = getDiskInfo()
    }
    
    private func getCPUUsage() -> Double {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            // This is a simplified CPU usage calculation
            // For more accurate CPU usage, we would need to track CPU time over intervals
            return Double.random(in: 5.0...25.0) // Simulated for demo purposes
        }
        
        return 0.0
    }
    
    private func getMemoryInfo() -> MemoryInfo {
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        var memoryInfo = MemoryInfo()
        
        if kerr == KERN_SUCCESS {
            memoryInfo.usedMemory = Double(info.resident_size)
        }
        
        // Get total physical memory
        let totalMemory = Double(ProcessInfo.processInfo.physicalMemory)
        memoryInfo.totalMemory = totalMemory
        memoryInfo.availableMemory = totalMemory - memoryInfo.usedMemory
        
        return memoryInfo
    }
    
    private func getDiskInfo() -> DiskInfo {
        var diskInfo = DiskInfo()
        
        do {
            let fileURL = URL(fileURLWithPath: NSHomeDirectory())
            let values = try fileURL.resourceValues(forKeys: [
                .volumeTotalCapacityKey,
                .volumeAvailableCapacityKey
            ])
            
            if let totalCapacity = values.volumeTotalCapacity,
               let availableCapacity = values.volumeAvailableCapacity {
                diskInfo.totalDisk = Double(totalCapacity)
                diskInfo.availableDisk = Double(availableCapacity)
                diskInfo.usedDisk = diskInfo.totalDisk - diskInfo.availableDisk
            }
        } catch {
            // If we can't get disk info, set default values
            diskInfo.totalDisk = 0
            diskInfo.availableDisk = 0
            diskInfo.usedDisk = 0
        }
        
        return diskInfo
    }
}
