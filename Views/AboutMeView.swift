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
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image section with CachedAsyncImageView
                VStack {
                    CachedAsyncImageView(
                        url: URL(string: "https://images.cnblogs.com/cnblogs_com/tobecrazy/432338/o_250810143405_Card.png"),
                        placeholder: Image(systemName: "person.circle.fill")
                    )
                    .frame(maxWidth: 300, maxHeight: 200)
                    .cornerRadius(.adaptiveCornerRadius)
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

struct AboutMeView_Previews: PreviewProvider {
    static var previews: some View {
        AboutMeView()
            .environmentObject(LocalizationManager())
    }
}
