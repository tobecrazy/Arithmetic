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
    @Environment(\.colorScheme) var colorScheme
    @StateObject private var systemInfoManager = SystemInfoManager()

    // Tech color palette
    private let deviceColor: Color = .cyan
    private let cpuColor: Color = .orange
    private let memoryColor: Color = .green
    private let diskColor: Color = .purple
    private let networkColor: Color = .blue
    private let batteryColor: Color = .mint
    private let screenColor: Color = .indigo
    private let timeColor: Color = .pink

    var body: some View {
        ZStack {
            // Animated background
            TechBackground(colorScheme: colorScheme)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    // Header Section
                    TechSectionHeader(
                        title: "system.info.title".localized,
                        subtitle: "system.info.description".localized
                    )
                    .padding(.top, 20)

                    // System Info Content
                    VStack(spacing: 16) {
                        // Device Name
                        SystemInfoRow(
                            title: "system.info.device_name".localized,
                            value: systemInfoManager.deviceName,
                            icon: "iphone",
                            accentColor: deviceColor
                        )

                        // CPU Info
                        SystemInfoRow(
                            title: "system.info.cpu_info".localized,
                            value: systemInfoManager.cpuInfo,
                            icon: "cpu",
                            accentColor: cpuColor
                        )

                        // CPU Usage (Real-time)
                        SystemInfoProgressRow(
                            title: "system.info.cpu_usage".localized,
                            value: systemInfoManager.cpuUsage,
                            unit: "%",
                            icon: "speedometer",
                            color: cpuColor
                        )

                        // Memory Usage Section
                        DetailInfoSection(
                            title: "system.info.memory_usage".localized,
                            icon: "memorychip",
                            color: memoryColor,
                            items: [
                                ("system.info.memory_used".localized, systemInfoManager.memoryUsage.usedMemoryMB),
                                ("system.info.memory_total".localized, systemInfoManager.memoryUsage.totalMemoryMB),
                                ("system.info.memory_available".localized, systemInfoManager.memoryUsage.availableMemoryMB)
                            ],
                            showProgressBar: true,
                            progressValue: systemInfoManager.memoryUsage.usagePercentage
                        )

                        // Disk Usage Section
                        DetailInfoSection(
                            title: "system.info.disk_usage".localized,
                            icon: "internaldrive",
                            color: diskColor,
                            items: [
                                ("system.info.disk_used".localized, systemInfoManager.diskUsage.usedDiskGB),
                                ("system.info.disk_total".localized, systemInfoManager.diskUsage.totalDiskGB),
                                ("system.info.disk_available".localized, systemInfoManager.diskUsage.availableDiskGB)
                            ],
                            showProgressBar: true,
                            progressValue: systemInfoManager.diskUsage.usagePercentage
                        )

                        // System Version
                        SystemInfoRow(
                            title: "system.info.system_version".localized,
                            value: systemInfoManager.systemVersion,
                            icon: "gear",
                            accentColor: .gray
                        )

                        // Network Information
                        networkInfoSection

                        // Battery Information
                        batteryInfoSection

                        // Screen Information
                        screenInfoSection

                        // Current Date and Time (Real-time)
                        RealtimeClockDisplay(
                            date: systemInfoManager.currentDate,
                            time: systemInfoManager.currentTime,
                            color: timeColor
                        )
                    }
                    .padding(.horizontal, 20)

                    Spacer(minLength: 50)
                }
                .padding()
            }
        }
        .navigationTitle("system.info.title".localized)
        .navigationBarTitleDisplayMode(.large)
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    HStack(spacing: 6) {
                        Image(systemName: "chevron.left")
                            .font(.system(size: 14, weight: .semibold))
                        Text("button.back".localized)
                    }
                    .foregroundColor(.cyan)
                }
            }
        }
    }

    // MARK: - Network Info Section
    private var networkInfoSection: some View {
        var networkItems: [(String, String)] = [
            ("system.info.connection_type".localized, systemInfoManager.networkInfo.connectionType)
        ]

        if !systemInfoManager.networkInfo.wifiSSID.isEmpty {
            networkItems.append(("system.info.wifi_ssid".localized, systemInfoManager.networkInfo.wifiSSID))
        }

        if !systemInfoManager.networkInfo.cellularCarrier.isEmpty && systemInfoManager.networkInfo.cellularCarrier != "Unknown" {
            networkItems.append(("system.info.cellular_carrier".localized, systemInfoManager.networkInfo.cellularCarrier))
        }

        return DetailInfoSection(
            title: "system.info.network_info".localized,
            icon: "wifi",
            color: networkColor,
            items: networkItems
        )
    }

    // MARK: - Battery Info Section
    private var batteryInfoSection: some View {
        DetailInfoSection(
            title: "system.info.battery_info".localized,
            icon: batteryIconName,
            color: batteryColor,
            items: [
                ("system.info.battery_level".localized, String(format: "%.0f%%", systemInfoManager.batteryInfo.level * 100)),
                ("system.info.battery_state".localized, systemInfoManager.batteryInfo.state),
                ("system.info.power_source".localized, systemInfoManager.batteryInfo.powerSourceState),
                ("system.info.boot_time".localized, systemInfoManager.batteryInfo.bootTimeString),
                ("system.info.uptime".localized, systemInfoManager.batteryInfo.uptimeString)
            ],
            showProgressBar: true,
            progressValue: Double(systemInfoManager.batteryInfo.level * 100)
        )
    }

    private var batteryIconName: String {
        let level = systemInfoManager.batteryInfo.level
        if level >= 0.75 {
            return "battery.100"
        } else if level >= 0.5 {
            return "battery.75"
        } else if level >= 0.25 {
            return "battery.50"
        } else {
            return "battery.25"
        }
    }

    // MARK: - Screen Info Section
    private var screenInfoSection: some View {
        DetailInfoSection(
            title: "system.info.screen_info".localized,
            icon: "display",
            color: screenColor,
            items: [
                ("system.info.screen_resolution".localized, systemInfoManager.screenInfo.screenResolution),
                ("system.info.screen_size".localized, String(format: "%.0f × %.0f", systemInfoManager.screenInfo.screenSize.width, systemInfoManager.screenInfo.screenSize.height)),
                ("system.info.scale_factor".localized, String(format: "%.0fx", systemInfoManager.screenInfo.scaleFactor)),
                ("system.info.refresh_rate".localized, String(format: "%.0f Hz", systemInfoManager.screenInfo.refreshRate)),
                ("system.info.physical_size".localized, systemInfoManager.screenInfo.physicalSize)
            ]
        )
    }
}

