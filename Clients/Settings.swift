import Foundation
import UIKit
import ChameleonFramework

class Settings {
    
    private static let themeColorKey = "themeColorKey"
    private static let enabledMileageKey = "enabledMileage"
    
    static var enabledMileage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: enabledMileageKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledMileageKey)
        }
    }
    
    static var themeColor: UIColor {
        get {
            return UIColor(hexString: UserDefaults.standard.string(forKey: themeColorKey)!)!
        }
        set {
            UserDefaults.standard.set(newValue.hexValue(), forKey: themeColorKey)
        }
    }
    
    static func colorUI() {
        let ui = UINavigationBar.appearance()
        ui.backgroundColor = themeColor
        ui.barTintColor = themeColor
    }
    
    static func firstRun() {
        let launchKey = "previouslyLaunched"
        if !UserDefaults.standard.bool(forKey: launchKey) {
            UserDefaults.standard.set(true, forKey: launchKey)
            
            enabledMileage = true
            themeColor = .flatOrange
        }
    }
}
