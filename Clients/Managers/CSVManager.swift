import Foundation
import Contacts
//import SwiftCSV

class CSVManager {
    static let types = ["Clients", "Mileage"]

    class func getCSV(_ client: [Client], type: String) -> NSString {
        switch type {
        case "Clients": return getClientsCSV(client)
        case "Mileage": return getMileageCSV(client)
        default: return NSString()
        }
    }

    fileprivate class func getMileageCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Mileage,Date\n"
        for client in clients {
            data += "\(client.contact.familyName),"
            data += "\(client.contact.givenName),"

            for miles in client.mileage {
                data += "\(miles.miles),"
                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date = formatter.string(from: miles.date as Date)
                data += "\(date)\n"
            }
        }
        return NSString(string: data)
    }

    fileprivate class func getClientsCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Phone,Email,Notes,Timestamp,Payments\n"
        for client in clients {
            data += "\(client.contact.familyName),"
            data += "\(client.contact.givenName),"
            if let phone = client.contact.phoneNumbers.first {
                let phoneNumber = phone.value 
                data += "\(phoneNumber.stringValue),"
            }
            else {
                data += "None,"
            }
            if let email = client.contact.emailAddresses.first {
                data += "\(email.value),"
            }
            else {
                data += "None,"
            }
            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.string(from: client.timestamp as Date)
            data += "\(client.notes),\(date),"

            for name in client.categories.keys {
                if let category = client.categories[name] {
                    data += "\(name),"
                    for payment in category.payments {
                        data += "\(payment.name): "
                        data += "\(payment.value) - "
                        data += "\(formatter.string(from: payment.date as Date)) - "
                        data += "\(payment.type),"
                    }
                }
            }
            data += "\n"
        }
        
        return NSString(string: data)
    }

    /*class func parseClients(_ csv: CSV) -> [Client] {
        //var clients: [Client] = []
        for clientData in csv.rows {
            var contact = CNContact()
            do {
                let name = "\(clientData["First"]!) \(clientData["Last"]!)"
                let predicate = CNContact.predicateForContacts(matchingName: name)
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactIdentifierKey]
                
                let contacts = try CNContactStore().unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
                if (!contacts.isEmpty) {
                    contact = contacts.first!
                }
                print("Imported contact \(contact.givenName) \(contact.familyName)")
            } catch {
                print("Unable to load a contact")
            }
/*
            var clientCategory: Category = Contract()
            var first = true

            for category in categories {
                for i in 0 ... category.sections.count - 1 {
                    let value = clientData[category.sections[i].name]!
                    if value != "N/A" {
                        if first {
                            switch category.categoryName {
                            case "Consultation": clientCategory = Consultation()
                            default: clientCategory = Contract()
                            }
                            first = false
                        }
                        clientCategory.sections[i].value = Double(value)!
                    }
                }
            }

            let client = Client(contact: contact, category: clientCategory, mileage: [], notes: clientData["Notes"]!, timestamp: NSDate())
            clients.append(client)*/
        }
        return []
    }*/
}
