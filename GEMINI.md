# GEMINI.md

## Project Overview

This is an iOS application developed using SwiftUI, designed to help elementary school students practice and learn basic arithmetic. The app is named "小学生算术学习应用" (Elementary Arithmetic Learning App) and supports both Chinese and English languages.

The core features of the application include:

*   **Arithmetic Practice:** Six levels of difficulty covering addition, subtraction, multiplication, and division.
*   **Intelligent Question Generation:** The app generates non-repetitive questions and ensures that division problems always have integer results.
*   **Wrong Question Collection:** The app automatically collects and stores questions that the user answers incorrectly, allowing them to practice and improve.
*   **Solution Analysis:** For wrong answers, the app provides a step-by-step solution to help the user understand the correct method.
*   **Bilingual Support:** The app is fully localized in both Chinese and English.
*   **Text-to-Speech (TTS):** The app can read questions and multiplication tables aloud.
*   **Game Progress Saving:** Users can save their progress and resume later.
*   **Multiplication Table:** A 9x9 multiplication table is available as a learning aid.
*   **System Information:** The app displays various system information like battery status, CPU usage, and network status.

The project follows the MVVM (Model-View-ViewModel) architectural pattern.

## Building and Running

To build and run this project, you will need:

*   macOS 12.0+ (Monterey)
*   Xcode 13.0+
*   Swift 5.5+

Follow these steps:

1.  **Clone the repository:**
    ```bash
    git clone https://github.com/tobecrazy/Arithmetic.git
    cd Arithmetic
    ```

2.  **Open the project in Xcode:**
    ```bash
    open Arithmetic.xcodeproj
    ```

3.  **Select a target device:**
    *   Choose an iPhone or iPad simulator, or a physical device.

4.  **Build and run:**
    *   Click the "Run" button in Xcode or press `Cmd+R`.

## Development Conventions

*   **Architecture:** The project uses the MVVM (Model-View-ViewModel) design pattern.
*   **UI:** The user interface is built with SwiftUI.
*   **Data Persistence:** Core Data is used for storing wrong questions and game progress.
*   **Localization:** The app uses the standard iOS localization mechanism, with strings stored in `Localizable.strings` files for English and Chinese.
*   **Dependency Management:** The project does not appear to use any external dependency managers like CocoaPods or Swift Package Manager.
*   **Testing:** There is a `Tests` directory, but it only contains a single `UtilsTests.swift` file, suggesting that testing is not very extensive.
*   **Coding Style:** The code is well-formatted and follows Swift conventions. Comments are used to explain complex logic.
