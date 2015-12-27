import Contacts

class Client: NSObject, NSCoding {
    var contact: CNContact
    var category: Category

    var mileage: [Mileage]

    var notes: String

    let timestamp: NSDate

    init(contact: CNContact, category: Category, mileage: [Mileage], notes: String, timestamp: NSDate) {
        self.contact = contact
        self.category = category
        self.timestamp = timestamp
        self.notes = notes
        self.mileage = mileage
    }

    required init(coder: NSCoder) {
        var contact = CNContact()
        do {
            let identifier = coder.decodeObjectForKey("contact") as! String
            let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactIdentifierKey]
            contact = try CNContactStore().unifiedContactWithIdentifier(identifier, keysToFetch: keysToFetch)
            print("Loaded contact \(contact.givenName) \(contact.familyName)")
        } catch {
            print("Unable to load a contact")
        }
        self.contact = contact
        self.category = coder.decodeObjectForKey("category") as! Category
        self.mileage = coder.decodeObjectForKey("mileage") as! [Mileage]
        self.notes = coder.decodeObjectForKey("notes") as! String
        self.timestamp = coder.decodeObjectForKey("timestamp") as! NSDate

        super.init()
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.contact.identifier, forKey: "contact")
        coder.encodeObject(self.category, forKey: "category")
        coder.encodeObject(self.mileage, forKey: "mileage")
        coder.encodeObject(self.notes, forKey: "notes")
        coder.encodeObject(self.timestamp, forKey: "timestamp")
    }
}

func ==(lhs: Client, rhs: Client) -> Bool {
    return lhs.timestamp == rhs.timestamp && lhs.contact.identifier == rhs.contact.identifier
}
