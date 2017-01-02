import Foundation
import UIKit
import ChameleonFramework

class Settings {

    private static let themeColorKey = "themeColor"
    private static let enabledMileageKey = "enabledMileage"
    private static let defaultPaymentNamesKey = "defaultPaymentNames"
    private static let defaultPaymentTypeKey = "defaultPaymentType"
    private static let defaultCategoriesKey = "defaultCategories"

    static var enabledMileage: Bool {
        get {
            return UserDefaults.standard.bool(forKey: enabledMileageKey)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: enabledMileageKey)
        }
    }

    static var defaultPaymentNames: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: defaultPaymentNamesKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultPaymentNamesKey)
        }
    }
    
    static func updateDefaultPaymentNames(index: Int, paymentName: String) {
        var defaults = defaultPaymentNames
        defaults[index] = paymentName
        defaultPaymentNames = defaults
    }


    static var defaultPaymentType: String {
        get {
            return UserDefaults.standard.string(forKey: defaultPaymentTypeKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultPaymentTypeKey)
        }
    }

    static var defaultCategories: [String] {
        get {
            return UserDefaults.standard.stringArray(forKey: defaultCategoriesKey)!
        }
        set {
            UserDefaults.standard.set(newValue, forKey: defaultCategoriesKey)
        }
    }

    static func updateDefaultCategories(index: Int, category: String) {
        var defaults = defaultCategories
        defaults[index] = category
        defaultCategories = defaults
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
        if !UserDefaults.standard.bool(forKey: launchKey) || UserDefaults.standard.object(forKey: defaultPaymentNamesKey) == nil {
            UserDefaults.standard.set(true, forKey: launchKey)

            enabledMileage = true
            themeColor = .flatOrange

            defaultPaymentType = "Check"

            defaultPaymentNames = ["Down", "Intermediate", "Final"]
            defaultCategories = ["Contract", "Consultation", "Time and Materials"]
        }
    }
}
