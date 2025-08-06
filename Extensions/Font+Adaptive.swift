import SwiftUI

extension Font {
    static func adaptiveTitle() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .largeTitle : .title
    }
    
    static func adaptiveTitle2() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .title : .title2
    }
    
    static func adaptiveHeadline() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .title : .headline
    }
    
    static func adaptiveBody() -> Font {
        return UIDevice.current.userInterfaceIdiom == .pad ? .title3 : .body
    }
}
