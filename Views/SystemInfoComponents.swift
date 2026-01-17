//
//  SystemInfoComponents.swift
//  Arithmetic
//
import SwiftUI

// MARK: - Animated Gradient Background
struct TechGradientBackground: View {
    let colors: [Color]
    @State private var animateGradient = false

    var body: some View {
        LinearGradient(
            colors: colors,
            startPoint: animateGradient ? .topLeading : .bottomLeading,
            endPoint: animateGradient ? .bottomTrailing : .topTrailing
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 3).repeatForever(autoreverses: true)) {
                animateGradient.toggle()
            }
        }
    }
}

// MARK: - Glowing Icon
struct GlowingIcon: View {
    let systemName: String
    let color: Color
    let size: CGFloat
    @State private var isGlowing = false

    var body: some View {
        ZStack {
            // Outer glow
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundColor(color)
                .blur(radius: isGlowing ? 8 : 4)
                .opacity(isGlowing ? 0.8 : 0.4)

            // Inner icon
            Image(systemName: systemName)
                .font(.system(size: size))
                .foregroundColor(color)
        }
        .frame(width: size + 16, height: size + 16)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                isGlowing.toggle()
            }
        }
    }
}

// MARK: - Circular Progress Ring
struct CircularProgressRing: View {
    let progress: Double
    let color: Color
    let lineWidth: CGFloat

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            // Background ring
            Circle()
                .stroke(color.opacity(0.2), lineWidth: lineWidth)

