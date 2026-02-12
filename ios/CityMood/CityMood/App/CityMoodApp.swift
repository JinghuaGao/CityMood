import SwiftUI

@main
struct CityMoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @State private var showMainApp = false
    
    var body: some Scene {
        WindowGroup {
            if showMainApp {
                ContentView()
                    .environmentObject(MoodStore())
            } else {
                InspirationalSplashView(onComplete: {
                    withAnimation(.easeInOut(duration: 0.8)) {
                        showMainApp = true
                    }
                })
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        // 初始化配置
        setupAppearance()
        return true
    }
    
    private func setupAppearance() {
        // 设置全局样式
        UINavigationBar.appearance().tintColor = .systemBlue
    }
}
