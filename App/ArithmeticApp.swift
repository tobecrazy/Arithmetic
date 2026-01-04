//
//  ArithmeticApp.swift
//  Arithmetic
//
import SwiftUI
import CoreData
import FirebaseCore
import FirebaseCrashlytics

//initialize Firebase
class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    // Use the Firebase library to configure APIs.
    FirebaseApp.configure()
    Crashlytics.crashlytics().setCrashlyticsCollectionEnabled(true)
    print("Crashlytics initialized.")
    return true
  }
}

@main
struct ArithmeticApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    @AppStorage("isDarkMode") private var isDarkMode = false
    // initialize core data manager
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
