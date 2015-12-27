import Foundation
import Contacts
import SwiftCSV

class CSVManager {
    static let categories = [Contract(), Consultation()]
    static let types = ["Clients", "Mileage"]

    class func getCSV(client: [Client], type: String) -> NSString {
        switch type {
        case "Clients": return getClientsCSV(client)
        case "Mileage": return getMileageCSV(client)
        default: return NSString()
        }
    }

    private class func getMileageCSV(clients: [Client]) -> NSString {
        var data = "Last,First,Mileage,Date\n"
        for client in clients {
            data += "\(client.contact.familyName),"
            data += "\(client.contact.givenName),"

            for miles in client.mileage {
                data += "\(miles.miles),"
                let formatter = NSDateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date = formatter.stringFromDate(miles.date)
                data += "\(date)\n"
            }
        }
        return NSString(string: data)
    }

    private class func getClientsCSV(clients: [Client]) -> NSString {
        var data = "Last,First,Phone,Email,"
        for category in categories {
            for section in category.sections {
                data += "\(section.name),"
            }
        }
        data += "Notes,Timestamp\n"
        for client in clients {
            data += "\(client.contact.familyName),"
            data += "\(client.contact.givenName),"
            if let phone = client.contact.phoneNumbers.first {
                let phoneNumber = phone.value as! CNPhoneNumber
                data += "\(phoneNumber.stringValue),"
            } else {
                data += "None,"
            }
            if let email = client.contact.emailAddresses.first {
                data += "\(email.value),"
            } else {
                data += "None,"
            }
            //TODO generify
            if client.category is Consultation {
                data += "N/A,N/A,N/A,N/A,"
            }
            for section in client.category.sections {
                data += "\(section.value),"
            }
            //TODO generify
            if client.category is Contract {
                data += "N/A,N/A,"
            }
            let formatter = NSDateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.stringFromDate(client.timestamp)
            data += "\(client.notes),\(date)\n"
        }
        return NSString(string: data)
    }

    class func parseClients(csv: CSV) -> [Client] {
        let clients: [Client] = []
        //TODO implement import
        return clients
    }
}