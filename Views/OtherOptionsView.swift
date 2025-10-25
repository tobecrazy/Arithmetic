import SwiftUI

struct OtherOptionsView: View {
    @EnvironmentObject var localizationManager: LocalizationManager
    @Environment(\.presentationMode) var presentationMode
    @Environment(\.horizontalSizeClass) var horizontalSizeClass
    @Environment(\.verticalSizeClass) var verticalSizeClass
    
    @State private var navigateToMultiplicationTable = false
    @State private var navigateToAboutMe = false
    @State private var navigateToFormulaGuide = false
    @State private var navigateToSystemInfo = false
    
    // Computed properties for navigation destinations
    private var multiplicationTableDestination: some View {
        MultiplicationTableView()
            .environmentObject(localizationManager)
    }
    
    private var aboutMeDestination: some View {
        AboutMeView()
            .environmentObject(localizationManager)
    }

    private var formulaGuideDestination: some View {
        FormulaGuideView()
            .environmentObject(localizationManager)
    }

    private var systemInfoDestination: some View {
        SystemInfoView()
            .environmentObject(localizationManager)
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Text("other_options.title".localized)
                    .font(.adaptiveTitle())
                    .padding()
                
                // 9×9乘法表按钮
                Button(action: {
                    navigateToMultiplicationTable = true
                }) {
                    HStack {
                        Image(systemName: "grid.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("button.multiplication_table".localized)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.white)
                            
                            Text("multiplication_table.instructions".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.green)
                    .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)

                // 公式大全按钮
                Button(action: {
                    navigateToFormulaGuide = true
                }) {
                    HStack {
                        Image(systemName: "function")
                            .font(.title2)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("button.formula_guide".localized)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.white)

                            Text("formula_guide_desc".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)

                // 关于我按钮
                Button(action: {
                    navigateToAboutMe = true
                }) {
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .font(.title2)
                            .foregroundColor(.white)
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("button.about_me".localized)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.white)
                            
                            Text("about.content".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }
                        
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.purple)
                    .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)

                // 系统信息按钮
                Button(action: {
                    navigateToSystemInfo = true
                }) {
                    HStack {
                        Image(systemName: "info.circle")
                            .font(.title2)
                            .foregroundColor(.white)

                        VStack(alignment: .leading, spacing: 4) {
                            Text("system.info.title".localized)
                                .font(.adaptiveHeadline())
                                .foregroundColor(.white)

                            Text("system.info.description".localized)
                                .font(.adaptiveBody())
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.leading)
                                .lineLimit(2)
                        }

                        Spacer()

                        Image(systemName: "chevron.right")
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding()
                    .background(Color.red.opacity(0.6))
                    .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)

                Spacer(minLength: 50)
                
                // 返回主页按钮
                Button(action: {
                    presentationMode.wrappedValue.dismiss()
                }) {
                    Text("other_options.back".localized)
                        .font(.adaptiveBody())
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.gray.opacity(0.2))
                        .foregroundColor(.primary)
                        .cornerRadius(.adaptiveCornerRadius)
                }
                .padding(.horizontal)
                .padding(.bottom, 30)
                
                // Navigation Links
                NavigationLink(
                    destination: multiplicationTableDestination,
                    isActive: $navigateToMultiplicationTable
                ) {
                    EmptyView()
                }
                
                NavigationLink(
                    destination: aboutMeDestination,
                    isActive: $navigateToAboutMe
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: formulaGuideDestination,
                    isActive: $navigateToFormulaGuide
                ) {
                    EmptyView()
                }

                NavigationLink(
                    destination: systemInfoDestination,
                    isActive: $navigateToSystemInfo
                ) {
                    EmptyView()
                }
            }
        }
        .navigationTitle("other_options.title".localized)
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

struct OtherOptionsView_Previews: PreviewProvider {
    static var previews: some View {
        OtherOptionsView()
            .environmentObject(LocalizationManager())
    }
}
