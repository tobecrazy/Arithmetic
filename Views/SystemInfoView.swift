//
//  SystemInfoView.swift
//  Arithmetic
//
import SwiftUI

struct SystemInfoView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @StateObject private var systemInfoManager = SystemInfoManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // System Information Title
                VStack(spacing: 15) {
                    Text("system.info.title".localized)
                        .font(.adaptiveTitle())
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    Text("system.info.description".localized)
                        .font(.adaptiveBody())
                        .multilineTextAlignment(.center)
                        .foregroundColor(.secondary)
                        .padding(.horizontal, 20)
                }
                .padding(.top, 20)
                
                // System Info Content
                VStack(spacing: 15) {
                    // Device Name
                    SystemInfoRow(
                        title: "system.info.device_name".localized,
                        value: systemInfoManager.deviceName,
                        icon: "iphone"
                    )
                    
                    // CPU Info
                    SystemInfoRow(
                        title: "system.info.cpu_info".localized,
                        value: systemInfoManager.cpuInfo,
                        icon: "cpu"
                    )
                    
                    // CPU Usage (Real-time)
                    SystemInfoProgressRow(
                        title: "system.info.cpu_usage".localized,
                        value: systemInfoManager.cpuUsage,
                        unit: "%",
                        icon: "speedometer",
                        color: .orange
                    )
                    
                    // Memory Usage (Real-time)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "memorychip")
                                .foregroundColor(.green)
                                .frame(width: 20)
                            Text("system.info.memory_usage".localized)
                                .font(.adaptiveBody())
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("system.info.memory_used".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.memoryUsage.usedMemoryMB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("system.info.memory_total".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.memoryUsage.totalMemoryMB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("system.info.memory_available".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.memoryUsage.availableMemoryMB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            // Memory Usage Progress Bar
                            ProgressView(value: systemInfoManager.memoryUsage.usagePercentage, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .green))
                                .scaleEffect(x: 1, y: 0.8, anchor: .center)
                            
                            HStack {
                                Spacer()
                                Text(String(format: "%.1f%%", systemInfoManager.memoryUsage.usagePercentage))
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                                    .foregroundColor(.green)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // Disk Usage (Real-time)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "internaldrive")
                                .foregroundColor(.purple)
                                .frame(width: 20)
                            Text("system.info.disk_usage".localized)
                                .font(.adaptiveBody())
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(alignment: .leading, spacing: 4) {
                            HStack {
                                Text("system.info.disk_used".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.diskUsage.usedDiskGB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("system.info.disk_total".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.diskUsage.totalDiskGB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            HStack {
                                Text("system.info.disk_available".localized + ":")
                                    .font(.adaptiveCaption())
                                    .foregroundColor(.secondary)
                                Spacer()
                                Text(systemInfoManager.diskUsage.availableDiskGB)
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                            }
                            
                            // Disk Usage Progress Bar
                            ProgressView(value: systemInfoManager.diskUsage.usagePercentage, total: 100)
                                .progressViewStyle(LinearProgressViewStyle(tint: .purple))
                                .scaleEffect(x: 1, y: 0.8, anchor: .center)
                            
                            HStack {
                                Spacer()
                                Text(String(format: "%.1f%%", systemInfoManager.diskUsage.usagePercentage))
                                    .font(.adaptiveCaption())
                                    .fontWeight(.medium)
                                    .foregroundColor(.purple)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                    
                    // System Version
                    SystemInfoRow(
                        title: "system.info.system_version".localized,
                        value: systemInfoManager.systemVersion,
                        icon: "gear"
                    )
                    
                    // Current Date and Time (Real-time)
                    VStack(alignment: .leading, spacing: 8) {
                        HStack {
                            Image(systemName: "clock")
                                .foregroundColor(.blue)
                                .frame(width: 20)
                            Text("system.info.current_time".localized)
                                .font(.adaptiveBody())
                                .fontWeight(.medium)
                            Spacer()
                        }
                        
                        VStack(alignment: .trailing, spacing: 4) {
                            HStack {
                                Spacer()
                                Text(systemInfoManager.currentDate)
                                    .font(.adaptiveBody())
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                            
                            HStack {
                                Spacer()
                                Text(systemInfoManager.currentTime)
                                    .font(.adaptiveBody())
                                    .fontWeight(.medium)
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(Color.secondary.opacity(0.1))
                    .cornerRadius(8)
                }
                .padding(.horizontal, 20)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("system.info.page_title".localized)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack {
                        Image(systemName: "chevron.left")
                        Text("button.back".localized)
                    }
                    .foregroundColor(.blue)
                }
            }
        }
    }
}

struct SystemInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SystemInfoView()
            .environmentObject(LocalizationManager())
    }
}
