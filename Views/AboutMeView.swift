//
//  AboutMeView.swift
//  Arithmetic
//
import SwiftUI

struct AboutMeView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    @State private var isImageLoading = false
    @StateObject private var deviceInfoManager = DeviceInfoManager()
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image section with CachedAsyncImageView
                VStack {
                    ZStack {
                        CachedAsyncImageView(
                            url: URL(string: "https://images.cnblogs.com/cnblogs_com/tobecrazy/432338/o_250810143405_Card.png"),
                            placeholder: Image(systemName: "person.circle.fill"),
                            onLoadingStateChanged: { loading in
                                isImageLoading = loading
                            }
                        )
                        .frame(maxWidth: 300, maxHeight: 200)
                        .cornerRadius(.adaptiveCornerRadius)
                        
                        // Progress indicator overlay
                        if isImageLoading {
                            ZStack {
                                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                    .fill(Color.black.opacity(0.3))
                                    .frame(maxWidth: 300, maxHeight: 200)
                                
                                VStack(spacing: 12) {
                                    ProgressViewUtils.LoadingProgressIndicator(
                                        color: .white,
                                        size: 40
                                    )
                                    
                                    Text("Loading...")
                                        .font(.caption)
                                        .foregroundColor(.white)
                                }
                            }
                            .transition(.opacity)
                        }
                    }
                    .frame(maxWidth: 300, maxHeight: 200)
                }
                .padding(.top, 20)
                
                // Content VStack
                VStack(spacing: 15) {
                    // Title
                    Text("about.title".localized)
                        .font(.adaptiveTitle2())
                        .fontWeight(.bold)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                    
                    // Content
                    Text("about.content".localized)
                        .font(.adaptiveBody())
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, 20)
                        .foregroundColor(.primary.opacity(0.8))
                    
                    // GitHub Link
                    Link("about.github_link".localized, destination: URL(string: "https://github.com/tobecrazy/Arithmetic")!)
                        .font(.adaptiveBody())
                        .foregroundColor(.blue)
                        .padding(.top, 10)
                    
                    // Device Information Section
                    VStack(alignment: .leading, spacing: 10) {
                        Text("about.device_info".localized)
                            .font(.headline)
                            .foregroundColor(.primary)
                            .padding(.top, 10)
                        
                        DeviceInfoView()
                            .environmentObject(deviceInfoManager)
                    }
                    .padding()
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(10)
                }
                .padding(.vertical, 20)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("about.page_title".localized)
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

struct DeviceInfoView: View {
    @EnvironmentObject var deviceInfoManager: DeviceInfoManager
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Device Name
            HStack {
                Text("about.device_name".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(DeviceUtils.deviceModel)
                    .foregroundColor(.secondary)
            }
            
            // CPU Info
            HStack {
                Text("about.cpu_info".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(DeviceUtils.deviceName)
                    .foregroundColor(.secondary)
            }
            
            // CPU Usage
            HStack {
                Text("about.cpu_usage".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.2f%%", deviceInfoManager.cpuUsage))
                    .foregroundColor(.secondary)
            }
            
            // Memory Usage
            HStack {
                Text("about.memory_usage".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(String(format: "%.2f%%", deviceInfoManager.memoryUsage))
                    .foregroundColor(.secondary)
            }
            
            // System Version
            HStack {
                Text("about.system_version".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(DeviceUtils.systemVersion)
                    .foregroundColor(.secondary)
            }
            
            // Current Time
            HStack {
                Text("about.current_time".localized + ": ")
                    .fontWeight(.semibold)
                Spacer()
                Text(deviceInfoManager.currentTime)
                    .foregroundColor(.secondary)
            }
        }
    }
}

struct AboutMeView_Previews: PreviewProvider {
    static var previews: some View {
        AboutMeView()
            .environmentObject(LocalizationManager())
    }
}
