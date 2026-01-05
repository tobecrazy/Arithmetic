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
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
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
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    
    var gitCommitHash: String {
        if let gitCommitURL = Bundle.main.url(forResource: "git_commit", withExtension: "txt"),
           let gitCommit = try? String(contentsOf: gitCommitURL, encoding: .utf8) {
            return gitCommit.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "N/A"
    }

    var gitCommitMessage: String {
        if let gitMessageURL = Bundle.main.url(forResource: "git_message", withExtension: "txt"),
           let gitMessage = try? String(contentsOf: gitMessageURL, encoding: .utf8) {
            return gitMessage.trimmingCharacters(in: .whitespacesAndNewlines)
        }
        return "N/A"
    }

    var body: some View {
        NavigationView {
            Form {
                Section {
                    HStack {
                        Spacer()
                        VStack(spacing: 10) {
                            Image("logo")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .cornerRadius(16)
                                .shadow(radius: 3)
                            Text("Arithmetic")
                                .font(.title)
                                .fontWeight(.bold)
                            Text("Version \(appVersion) (\(buildNumber))")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        Spacer()
                    }
                    .padding(.vertical)
                }
                
                Section(header: Text("about.app.section.git_details".localized)) {
                    InfoRow(label: "about.app.label.hash".localized, value: gitCommitHash)
                    InfoRow(label: "about.app.label.message".localized, value: gitCommitMessage)
                }
                
                Section(header: Text("about.app.section.about_app".localized)) {
                    Text("about.app.description".localized)
                        .font(.body)
                        .padding(.vertical, 5)
                }

                Section(header: Text("about.app.section.acknowledgements".localized)) {
                    Link("Firebase", destination: URL(string: "https://firebase.google.com")!)
                    Link("SwiftUI", destination: URL(string: "https://developer.apple.com/xcode/swiftui/")!)
                }
            }
            .navigationTitle("about.arithmetic.title".localized)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
            Text(value)
                .font(.body)
                .lineLimit(3)
        }
        .padding(.vertical, 4)
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocalizationManager())
    }
}
