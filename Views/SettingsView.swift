import SwiftUI

struct SettingsView: View {
    @Environment(\.presentationMode) var presentationMode
    @AppStorage("isDarkMode") private var isDarkMode = false
    @AppStorage("isTtsEnabled") private var isTtsEnabled = true

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("settings.display".localized)) {
                    Toggle(isOn: $isDarkMode) {
                        Text("settings.dark_mode".localized)
                    }
                }
                Section(header: Text("settings.audio".localized)) {
                    Toggle(isOn: $isTtsEnabled) {
                        Text("settings.auto_read".localized)
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
