import Foundation
import UIKit

class Payment: NSObject, NSCoding {

    var name: String
    var value: Double
    var type: String
    var date: Date

    init(name: String, value: Double, type: String, date: Date) {
        self.name = name
        self.value = value
        self.type = type
        self.date = date
    }

    required init(coder: NSCoder) {
        self.name = coder.decodeObject(forKey: "paymentName") as! String
        self.value = coder.decodeDouble(forKey: "paymentValue")
        self.type = coder.decodeObject(forKey: "paymentType") as! String
        self.date = coder.decodeObject(forKey: "paymentDate") as! Date
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.name, forKey: "paymentName")
        coder.encode(self.value, forKey: "paymentValue")
        coder.encode(self.type, forKey: "paymentType")
        coder.encode(self.date, forKey: "paymentDate")
    }
}
