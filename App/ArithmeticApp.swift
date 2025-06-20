//
//  ArithmeticApp.swift
//  Arithmetic
//
import SwiftUI

@main
struct ArithmeticApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(LocalizationManager())
        }
    }
}
