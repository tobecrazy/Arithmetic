import SwiftUI

struct AboutAppView: View {
    @Environment(\.presentationMode) var presentationMode
    
    var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "N/A"
    }
    
    var buildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "N/A"
    }
    
    var gitCommitHash: String {
        // This information should be injected at build time.
        // Add a build script to your Xcode project:
        //
        // SCRIPT_PATH="${TARGET_BUILD_DIR}/${UNLOCALIZED_RESOURCES_FOLDER_PATH}"
        // echo "${GIT_COMMIT_HASH}" > "${SCRIPT_PATH}/git_commit.txt"
        //
        // Then, add `git_commit.txt` to your project and bundle resources.
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
        VStack(alignment: .leading, spacing: 20) {
            HStack {
                Spacer()
                VStack {
                    Image("logo")
                        .resizable()
                        .frame(width: 100, height: 100)
                        .cornerRadius(20)
                    Text("Arithmetic")
                        .font(.largeTitle)
                }
                Spacer()
            }

            Text("Version: \(appVersion) (\(buildNumber))")
                .font(.headline)
            
            VStack(alignment: .leading) {
                Text("Latest Commit:")
                    .font(.headline)
                Text("Hash: \(gitCommitHash)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                Text("Message: \(gitCommitMessage)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
        }
        .padding()
        .navigationTitle("about.arithmetic.title".localized)
        .navigationBarItems(trailing: Button("Done") {
            presentationMode.wrappedValue.dismiss()
        })
    }
}

struct AboutAppView_Previews: PreviewProvider {
    static var previews: some View {
        AboutAppView()
    }
}
