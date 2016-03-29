import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject:AnyObject]?) -> Bool {
        let color = UIColor.orangeColor()
        let ui = UINavigationBar.appearance()
        ui.backgroundColor = color
        ui.barTintColor = color
        ui.translucent = false
        ui.setBackgroundImage(UIImage(), forBarMetrics: UIBarMetrics.Default)
        ui.shadowImage = UIImage()
        ui.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        ui.tintColor = UIColor.whiteColor()

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
    }

    func applicationDidEnterBackground(application: UIApplication) {
    }

    func applicationWillEnterForeground(application: UIApplication) {
    }

    func applicationDidBecomeActive(application: UIApplication) {
    }

    func applicationWillTerminate(application: UIApplication) {
    }
}
