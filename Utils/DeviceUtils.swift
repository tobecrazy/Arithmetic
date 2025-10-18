import SwiftUI
import Darwin
import UIKit
import Foundation

// MARK: - System Constants
let TASK_INFO_MAX = mach_msg_type_number_t(MemoryLayout<task_info_data_t>.size) / mach_msg_type_number_t(4)
let THREAD_BASIC_INFO_COUNT = mach_msg_type_number_t(MemoryLayout<thread_basic_info_data_t>.size) / mach_msg_type_number_t(MemoryLayout<integer_t>.size)
let TH_USAGE_SCALE = 1000000

// MARK: - DeviceInfoManager for real-time monitoring
class DeviceInfoManager: ObservableObject {
    @Published var cpuUsage: Double = 0.0
    @Published var memoryUsage: Double = 0.0
    @Published var currentTime: String = ""
    
    private var timer: Timer?
    private let updateInterval: TimeInterval = 1.0 // Update every second
    
    init() {
        updateInfo()
        startTimer()
    }
    
    private func startTimer() {
        timer = Timer.scheduledTimer(withTimeInterval: updateInterval, repeats: true) { _ in
            self.updateInfo()
        }
    }
    
    private func updateInfo() {
        cpuUsage = DeviceUtils.getCPUUsage()
        memoryUsage = DeviceUtils.memoryUsage
        currentTime = DeviceUtils.currentTime
    }
    
    deinit {
        timer?.invalidate()
    }
}

struct DeviceUtils {
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func isLandscape(with sizeClass: (horizontal: UserInterfaceSizeClass?, vertical: UserInterfaceSizeClass?)) -> Bool {
        return sizeClass.horizontal == .regular && sizeClass.vertical == .regular
    }
    
    // MARK: - Device Information
    static var deviceName: String {
        var systemInfo = utsname()
        uname(&systemInfo)
        let machineMirror = Mirror(reflecting: systemInfo.machine)
        let identifier = machineMirror.children.reduce("") { identifier, element in
            guard let value = element.value as? Int8, value != 0 else { return identifier }
            return identifier + String(UnicodeScalar(UInt8(value)))
        }
        return identifier
    }
    
    static var deviceModel: String {
        let identifier = deviceName
        // Map device identifiers to user-friendly names
        switch identifier {
        case "iPod5,1": return "iPod Touch 5"
        case "iPod7,1": return "iPod Touch 6"
        case "iPhone3,1", "iPhone3,2", "iPhone3,3": return "iPhone 4"
        case "iPhone4,1": return "iPhone 4s"
        case "iPhone5,1", "iPhone5,2": return "iPhone 5"
        case "iPhone5,3", "iPhone5,4": return "iPhone 5c"
        case "iPhone6,1", "iPhone6,2": return "iPhone 5s"
        case "iPhone7,2": return "iPhone 6"
        case "iPhone7,1": return "iPhone 6 Plus"
        case "iPhone8,1": return "iPhone 6s"
        case "iPhone8,2": return "iPhone 6s Plus"
        case "iPhone8,4": return "iPhone SE"
        case "iPhone9,1", "iPhone9,3": return "iPhone 7"
        case "iPhone9,2", "iPhone9,4": return "iPhone 7 Plus"
        case "iPhone10,1", "iPhone10,4": return "iPhone 8"
        case "iPhone10,2", "iPhone10,5": return "iPhone 8 Plus"
        case "iPhone10,3", "iPhone10,6": return "iPhone X"
        case "iPhone11,2": return "iPhone XS"
        case "iPhone11,4", "iPhone11,6": return "iPhone XS Max"
        case "iPhone11,8": return "iPhone XR"
        case "iPhone12,1": return "iPhone 11"
        case "iPhone12,3": return "iPhone 11 Pro"
        case "iPhone12,5": return "iPhone 11 Pro Max"
        case "iPhone12,8": return "iPhone SE (2nd generation)"
        case "iPhone13,1": return "iPhone 12 mini"
        case "iPhone13,2": return "iPhone 12"
        case "iPhone13,3": return "iPhone 12 Pro"
        case "iPhone13,4": return "iPhone 12 Pro Max"
        case "iPhone14,4": return "iPhone 13 mini"
        case "iPhone14,5": return "iPhone 13"
        case "iPhone14,2": return "iPhone 13 Pro"
        case "iPhone14,3": return "iPhone 13 Pro Max"
        case "iPhone14,7": return "iPhone 14"
        case "iPhone14,8": return "iPhone 14 Plus"
        case "iPhone15,2": return "iPhone 14 Pro"
        case "iPhone15,3": return "iPhone 14 Pro Max"
        case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4": return "iPad 2"
        case "iPad3,1", "iPad3,2", "iPad3,3": return "iPad (3rd generation)"
        case "iPad3,4", "iPad3,5", "iPad3,6": return "iPad (4th generation)"
        case "iPad6,11", "iPad6,12": return "iPad (5th generation)"
        case "iPad7,5", "iPad7,6": return "iPad (6th generation)"
        case "iPad7,11", "iPad7,12": return "iPad (7th generation)"
        case "iPad11,6", "iPad11,7": return "iPad (8th generation)"
        case "iPad12,1", "iPad12,2": return "iPad (9th generation)"
        case "iPad13,18", "iPad13,19": return "iPad (10th generation)"
        case "iPad4,1", "iPad4,2", "iPad4,3": return "iPad Air"
        case "iPad5,3", "iPad5,4": return "iPad Air 2"
        case "iPad11,3", "iPad11,4": return "iPad Air (3rd generation)"
        case "iPad13,1", "iPad13,2": return "iPad Air (4th generation)"
        case "iPad13,16", "iPad13,17": return "iPad Air (5th generation)"
        case "iPad2,5", "iPad2,6", "iPad2,7": return "iPad Mini"
        case "iPad4,4", "iPad4,5", "iPad4,6": return "iPad Mini 2"
        case "iPad4,7", "iPad4,8", "iPad4,9": return "iPad Mini 3"
        case "iPad5,1", "iPad5,2": return "iPad Mini 4"
        case "iPad11,1", "iPad11,2": return "iPad Mini (5th generation)"
        case "iPad14,1", "iPad14,2": return "iPad Mini (6th generation)"
        case "iPad6,3", "iPad6,4": return "iPad Pro (9.7-inch)"
        case "iPad6,7", "iPad6,8": return "iPad Pro (12.9-inch)"
        case "iPad7,1", "iPad7,2": return "iPad Pro (12.9-inch) (2nd generation)"
        case "iPad7,3", "iPad7,4": return "iPad Pro (10.5-inch)"
        case "iPad8,1", "iPad8,2", "iPad8,3", "iPad8,4": return "iPad Pro (11-inch)"
        case "iPad8,5", "iPad8,6", "iPad8,7", "iPad8,8": return "iPad Pro (12.9-inch) (3rd generation)"
        case "iPad8,9", "iPad8,10": return "iPad Pro (11-inch) (2nd generation)"
        case "iPad8,11", "iPad8,12": return "iPad Pro (12.9-inch) (4th generation)"
        case "iPad13,4", "iPad13,5", "iPad13,6", "iPad13,7": return "iPad Pro (11-inch) (3rd generation)"
        case "iPad13,8", "iPad13,9", "iPad13,10", "iPad13,11": return "iPad Pro (12.9-inch) (5th generation)"
        case "iPad14,3", "iPad14,4": return "iPad Pro (11-inch) (4th generation)"
        case "iPad14,5", "iPad14,6": return "iPad Pro (12.9-inch) (6th generation)"
        case "AppleTV5,3": return "Apple TV"
        case "AppleTV6,2": return "Apple TV 4K"
        case "AudioAccessory1,1": return "HomePod"
        case "i386", "x86_64", "arm64": return "Simulator"
        default: return identifier
        }
    }
    
