import Foundation
import UIKit

class Payment: NSObject, NSCoding {

    var name: String
    var value: Double
    var type: String
    var date: NSDate

    init(name: String, value: Double, type: String, date: NSDate) {
        self.name = name
        self.value = value
        self.type = type
        self.date = date
    }

    required init(coder: NSCoder) {
        self.name = coder.decodeObjectForKey("paymentName") as! String
        self.value = coder.decodeDoubleForKey("paymentValue")
        self.type = coder.decodeObjectForKey("paymentType") as! String
        self.date = coder.decodeObjectForKey("paymentDate") as! NSDate
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.name, forKey: "paymentName")
        coder.encodeDouble(self.value, forKey: "paymentValue")
        coder.encodeObject(self.type, forKey: "paymentType")
        coder.encodeObject(self.date, forKey: "paymentDate")
    }
}
