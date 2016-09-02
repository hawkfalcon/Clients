import UIKit

class Mileage: NSObject, NSCoding {

    let miles: Double
    let date: Date

    init(miles: Double, date: Date) {
        self.miles = miles
        self.date = date
    }

    required init(coder: NSCoder) {
        self.miles = coder.decodeDouble(forKey: "miles")
        self.date = coder.decodeObject(forKey: "date") as! Date
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.miles, forKey: "miles")
        coder.encode(self.date, forKey: "date")
    }
}