            // Progress ring
            Circle()
                .trim(from: 0, to: animatedProgress / 100)
                .stroke(
                    AngularGradient(
                        colors: [color.opacity(0.5), color, color.opacity(0.8)],
                        center: .center
                    ),
                    style: StrokeStyle(lineWidth: lineWidth, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Tech Card Container
struct TechCard<Content: View>: View {
    let content: Content
    let accentColor: Color

    init(accentColor: Color = .blue, @ViewBuilder content: () -> Content) {
        self.accentColor = accentColor
        self.content = content()
    }

    var body: some View {
        content
            .padding(.vertical, 12)
            .padding(.horizontal, 16)
            .background(
                ZStack {
                    // Glass background
                    RoundedRectangle(cornerRadius: 16)
                        .fill(.ultraThinMaterial)

                    // Border glow
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(
                            LinearGradient(
                                colors: [accentColor.opacity(0.6), accentColor.opacity(0.1), accentColor.opacity(0.3)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                }
            )
            .shadow(color: accentColor.opacity(0.15), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Animated Value Display
struct AnimatedValueText: View {
    let value: String
    let color: Color
    @State private var opacity: Double = 0.7

    var body: some View {
        Text(value)
            .font(.adaptiveBody())
            .fontWeight(.semibold)
            .foregroundColor(color)
            .opacity(opacity)
            .onAppear {
                withAnimation(.easeInOut(duration: 0.8).repeatForever(autoreverses: true)) {
                    opacity = 1.0
                }
            }
    }
}

// MARK: - System Info Row Component
struct SystemInfoRow: View {
    let title: String
    let value: String
    let icon: String
    var isRealTime: Bool = false
    var accentColor: Color = .cyan

    var body: some View {
        TechCard(accentColor: accentColor) {
            VStack(alignment: .leading, spacing: 10) {
                // Header row with icon and title
                HStack(spacing: 12) {
                    GlowingIcon(systemName: icon, color: accentColor, size: 18)

                    Text(title)
                        .font(.adaptiveBody())
                        .fontWeight(.medium)
                        .foregroundColor(.primary)

                    Spacer()
                }

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [accentColor.opacity(0.3), accentColor.opacity(0.05), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)

                // Value row
                HStack {
                    Spacer()

                    if isRealTime {
                        AnimatedValueText(value: value, color: accentColor)
                            .font(.system(.body, design: .monospaced))
                    } else {
                        Text(value)
                            .font(.system(.body, design: .monospaced))
                            .fontWeight(.semibold)
                            .foregroundColor(accentColor.opacity(0.9))
                            .multilineTextAlignment(.trailing)
                            .lineLimit(2)
                            .minimumScaleFactor(0.8)
                    }
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(accentColor.opacity(0.06))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(accentColor.opacity(0.12), lineWidth: 0.5)
                )
            }
        }
    }
}

// MARK: - System Info Progress Row Component
struct SystemInfoProgressRow: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color

    @State private var animatedValue: Double = 0

    var body: some View {
        TechCard(accentColor: color) {
            VStack(spacing: 14) {
                // Header row
                HStack(spacing: 12) {
                    // Circular progress indicator with icon
                    ZStack {
                        CircularProgressRing(progress: value, color: color, lineWidth: 4)
                            .frame(width: 48, height: 48)

                        GlowingIcon(systemName: icon, color: color, size: 16)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text(title)
                            .font(.adaptiveBody())
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("system.info.realtime_monitoring".localized)
                            .font(.adaptiveCaption())
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Value display with badge style
                    HStack(alignment: .firstTextBaseline, spacing: 2) {
                        Text(String(format: "%.1f", animatedValue))
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(color)

                        Text(unit)
                            .font(.system(.caption, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(color.opacity(0.7))
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(color.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                }

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.3), color.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)

                // Progress bar section
                VStack(alignment: .leading, spacing: 8) {
                    // Linear progress bar with gradient
                    GeometryReader { geometry in
                        ZStack(alignment: .leading) {
                            // Background track
                            RoundedRectangle(cornerRadius: 5)
                                .fill(color.opacity(0.12))
                                .frame(height: 10)

                            // Progress fill
                            RoundedRectangle(cornerRadius: 5)
                                .fill(
                                    LinearGradient(
                                        colors: [color.opacity(0.5), color, color.opacity(0.8)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: max(0, geometry.size.width * (animatedValue / 100)), height: 10)
                                .shadow(color: color.opacity(0.5), radius: 4, x: 0, y: 0)

                            // Glow dot at progress end
                            if animatedValue > 0 {
                                Circle()
                                    .fill(color)
                                    .frame(width: 10, height: 10)
                                    .shadow(color: color, radius: 5, x: 0, y: 0)
                                    .offset(x: max(0, geometry.size.width * (animatedValue / 100) - 5))
                            }
                        }
                    }
                    .frame(height: 10)

                    // Scale markers
                    HStack {
                        Text("0%")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("50%")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)

                        Spacer()

                        Text("100%")
                            .font(.system(.caption2, design: .monospaced))
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedValue = value
            }
        }
        .onChange(of: value) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedValue = newValue
            }
        }
    }
}

// MARK: - Detail Info Item Row
struct DetailInfoItemRow: View {
    let label: String
    let value: String
    let color: Color
    let isLast: Bool

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .center, spacing: 8) {
                // Label with dot indicator
                HStack(spacing: 6) {
                    Circle()
                        .fill(color.opacity(0.6))
                        .frame(width: 4, height: 4)

                    Text(label)
                        .font(.adaptiveCaption())
                        .foregroundColor(.secondary)
                        .lineLimit(1)
                }

                Spacer()

                // Value with styled background
                Text(value)
                    .font(.system(.caption, design: .monospaced))
                    .fontWeight(.semibold)
                    .foregroundColor(.primary)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(
                        RoundedRectangle(cornerRadius: 6)
                            .fill(color.opacity(0.08))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(color.opacity(0.15), lineWidth: 0.5)
                    )
            }
            .padding(.vertical, 8)

            // Separator line (except for last item)
            if !isLast {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.2), color.opacity(0.05), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 0.5)
                    .padding(.leading, 10)
            }
        }
    }
}

// MARK: - Detail Info Section
struct DetailInfoSection: View {
    let title: String
    let icon: String
    let color: Color
    let items: [(String, String)]
    var showProgressBar: Bool = false
    var progressValue: Double = 0

    @State private var animatedProgress: Double = 0

    var body: some View {
        TechCard(accentColor: color) {
            VStack(alignment: .leading, spacing: 14) {
                // Header
                HStack(spacing: 12) {
                    GlowingIcon(systemName: icon, color: color, size: 18)

                    Text(title)
                        .font(.adaptiveBody())
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Spacer()

                    if showProgressBar {
                        // Percentage badge
                        HStack(spacing: 4) {
                            Text(String(format: "%.1f", animatedProgress))
                                .font(.system(.caption, design: .monospaced))
                                .fontWeight(.bold)
                                .foregroundColor(color)
                            Text("%")
                                .font(.system(.caption2, design: .monospaced))
                                .foregroundColor(color.opacity(0.7))
                        }
                        .padding(.horizontal, 10)
                        .padding(.vertical, 5)
                        .background(
                            Capsule()
                                .fill(color.opacity(0.12))
                        )
                        .overlay(
                            Capsule()
                                .stroke(color.opacity(0.3), lineWidth: 1)
                        )
                    }
                }

                // Progress bar if enabled
                if showProgressBar {
                    VStack(spacing: 6) {
                        // Progress bar with animated fill
                        GeometryReader { geometry in
                            ZStack(alignment: .leading) {
                                // Background track
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(color.opacity(0.1))
                                    .frame(height: 8)

                                // Progress fill with gradient
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [color.opacity(0.5), color, color.opacity(0.8)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: max(0, geometry.size.width * (animatedProgress / 100)), height: 8)
                                    .shadow(color: color.opacity(0.4), radius: 3, x: 0, y: 0)

                                // Glow effect at progress end
                                if animatedProgress > 0 {
                                    Circle()
                                        .fill(color)
                                        .frame(width: 8, height: 8)
                                        .shadow(color: color, radius: 4, x: 0, y: 0)
                                        .offset(x: max(0, geometry.size.width * (animatedProgress / 100) - 4))
                                }
                            }
                        }
                        .frame(height: 8)
                    }
                }

                // Divider with gradient
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.4), color.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                // Detail items with improved layout
                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        DetailInfoItemRow(
                            label: item.0,
                            value: item.1,
                            color: color,
                            isLast: index == items.count - 1
                        )
                    }
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 1.0)) {
                animatedProgress = progressValue
            }
        }
        .onChange(of: progressValue) { newValue in
            withAnimation(.easeOut(duration: 0.5)) {
                animatedProgress = newValue
            }
        }
    }
}

// MARK: - Real-time Clock Display
struct RealtimeClockDisplay: View {
    let date: String
    let time: String
    let color: Color

    @State private var pulseAnimation = false
    @State private var colonVisible = true

    var body: some View {
        TechCard(accentColor: color) {
            VStack(spacing: 14) {
                // Header
                HStack(spacing: 12) {
                    // Animated clock icon
                    ZStack {
                        Circle()
                            .stroke(color.opacity(0.2), lineWidth: 2)
                            .frame(width: 44, height: 44)

                        Circle()
                            .stroke(color.opacity(0.6), lineWidth: 2)
                            .frame(width: 44, height: 44)
                            .scaleEffect(pulseAnimation ? 1.15 : 1.0)
                            .opacity(pulseAnimation ? 0.3 : 0.8)

                        GlowingIcon(systemName: "clock.fill", color: color, size: 18)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("system.info.current_time".localized)
                            .font(.adaptiveBody())
                            .fontWeight(.semibold)
                            .foregroundColor(.primary)

                        Text("system.info.realtime".localized)
                            .font(.adaptiveCaption())
                            .foregroundColor(.secondary)
                    }

                    Spacer()

                    // Live indicator
                    HStack(spacing: 4) {
                        Circle()
                            .fill(Color.green)
                            .frame(width: 6, height: 6)
                            .opacity(pulseAnimation ? 1.0 : 0.5)

                        Text("system.info.live".localized)
                            .font(.system(.caption2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(.green)
                    }
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(
                        Capsule()
                            .fill(Color.green.opacity(0.1))
                    )
                }
                .onAppear {
                    withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                        pulseAnimation.toggle()
                    }
                }

                // Divider
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [color.opacity(0.4), color.opacity(0.1), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                // Date and Time Display
                HStack(spacing: 16) {
                    // Date display
                    VStack(alignment: .leading, spacing: 4) {
                        Text("system.info.date".localized)
                            .font(.adaptiveCaption())
                            .foregroundColor(.secondary)

                        Text(date)
                            .font(.system(.callout, design: .monospaced))
                            .fontWeight(.medium)
                            .foregroundColor(.primary)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.06))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.15), lineWidth: 0.5)
                    )

                    Spacer()

                    // Time display with glowing effect
                    VStack(alignment: .trailing, spacing: 4) {
                        Text("system.info.time".localized)
                            .font(.adaptiveCaption())
                            .foregroundColor(.secondary)

                        Text(time)
                            .font(.system(.title2, design: .monospaced))
                            .fontWeight(.bold)
                            .foregroundColor(color)
                            .shadow(color: color.opacity(0.4), radius: 6, x: 0, y: 0)
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(
                        RoundedRectangle(cornerRadius: 8)
                            .fill(color.opacity(0.1))
                    )
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(color.opacity(0.25), lineWidth: 1)
                    )
                }
            }
        }
    }
}

// MARK: - Section Header
struct TechSectionHeader: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(spacing: 8) {
            HStack {
                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.clear, .cyan.opacity(0.5)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)

                Text(title)
                    .font(.adaptiveTitle())
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                Rectangle()
                    .fill(
                        LinearGradient(
                            colors: [.cyan.opacity(0.5), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(height: 1)
            }

            Text(subtitle)
                .font(.adaptiveBody())
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding(.horizontal)
    }
}

// MARK: - Preview
struct SystemInfoComponents_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: 16) {
                TechSectionHeader(
                    title: "System Info",
                    subtitle: "Real-time device monitoring"
                )

                SystemInfoRow(
                    title: "Device Name",
                    value: "iPhone 15 Pro",
                    icon: "iphone",
                    accentColor: .cyan
                )

                SystemInfoRow(
                    title: "Current Time",
                    value: "2:30 PM",
                    icon: "clock",
                    isRealTime: true,
                    accentColor: .blue
                )

                SystemInfoProgressRow(
                    title: "CPU Usage",
                    value: 45.5,
                    unit: "%",
                    icon: "cpu",
                    color: .orange
                )

                DetailInfoSection(
                    title: "Memory Usage",
                    icon: "memorychip",
                    color: .green,
                    items: [
                        ("Used", "4.2 GB"),
                        ("Total", "8.0 GB"),
                        ("Available", "3.8 GB")
                    ],
                    showProgressBar: true,
                    progressValue: 52.5
                )

                RealtimeClockDisplay(
                    date: "2024-01-15",
                    time: "14:30:25",
                    color: .blue
                )
            }
            .padding()
        }
        .background(Color(.systemBackground))
        .previewLayout(.sizeThatFits)
    }
}
