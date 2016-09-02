import Contacts

class Client: NSObject, NSCoding {
    var contact: CNContact
    
    var categories: [String:Category]

    var mileage: [Mileage]
    var notes: String
    let timestamp: Date

    init(contact: CNContact, categories: [String:Category], mileage: [Mileage], notes: String, timestamp: Date) {
        self.contact = contact
        self.categories = categories
        self.timestamp = timestamp
        self.notes = notes
        self.mileage = mileage
    }

    required init(coder: NSCoder) {
        var contact = CNContact()
        do {
            let identifier = coder.decodeObject(forKey: "contact") as! String
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactIdentifierKey]
            contact = try CNContactStore().unifiedContact(withIdentifier: identifier, keysToFetch: keysToFetch as [CNKeyDescriptor])
            print("Loaded contact \(contact.givenName) \(contact.familyName)")
        } catch {
            print("Unable to load a contact")
        }
        self.contact = contact
        self.categories = coder.decodeObject(forKey: "categories") as! [String:Category]
        self.mileage = coder.decodeObject(forKey: "mileage") as! [Mileage]
        self.notes = coder.decodeObject(forKey: "notes") as! String
        self.timestamp = coder.decodeObject(forKey: "timestamp") as! Date

        super.init()
    }

    func encode(with coder: NSCoder) {
        coder.encode(self.contact.identifier, forKey: "contact")
        coder.encode(self.categories, forKey: "categories")
        coder.encode(self.mileage, forKey: "mileage")
        coder.encode(self.notes, forKey: "notes")
        coder.encode(self.timestamp, forKey: "timestamp")
    }
    
    func owed() -> Double {
        var owed = 0.0
        for category in categories.values {
            owed += category.owed()
        }
        return owed
    }
    
    func paid() -> Double {
        var paid = 0.0
        for category in categories.values {
            paid += category.paid()
        }
        return paid
    }
    
    func complete() -> Bool {
        return owed() == 0.0
    }
}

func ==(lhs: Client, rhs: Client) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.contact.identifier == rhs.contact.identifier
}
