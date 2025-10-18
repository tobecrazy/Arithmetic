//
//  SystemInfoComponents.swift
//  Arithmetic
//
import SwiftUI

// MARK: - System Info Row Component
struct SystemInfoRow: View {
    let title: String
    let value: String
    let icon: String
    var isRealTime: Bool = false
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(isRealTime ? .blue : .primary)
                .frame(width: 20)
            
            Text(title)
                .font(.adaptiveBody())
                .fontWeight(.medium)
            
            Spacer()
            
            Text(value)
                .font(.adaptiveBody())
                .fontWeight(.medium)
                .foregroundColor(isRealTime ? .blue : .secondary)
                .multilineTextAlignment(.trailing)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - System Info Progress Row Component
struct SystemInfoProgressRow: View {
    let title: String
    let value: Double
    let unit: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundColor(color)
                    .frame(width: 20)
                Text(title)
                    .font(.adaptiveBody())
                    .fontWeight(.medium)
                Spacer()
                Text(String(format: "%.1f%@", value, unit))
                    .font(.adaptiveBody())
                    .fontWeight(.medium)
                    .foregroundColor(color)
            }
            
            ProgressView(value: value, total: 100)
                .progressViewStyle(LinearProgressViewStyle(tint: color))
                .scaleEffect(x: 1, y: 0.8, anchor: .center)
        }
        .padding(.vertical, 8)
        .padding(.horizontal, 16)
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}

// MARK: - Preview
struct SystemInfoComponents_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            SystemInfoRow(
                title: "Device Name",
                value: "iPhone 15 Pro",
                icon: "iphone"
            )
            
            SystemInfoRow(
                title: "Current Time",
                value: "2:30 PM",
                icon: "clock",
                isRealTime: true
            )
            
            SystemInfoProgressRow(
                title: "CPU Usage",
                value: 25.5,
                unit: "%",
                icon: "speedometer",
                color: .orange
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
