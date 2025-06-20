import SwiftUI

struct DeviceUtils {
    static var isIPad: Bool {
        return UIDevice.current.userInterfaceIdiom == .pad
    }
    
    static func isLandscape(with sizeClass: (horizontal: UserInterfaceSizeClass?, vertical: UserInterfaceSizeClass?)) -> Bool {
        return sizeClass.horizontal == .regular && sizeClass.vertical == .regular
    }
}
