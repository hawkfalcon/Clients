import Foundation
import UIKit

class Section: NSObject, NSCoding {

    let name: String
    var value: Double
    var color: UIColor

    init(name: String, value: Double, color: UIColor) {
        self.name = name
        self.value = value
        self.color = color
    }

    convenience init(name: String, value: Double) {
        self.init(name: name, value: value, color: UIColor.blackColor())
    }

    required init(coder: NSCoder) {
        self.name = coder.decodeObjectForKey("name") as! String
        self.value = coder.decodeDoubleForKey("value")
        self.color = coder.decodeObjectForKey("color") as! UIColor
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "name")
        coder.encodeDouble(self.value, forKey: "value")
        coder.encodeObject(self.color, forKey: "color")
    }
}
