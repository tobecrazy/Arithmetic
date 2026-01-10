import SwiftUI

struct SettingsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isTtsEnabled") private var isTtsEnabled = true
    @AppStorage("followSystem") private var followSystem = true

    @State private var navigateToAboutMe = false
    @State private var navigateToSystemInfo = false
    @State private var navigateToQrCodeTool = false
    @State private var navigateToAboutApp = false

    private var aboutMeDestination: some View {
        AboutMeView()
            .environmentObject(localizationManager)
    }

    private var systemInfoDestination: some View {
        SystemInfoView()
            .environmentObject(localizationManager)
    }

    private var qrCodeToolDestination: some View {
        QrCodeToolView()
            .environmentObject(localizationManager)
    }

    private var aboutAppDestination: some View {
        AboutAppView()
            .environmentObject(localizationManager)
    }

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("settings.display".localized)) {
                    Toggle(isOn: $followSystem) {
                        Text("settings.follow_system".localized)
                    }
                    if !followSystem {
                        Toggle(isOn: $isDarkMode) {
                            Text("settings.dark_mode".localized)
                        }
                    }
                }
                Section(header: Text("settings.audio".localized)) {
                    Toggle(isOn: $isTtsEnabled) {
                        Text("settings.auto_read".localized)
                    }
                }
                
                Section(header: Text("crash.test.title".localized)) {
                    Button("crash.test.button".localized) {
                      fatalError("Crash was triggered")
                    }
                }

                Section(header: Text("settings.info".localized)) {
                    Button(action: { navigateToAboutMe = true }) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.purple)
                            Text("button.about_me".localized)
                        }
                    }
                    .buttonStyle(PlainButtonStyle()) // To make the button behave like a NavigationLink visualy

                    Button(action: { navigateToSystemInfo = true }) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.red)
                            Text("system.info.title".localized)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { navigateToQrCodeTool = true }) {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundColor(.blue)
                            Text("qr_code.tool.title".localized)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())

                    Button(action: { navigateToAboutApp = true }) {
                        HStack {
                            Image(systemName: "info.circle.fill")
                                .foregroundColor(.green)
                            Text("about.arithmetic.title".localized)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
            }
            .navigationTitle("settings.title".localized)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .sheet(isPresented: $navigateToAboutMe) {
                NavigationView { // Wrap in NavigationView if the destination view needs a navigation bar
                    aboutMeDestination
                }
            }
            .sheet(isPresented: $navigateToSystemInfo) {
                NavigationView { // Wrap in NavigationView if the destination view needs a navigation bar
                    systemInfoDestination
                }
            }
            .sheet(isPresented: $navigateToQrCodeTool) {
                NavigationView { // Wrap in NavigationView if the destination view needs a navigation bar
                    qrCodeToolDestination
                }
            }
            .sheet(isPresented: $navigateToAboutApp) {
                NavigationView {
                    aboutAppDestination
                }
            }
        }
    }
}

struct AboutAppView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var animateHero = false
    @State private var animateCards = false
    @State private var copiedHashState = false

    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }

    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }

    var gitCommitHash: String {
        gitInfo.hash
    }

    var gitCommitMessage: String {
        gitInfo.message
    }

    private var gitInfo: (hash: String, message: String) {
        if let appVersionURL = Bundle.main.url(forResource: "appversion", withExtension: "txt"),
           let content = try? String(contentsOf: appVersionURL, encoding: .utf8) {
            let components = content.components(separatedBy: "_||_")
            if components.count == 2 {
                let hash = components[0].trimmingCharacters(in: .whitespacesAndNewlines)
                let message = components[1].trimmingCharacters(in: .whitespacesAndNewlines)
                return (hash, message)
            }
        }
        return ("N/A", "N/A")
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color(.systemBackground).ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 28) {
                        // Hero Section
                        HeroHeader(
                            appVersion: appVersion,
                            buildNumber: buildNumber,
                            isAnimating: animateHero
                        )
                        .padding(.top, 20)

                        VStack(spacing: 20) {
                            // Git Details Section
                            VStack(alignment: .leading, spacing: 16) {
                                AboutSectionHeader(
                                    title: "about.app.section.git_details".localized,
                                    icon: "square.and.pencil"
                                )

                                CopyableInfoRow(
                                    label: "about.app.label.hash".localized,
                                    value: gitCommitHash,
                                    isCopied: $copiedHashState
                                )
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 10)

                                InfoCard(
                                    label: "about.app.label.message".localized,
                                    value: gitCommitMessage,
                                    icon: "quote.bubble",
                                    iconColor: .blue
                                )
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 10)
                            }
                            .padding(.horizontal, 16)

                            // About App Description Section
                            VStack(alignment: .leading, spacing: 16) {
                                AboutSectionHeader(
                                    title: "about.app.section.about_app".localized,
                                    icon: "info.circle.fill"
                                )

                                DescriptionCard(
                                    text: "about.app.description".localized
                                )
                                .opacity(animateCards ? 1 : 0)
                                .offset(y: animateCards ? 0 : 10)
                            }
                            .padding(.horizontal, 16)

                            // Acknowledgements Section
                            VStack(alignment: .leading, spacing: 16) {
                                AboutSectionHeader(
                                    title: "about.app.section.acknowledgements".localized,
                                    icon: "heart.fill"
                                )

                                VStack(spacing: 12) {
                                    AccreditationLink(
                                        title: "Firebase",
                                        icon: "flame.fill",
                                        color: .orange,
                                        url: URL(string: "https://firebase.google.com")!
                                    )
                                    .opacity(animateCards ? 1 : 0)
                                    .offset(y: animateCards ? 0 : 10)

                                    AccreditationLink(
                                        title: "SwiftUI",
                                        icon: "swift",
                                        color: .blue,
                                        url: URL(string: "https://developer.apple.com/xcode/swiftui/")!
                                    )
                                    .opacity(animateCards ? 1 : 0)
                                    .offset(y: animateCards ? 0 : 10)
                                }
                            }
                            .padding(.horizontal, 16)

                            Spacer(minLength: 40)
                        }
                        .padding(.vertical, 20)
                    }
                }
            }
            .navigationTitle("about.arithmetic.title".localized)
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                    animateHero = true
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                    withAnimation(.easeInOut(duration: 0.6)) {
                        animateCards = true
                    }
                }
            }
        }
    }
}

