import Foundation

class Category: NSObject, NSCoding {
    
    var total: Double
    var payments: [Payment]

    init(total: Double, payments: [Payment]) {
        self.total = total
        self.payments = payments
    }
    
    required init(coder: NSCoder) {
        self.total = coder.decodeDoubleForKey("total")
        self.payments = coder.decodeObjectForKey("payments") as! [Payment]

        super.init()
    }
    
    func owed() -> Double {
        var owed = total
        for payment in payments {
            owed -= payment.value
        }
        return owed
    }
    
    func received() -> Double {
        var received = 0.0
        for payment in payments {
            received += payment.value
        }
        return received
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeDouble(self.total, forKey: "total")
        coder.encodeObject(self.payments, forKey: "payments")
    }
}