import SwiftUI

@main
struct CityMoodApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(MoodStore())
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