// MARK: - Hero Header Component
private struct HeroHeader: View {
    let appVersion: String
    let buildNumber: String
    let isAnimating: Bool

    var body: some View {
        VStack(spacing: 16) {
            Image("logo")
                .resizable()
                .frame(width: 100, height: 100)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.1), radius: 12, x: 0, y: 6)
                .scaleEffect(isAnimating ? 1 : 0.8)
                .opacity(isAnimating ? 1 : 0)

            VStack(spacing: 8) {
                Text("Arithmetic")
                    .font(.adaptiveTitle())
                    .fontWeight(.bold)
                    .foregroundColor(.primary)

                VStack(spacing: 4) {
                    Text("Version \(appVersion)")
                        .font(.adaptiveHeadline())
                        .foregroundColor(.primary)

                    Text("Build \(buildNumber)")
                        .font(.adaptiveCaption())
                        .foregroundColor(.secondary)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(.adaptiveCornerRadius)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 16)
    }
}

// MARK: - About Section Header Component
private struct AboutSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.blue)
                .frame(width: 28, height: 28)
                .background(Color.blue.opacity(0.1))
                .cornerRadius(.adaptiveCornerRadius)

            Text(title)
                .font(.adaptiveHeadline())
                .fontWeight(.semibold)
                .foregroundColor(.primary)

            Spacer()
        }
    }
}

// MARK: - Copyable Info Row Component
private struct CopyableInfoRow: View {
    let label: String
    let value: String
    @Binding var isCopied: Bool
    @State private var showToast = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 8) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)

                Spacer()

                Button(action: copyToClipboard) {
                    HStack(spacing: 6) {
                        Image(systemName: isCopied ? "checkmark" : "doc.on.doc")
                            .font(.system(size: 12, weight: .semibold))
                        Text(isCopied ? "Copied" : "Copy")
                            .font(.caption2)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white)
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(isCopied ? Color.green : Color.blue)
                    .cornerRadius(6)
                }
                .buttonStyle(PlainButtonStyle())
            }

            Text(value)
                .font(.system(.body, design: .monospaced))
                .lineLimit(2)
                .truncationMode(.middle)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.gray.opacity(0.08))
                .cornerRadius(.adaptiveCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                        .stroke(Color.gray.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(.adaptiveCornerRadius * 1.5)
        .overlay(
            RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }

    private func copyToClipboard() {
        UIPasteboard.general.string = value
        isCopied = true

        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isCopied = false
        }
    }
}

// MARK: - Info Card Component
private struct InfoCard: View {
    let label: String
    let value: String
    let icon: String
    let iconColor: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(iconColor)

                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)

                Spacer()
            }

            Text(value)
                .font(.adaptiveBody())
                .lineSpacing(1.2)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color(.systemBackground))
                .cornerRadius(.adaptiveCornerRadius)
                .overlay(
                    RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                        .stroke(iconColor.opacity(0.2), lineWidth: 1)
                )
        }
        .padding(14)
        .background(Color(.systemBackground))
        .cornerRadius(.adaptiveCornerRadius * 1.5)
        .overlay(
            RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                .stroke(Color.gray.opacity(0.15), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Description Card Component
private struct DescriptionCard: View {
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(spacing: 8) {
                Image(systemName: "lightbulb.fill")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.yellow)

                Text("Description")
                    .font(.caption)
                    .foregroundColor(.secondary)
                    .fontWeight(.medium)

                Spacer()
            }

            Text(text)
                .font(.adaptiveBody())
                .lineSpacing(1.5)
                .foregroundColor(.primary)
        }
        .padding(16)
        .background(Color.yellow.opacity(0.08))
        .cornerRadius(.adaptiveCornerRadius * 1.5)
        .overlay(
            RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                .stroke(Color.yellow.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
    }
}

// MARK: - Accreditation Link Component
private struct AccreditationLink: View {
    let title: String
    let icon: String
    let color: Color
    let url: URL

    @State private var isPressed = false

    var body: some View {
        Link(destination: url) {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(width: 36, height: 36)
                    .background(color)
                    .cornerRadius(10)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.adaptiveHeadline())
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)

                    Text("Open official website")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.secondary)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
            }
            .padding(14)
            .background(Color(.systemBackground))
            .cornerRadius(.adaptiveCornerRadius * 1.5)
            .overlay(
                RoundedRectangle(cornerRadius: .adaptiveCornerRadius * 1.5)
                    .stroke(Color.gray.opacity(0.15), lineWidth: 1)
            )
            .shadow(color: Color.black.opacity(0.05), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .onLongPressGesture(minimumDuration: 0.1, perform: {}, onPressingChanged: { pressing in
            withAnimation(.easeInOut(duration: 0.15)) {
                isPressed = pressing
            }
        })
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocalizationManager())
    }
}
