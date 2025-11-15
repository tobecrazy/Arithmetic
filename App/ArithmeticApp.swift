//
//  ArithmeticApp.swift
//  Arithmetic
//
import SwiftUI
import CoreData

@main
struct ArithmeticApp: App {
    @AppStorage("isDarkMode") private var isDarkMode = false
    // 初始化CoreData管理器
    private let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager())
                .environment(\.managedObjectContext, coreDataManager.context)
                .onAppear {
                    // Check if this is the first time the app is launched
                    // The welcome screen will handle setting the HasLaunchedBefore flag when dismissed
                }
        }
    }
}
