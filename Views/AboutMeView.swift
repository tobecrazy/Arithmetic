//
//  AboutMeView.swift
//  Arithmetic
//
import SwiftUI

struct AboutMeView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Image section with AsyncImage
                VStack {
                    AsyncImage(url: URL(string: "https://images2015.cnblogs.com/blog/418763/201610/418763-20161014225758390-402578379.gif")) { image in
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(maxWidth: 300, maxHeight: 200)
                            .cornerRadius(.adaptiveCornerRadius)
                    } placeholder: {
                        // Placeholder while loading
                        Image(systemName: "person.circle.fill")
                            .font(.system(size: 100))
                            .foregroundColor(.gray.opacity(0.5))
                            .frame(maxWidth: 300, maxHeight: 200)
                            .background(
                                RoundedRectangle(cornerRadius: .adaptiveCornerRadius)
                                    .fill(Color.gray.opacity(0.1))
                            )
                    }
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
                }
                .padding(.vertical, 20)
                
                Spacer(minLength: 50)
            }
            .padding()
        }
        .navigationTitle("about.page_title".localized)
        .navigationBarTitleDisplayMode(.large)
    }
}

struct AboutMeView_Previews: PreviewProvider {
    static var previews: some View {
        AboutMeView()
            .environmentObject(LocalizationManager())
    }
}
