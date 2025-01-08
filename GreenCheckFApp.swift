import SwiftUI

@main
struct GreenCheckFApp: App {
    
    // Bridge the traditional AppDelegate into SwiftUI's lifecycle
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}
