import Foundation

class Category: NSObject, NSCoding {
    
    var total: Double
    var payments: [Payment]

    init(total: Double, payments: [Payment]) {
        self.total = total
        self.payments = payments
    }
    
    required init(coder: NSCoder) {
        self.total = coder.decodeDouble(forKey: "total")
        self.payments = coder.decodeObject(forKey: "payments") as! [Payment]

        super.init()
    }
    
    func owed() -> Double {
        var owed = total
        for payment in payments {
            owed -= payment.value
        }
        return owed
    }
    
    func paid() -> Double {
        var paid = 0.0
        for payment in payments {
            paid += payment.value
        }
        return paid
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.total, forKey: "total")
        coder.encode(self.payments, forKey: "payments")
    }
}
