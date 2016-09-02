import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey:Any]?) -> Bool {
        let color = UIColor.orange
        let ui = UINavigationBar.appearance()
        ui.backgroundColor = color
        ui.barTintColor = color
        ui.isTranslucent = false
        ui.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        ui.shadowImage = UIImage()
        ui.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        ui.tintColor = UIColor.white

        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillTerminate(_ application: UIApplication) {
    }
}
