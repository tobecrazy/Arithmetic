import SwiftUI

extension CGFloat {
    static let adaptivePadding: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 24 : 16
    static let adaptiveCornerRadius: CGFloat = UIDevice.current.userInterfaceIdiom == .pad ? 12 : 8
}