// MARK: - Tech Background
struct TechBackground: View {
    let colorScheme: ColorScheme
    @State private var animateGradient = false

    var body: some View {
        ZStack {
            // Base gradient
            LinearGradient(
                colors: colorScheme == .dark
                    ? [Color(red: 0.05, green: 0.05, blue: 0.15), Color(red: 0.1, green: 0.1, blue: 0.2)]
                    : [Color(red: 0.95, green: 0.97, blue: 1.0), Color(red: 0.9, green: 0.95, blue: 1.0)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )

            // Animated orbs
            GeometryReader { geometry in
                ZStack {
                    // Cyan orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.cyan.opacity(0.3), Color.cyan.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 150
                            )
                        )
                        .frame(width: 300, height: 300)
                        .offset(
                            x: animateGradient ? geometry.size.width * 0.2 : geometry.size.width * 0.1,
                            y: animateGradient ? geometry.size.height * 0.1 : geometry.size.height * 0.2
                        )

                    // Purple orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.purple.opacity(0.2), Color.purple.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 120
                            )
                        )
                        .frame(width: 240, height: 240)
                        .offset(
                            x: animateGradient ? geometry.size.width * 0.6 : geometry.size.width * 0.7,
                            y: animateGradient ? geometry.size.height * 0.6 : geometry.size.height * 0.5
                        )

                    // Blue orb
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.blue.opacity(0.15), Color.blue.opacity(0)],
                                center: .center,
                                startRadius: 0,
                                endRadius: 100
                            )
                        )
                        .frame(width: 200, height: 200)
                        .offset(
                            x: animateGradient ? geometry.size.width * 0.3 : geometry.size.width * 0.4,
                            y: animateGradient ? geometry.size.height * 0.8 : geometry.size.height * 0.7
                        )
                }
            }

            // Grid pattern overlay
            GridPatternView()
                .opacity(colorScheme == .dark ? 0.1 : 0.05)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 8).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Grid Pattern
struct GridPatternView: View {
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                let spacing: CGFloat = 30
                let width = geometry.size.width
                let height = geometry.size.height

                // Vertical lines
                var x: CGFloat = 0
                while x <= width {
                    path.move(to: CGPoint(x: x, y: 0))
                    path.addLine(to: CGPoint(x: x, y: height))
                    x += spacing
                }

                // Horizontal lines
                var y: CGFloat = 0
                while y <= height {
                    path.move(to: CGPoint(x: 0, y: y))
                    path.addLine(to: CGPoint(x: width, y: y))
                    y += spacing
                }
            }
            .stroke(Color.cyan, lineWidth: 0.5)
        }
    }
}

struct SystemInfoView_Previews: PreviewProvider {
    static var previews: some View {
        SystemInfoView()
            .environmentObject(LocalizationManager())
    }
}
