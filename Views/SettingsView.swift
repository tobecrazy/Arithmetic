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
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsView()
            .environmentObject(LocalizationManager())
    }
}
