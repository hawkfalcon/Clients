import UIKit
import Contacts
import ContactsUI

class ClientInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate, CNContactViewControllerDelegate, CNContactPickerDelegate {

    var sections = [String]()
    
    //var expanded = [String:Int]()

    @IBOutlet var tableView: UITableView!

    var client: Client!

    // Initialize
    override func viewWillAppear(_ animated: Bool) {
        var title = "New Contact"
        if (client.contact.givenName != "") {
            title = "\(client.contact.givenName) \(client.contact.familyName)"
        }
        sections = ["Contact", "Categories", "Driving", "Other"]
        for (category, _) in client.categories {
            sections.insert(category, at: 2)
        }
        navigationItem.title = title
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }

    // Setup layout
    func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = client.categories[sections[section]] {
            return category.payments.count + 2
        }
        return 1
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = sections[section]
        if client.categories[category] != nil {
            return nil
        }
        return category
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[(indexPath as NSIndexPath).section]
        switch section {
        case "Other":
            return 150.0
        case "Categories":
            if client.categories.count == 0 {
                return 55.0
            }
            return 0
        case "Driving":
            return 55.0
        case "Contact":
            return 55.0
        default:
            if (indexPath as NSIndexPath).row == 0 {
                return 35.0
            }
            /*else if expanded[section] == indexPath.row {
                return 330.0
            }*/
            return 55.0
        }
    }

    // Populate data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[(indexPath as NSIndexPath).section]
        var cell: UITableViewCell
        if client.categories[section] != nil {
            cell = createPaymentCell(section: section, indexPath: indexPath)
        }
        else {
            cell = createInfoCell(section: section, indexPath: indexPath)
        }
        
        return cell
    }

    func createPaymentCell(section: String, indexPath: IndexPath) -> UITableViewCell {
        let last = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section) - 1
        if (indexPath as NSIndexPath).row == last {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewPaymentCell", for: indexPath) as! NewPaymentTableViewCell
            cell.configure()
            return cell
        }
        else {
            let category = client.categories[section]!
            let cell = tableView.dequeueReusableCell(withIdentifier: "PaymentCell", for: indexPath) as! PaymentDataTableViewCell
            if (indexPath as NSIndexPath).row == 0 {
                let leftLabel = UILabel()
                leftLabel.text = "Total: "
                leftLabel.textAlignment = .right
                leftLabel.sizeToFit()
                cell.valueField.leftView = leftLabel
                cell.valueField.leftViewMode = .unlessEditing
                
                cell.paymentField.text = section
                cell.paymentField.isEnabled = false

                cell.valueField.text = "\(category.total.currency)"
                cell.valueField.sizeToFit()
                
                cell.backgroundColor = UIColor.lightText
                
                cell.selectionStyle = .none
                cell.accessoryType = .none
            } else {
                let payment = category.payments[(indexPath as NSIndexPath).row - 1]
                
                cell.paymentField.text = payment.name
                cell.valueField.text = "\(payment.value.currency)"
                cell.valueField.isEnabled = false
            }
            cell.addTargets(viewController: self)
            return cell
        }
    }

    func createInfoCell(section: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath) as! TextInputTableViewCell
        
        var title = ""
        var value = ""
        cell.textField.isEnabled = false
        switch section {
        case "Contact":
            title = client.contact.givenName + " " + client.contact.familyName
            if (title == " ") {
                title = "Choose a Contact"
            }
            value = "Go to Contact"
        case "Driving":
            title = "Miles Driven"
            //TODO recalcuate on segue from Mileage
            var mileTotal: Double = 0.0
            for mile in client.mileage {
                mileTotal += mile.miles
            }
            value = "\(mileTotal)"
        case "Other":
            title = "Notes"
            value = client.notes
            cell.detailTextLabel?.lineBreakMode = .byWordWrapping;
            cell.detailTextLabel?.numberOfLines = 0;
            cell.textField.isEnabled = true
            cell.textField.keyboardType = .default
        case "Categories":
            if client.categories.count == 0 {
                title = "Add a Category +"
            }
        default:
            print("?")
        }
        
        if section == "Contact" || section == "Driving" {
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        }
        else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        
        return cell
    }
    
    /*func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        return range.length < 1 || range.location + range.length > 1
    }*/
    
    func fieldDidChange(_ textField: UITextField) {
        if let name = textField.placeholder, let cell = textField.superview?.superview as? UITableViewCell,
            let indexPath = tableView.indexPath(for: cell),
            let category = client.categories[sections[(indexPath as NSIndexPath).section]],
            let text = textField.text {
            if (indexPath as NSIndexPath).row > 0 {
                let payment = category.payments[(indexPath as NSIndexPath).row - 1]
                if name == "Name" {
                    payment.name = text
                }
                else if let value = text.rawDouble {
                    payment.value = value
                }
            }
            else {
                if let value = text.rawDouble {
                    category.total = value
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        let category = sections[(indexPath as NSIndexPath).section]
        if client.categories[category] != nil && (indexPath as NSIndexPath).row == 0 {
            return nil
        }
        return indexPath
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let category = sections[section]
        if client.categories[category] != nil || category == "Categories" {
            return 0.0001
        }
        return 18.0;
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let category = sections[section]
        if client.categories[category] != nil {
            return 0.0001
        }
        else if category == "Contact" || category == "Driving" {
            return 36.0
        }
        return 18.0;
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let last = tableView.numberOfRows(inSection: (indexPath as NSIndexPath).section) - 1
        let category = sections[(indexPath as NSIndexPath).section]
        if client.categories[category] != nil && (indexPath as NSIndexPath).row != last {// && indexPath.row != 0 {
            return true
        }
        return false
    }
    
    // Allow deletion
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let category = sections[(indexPath as NSIndexPath).section]
            tableView.beginUpdates()
            if (indexPath as NSIndexPath).row == 0 {
                client.categories[category] = nil
                sections.remove(at: (indexPath as NSIndexPath).section)
                tableView.deleteSections(IndexSet(integer: (indexPath as NSIndexPath).section), with: .automatic)
            }
            else {
                client.categories[category]?.payments.remove(at: (indexPath as NSIndexPath).row - 1)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
            tableView.endUpdates()
        }
    }
    
    // Tapped on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let section = sections[(indexPath as NSIndexPath).section]
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if let text = cell.detailTextLabel?.text , text == "Go to Contact" {
            if (client.contact.givenName == "") {
                showContactsPicker()
            }
            else {
                loadContact()
            }
        }
        else if let text = cell.textLabel?.text , text == "Miles Driven" {
            performSegue(withIdentifier: "toMiles", sender: nil)
        }
        else if let text = cell.textLabel?.text , text == "Add a Category +" {
            performSegue(withIdentifier: "addCategory", sender: nil)
        }
        else if cell is NewPaymentTableViewCell {
            let category = client.categories[section]
            let payment = Payment(name: "Payment", value: 0.0, type: "", date: Date())
            category?.payments.append(payment)
            
            tableView.beginUpdates()
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
            
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "toPayment", sender: self)

            NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
        }
        else {
            if let textCell = cell as? TextInputTableViewCell {
                if textCell.textField != nil {
                    textCell.textField.becomeFirstResponder()
                }
            }
        }
    }

    func loadContact() {
        do {
            let contact = try CNContactStore().unifiedContact(withIdentifier: client.contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            let viewController = CNContactViewController(for: contact)
            viewController.contactStore = CNContactStore()
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        } catch {
            print("Can't load contact")
        }
    }
    
    // Choose a contact
    func showContactsPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        // TODO: fix predicate
        // let predicate = NSPredicate(format: "phoneNumbers.@count > 0")
        // contactPicker.predicateForEnablingContact = predicate
        self.present(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactSelected: CNContact) {
        client.contact = contactSelected
        let cell = tableView.cellForRow(at: tableView.indexPathsForVisibleRows![0]) as! TextInputTableViewCell
        let name = "\(contactSelected.givenName) \(contactSelected.familyName)"
        cell.textLabel!.text = "\(name)"
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
    }

    // Setup reponse
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if let money = textField.text?.rawDouble {
            textField.text = money.currency
        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    @IBAction func unwindAndAddCategory(_ segue: UIStoryboardSegue) {
        let source = segue.source as! NewCategoryViewController
        let category = source.category
        let name = source.name
        client.categories[name] = category
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
    }
    
    @IBAction func unwindToClient(_ segue: UIStoryboardSegue) {
        //Cancelled
    }


    // Prepare to edit client or go to mileage
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let id = segue.identifier {
            if id == "toMiles", let destination = segue.destination as? MileageTableViewController {
                destination.mileage = client.mileage
                destination.client = client
            }
            else if id == "toPayment", let destination = segue.destination as? PaymentInfoViewController {
                if let index = tableView.indexPathForSelectedRow {
                    let section = sections[(index as NSIndexPath).section]
                    destination.payment = client.categories[section]?.payments[(index as NSIndexPath).row - 1]
                }
            }
        }
    }
}

extension Double {
    var currency:String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension String {
    var rawDouble:Double? {
        var raw = self.replacingOccurrences(of: "$", with: "")
        raw = raw.replacingOccurrences(of: ",", with: "")
        return Double(raw)
    }
}
