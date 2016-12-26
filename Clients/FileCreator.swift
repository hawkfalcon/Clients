import Foundation
import Contacts
import SSZipArchive

class FileCreator {
    static let types = ["Clients", "Categories", "Payments", "Mileage", "All"]

    class func createFile(clients: [Client], type: String) -> URL {
        if type == "All" {
            return createZip(clients)
        }
        guard let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "")
        }

        let content = getCSV(clients, type: type)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let date = formatter.string(from: Date())
        let file = path.appendingPathComponent("Clients_\(type)_\(date).csv")
        do {
            try content.write(to: file, atomically: false, encoding: String.Encoding.utf8.rawValue)
        } catch let error as NSError {
            print(error.localizedDescription)
        }
        return file
    }

    class func createZip(_ clients: [Client]) -> URL {
        guard let path = FileManager.default
                .urls(for: .documentDirectory, in: .userDomainMask).first else {
            return URL(fileURLWithPath: "")
        }

        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd_HH_mm_ss"
        let date = formatter.string(from: Date())

        let folder = path.appendingPathComponent("Clients_\(date)")
        do {
            try FileManager.default.createDirectory(atPath: folder.path, withIntermediateDirectories: false, attributes: nil)
        } catch let error as NSError {
            print(error.localizedDescription);
        }

        for type in types {
            if type == "All" {
                continue
            }
            let file = folder.appendingPathComponent("\(type).csv")
            let content = getCSV(clients, type: type)
            do {
                try content.write(to: file, atomically: false, encoding: String.Encoding.utf8.rawValue)
            } catch let error as NSError {
                print(error.localizedDescription)
            }
        }

        let zip = path.appendingPathComponent("Clients_\(date).zip")
        SSZipArchive.createZipFile(atPath: zip.path, withContentsOfDirectory: folder.path)
        return zip
    }

    class func getCSV(_ clients: [Client], type: String) -> NSString {
        switch type {
        case "Clients": return getClientsCSV(clients)
        case "Categories": return getCategoriesCSV(clients)
        case "Payments": return getPaymentsCSV(clients)
        case "Mileage": return getMileageCSV(clients)
        default: return NSString(string: "test")
        }
    }

    private class func getMileageCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Total Miles,Date,Mileage\n"
        for client in clients {
            var names = ""
            if let last = client.lastName {
                names += "\(last)"
            }
            names += ","

            if let first = client.firstName {
                names += "\(first)"
            }
            names += ","

            var milesText = ""
            var total = 0.0
            for miles in client.mileage! {
                let miles = miles as! Mileage
                total += miles.miles

                let formatter = DateFormatter()
                formatter.dateFormat = "MM/dd/yyyy"
                let date = formatter.string(from: miles.date as! Date)
                milesText += "\(date),"
                milesText += "\(miles.miles),"
            }
            data += "\(total),"
            data += milesText
            data += "\n"
        }
        return NSString(string: data)
    }

    private class func getPaymentsCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Category,Name,Type,Amount,Date\n"
        for client in clients {
            var names = ""
            if let last = client.lastName {
                names += "\(last)"
            }
            names += ","

            if let first = client.firstName {
                names += "\(first)"
            }
            names += ","

            for category in client.categories! {
                let category = category as! Category

                for payment in category.payments! {
                    let payment = payment as! Payment

                    data += "\(names)"
                    if let name = category.name {
                        data += "\(name)"
                    }
                    data += ","

                    data += "\(payment.name!),"
                    data += "\(payment.type!),"
                    data += "\(payment.value),"

                    let formatter = DateFormatter()
                    formatter.dateFormat = "MM/dd/yyyy HH:mm:ss"
                    let date = formatter.string(from: payment.date as! Date)
                    data += "\(date)"

                    data += "\n"
                }
            }
            data += "\n"
        }
        return NSString(string: data)
    }

    private class func getCategoriesCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Category,Total\n"
        for client in clients {
            var names = ""
            if let last = client.lastName {
                names += "\(last)"
            }
            names += ","

            if let first = client.firstName {
                names += "\(first)"
            }
            names += ","

            for category in client.categories! {
                let category = category as! Category

                data += "\(names)"
                if let name = category.name {
                    data += "\(name)"
                }
                data += ","

                data += "\(category.total)"
                data += "\n"
            }
            data += "\n"
        }
        return NSString(string: data)
    }

    private class func getClientsCSV(_ clients: [Client]) -> NSString {
        var data = "Last,First,Phone,Email,Notes,Timestamp,Total Paid, Total Owed\n"
        for client in clients {
            if let last = client.lastName {
                data += "\(last)"
            }
            data += ","

            if let first = client.firstName {
                data += "\(first)"
            }
            data += ","

            do {
                let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey, CNContactEmailAddressesKey, CNContactIdentifierKey]
                let contact = try CNContactStore().unifiedContact(withIdentifier: client.contact!, keysToFetch: keysToFetch as [CNKeyDescriptor])

                if let phone = contact.phoneNumbers.first {
                    let phoneNumber = phone.value
                    data += "\(phoneNumber.stringValue)"
                }
                data += ","

                if let email = contact.emailAddresses.first {
                    data += "\(email.value)"
                }
                data += ","
            } catch {
                print("Invalid contact")
            }
            if let notes = client.notes {
                data += "\(notes)"
            }
            data += ","

            let formatter = DateFormatter()
            formatter.dateFormat = "MM/dd/yyyy"
            let date = formatter.string(from: client.timestamp as! Date)
            data += "\(date),"

            data += "\(client.paid()),"
            data += "\(client.owed())"

            data += "\n"
        }

        return NSString(string: data)
    }
}
