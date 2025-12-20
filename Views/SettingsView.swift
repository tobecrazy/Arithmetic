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
                
                //add section button
                Section(header: Text("Crash Test".localized)) {
                    Button("Genrate App Crash") {
                      fatalError("Crash was triggered")
                    }
                }

                Section(header: Text("settings.info".localized)) {
                    NavigationLink(
                        destination: aboutMeDestination,
                        isActive: $navigateToAboutMe
                    ) {
                        HStack {
                            Image(systemName: "person.circle.fill")
                                .foregroundColor(.purple)
                            Text("button.about_me".localized)
                        }
                    }

                    NavigationLink(
                        destination: systemInfoDestination,
                        isActive: $navigateToSystemInfo
                    ) {
                        HStack {
                            Image(systemName: "info.circle")
                                .foregroundColor(.red)
                            Text("system.info.title".localized)
                        }
                    }

                    NavigationLink(
                        destination: qrCodeToolDestination,
                        isActive: $navigateToQrCodeTool
                    ) {
                        HStack {
                            Image(systemName: "qrcode")
                                .foregroundColor(.blue)
                            Text("qr_code.tool.title".localized)
                        }
                    }
                }
            }
            .navigationTitle("settings.title".localized)
            .navigationBarItems(trailing: Button("Done") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocalizationManager())
    }
}
