import UIKit

class Mileage: NSObject, NSCoding {

    let miles: Double
    let date: NSDate

    init(miles: Double, date: NSDate) {
        self.miles = miles
        self.date = date
    }

    required init(coder: NSCoder) {
        self.miles = coder.decodeDoubleForKey("miles")
        self.date = coder.decodeObjectForKey("date") as! NSDate
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(self.miles, forKey: "miles")
        coder.encodeObject(self.date, forKey: "date")
    }
}
