//
//  ArithmeticApp.swift
//  Arithmetic
//
import SwiftUI
import CoreData

@main
struct ArithmeticApp: App {
    // 初始化CoreData管理器
    private let coreDataManager = CoreDataManager.shared
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager())
                .environment(\.managedObjectContext, coreDataManager.context)
                .onAppear {
                    // Check if this is the first time the app is launched
                    if !UserDefaults.standard.bool(forKey: "HasLaunchedBefore") {
                        UserDefaults.standard.set(true, forKey: "HasLaunchedBefore")
                    }
                }
        }
    }
}