    static var systemVersion: String {
        return UIDevice.current.systemVersion
    }
    
    // MARK: - CPU Usage
    static func getCPUUsage() -> Double {
        var kr: kern_return_t
        var thread_list: thread_act_array_t?
        var thread_count: mach_msg_type_number_t = 0
        
        // Get the list of threads in the current task
        kr = task_threads(mach_task_self_, &thread_list, &thread_count)
        if kr != KERN_SUCCESS {
            return -1
        }
        
        var tot_cpu = Int32(0)
        
        // Process each thread to calculate CPU usage
        if let thread_list = thread_list {
            for i in 0..<Int(thread_count) {
                var thread_info_count = THREAD_BASIC_INFO_COUNT
                var thread_info_array = [Int32](repeating: 0, count: Int(THREAD_BASIC_INFO_COUNT))
                
                kr = thread_info(
                    thread_list[i],
                    thread_flavor_t(THREAD_BASIC_INFO),
                    thread_info_t(&thread_info_array),
                    &thread_info_count
                )
                
                if kr == KERN_SUCCESS && thread_info_count >= Int32(THREAD_BASIC_INFO_COUNT) {
                    let cpu_usage = thread_info_array[4]
                    let flags = thread_info_array[6]
                    
                    if flags & 4 == 0 {  // Not idle
                        tot_cpu += cpu_usage
                    }
                }
            }
            
            // Clean up thread list
            for i in 0..<Int(thread_count) {
                mach_port_deallocate(mach_task_self_, thread_list[i])
            }
            
            kr = vm_deallocate(mach_task_self_, 
                              vm_address_t(UInt(bitPattern: thread_list)), 
                              vm_size_t(thread_count * UInt32(MemoryLayout<thread_act_t>.stride)))
        }
        
        return Double(tot_cpu) / Double(TH_USAGE_SCALE) * 100.0
    }
    
    // MARK: - Memory Usage
    static var memoryUsage: Double {
        let info = ProcessInfo.processInfo
        let memoryUsed = info.physicalMemory
        
        // Get the memory usage as a percentage of total physical memory
        // This requires getting the total memory on the device
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)
        
        return Double(memoryUsed) / Double(totalMemory) * 100.0
    }
    
    static var memoryUsedInMB: Double {
        let info = ProcessInfo.processInfo
        let memoryUsed = info.physicalMemory
        return Double(memoryUsed) / (1024.0 * 1024.0)
    }
    
    static var totalMemoryInMB: Double {
        var totalMemory: UInt64 = 0
        var size = MemoryLayout<UInt64>.size
        sysctlbyname("hw.memsize", &totalMemory, &size, nil, 0)
        return Double(totalMemory) / (1024.0 * 1024.0)
    }
    
    // MARK: - Current Time
    static var currentTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .medium
        return formatter.string(from: Date())
    }
}
