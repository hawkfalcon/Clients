import UIKit
import Contacts
import ContactsUI

class ClientInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CNContactViewControllerDelegate, CNContactPickerDelegate {

    var sections = [String]()
    
    var expanded = [String:Int]()

    @IBOutlet var tableView: UITableView!

    var client: Client!

    // Initialize
    override func viewWillAppear(animated: Bool) {
        var title = "New Contact"
        if (client.contact.givenName != "") {
            title = "\(client.contact.givenName) \(client.contact.familyName)"
        }
        sections = ["Contact", "Categories", "Driving", "Other"]
        for (category, _) in client.categories {
            sections.insert(category, atIndex: 2)
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
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let category = client.categories[sections[section]] {
            return category.payments.count + 2
        }
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = sections[section]
        if client.categories[category] != nil {
            return nil
        }
        return category
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        let section = sections[indexPath.section]
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
            if indexPath.row == 0 {
                return 25.0
            }
            else if expanded[section] == indexPath.row {
                return 110.0
            }
            return 55.0
        }
    }

    // Populate data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        var cell: UITableViewCell
        if client.categories[section] != nil {
            cell = createPaymentCell(section, indexPath: indexPath)
        }
        else {
            cell = createInfoCell(section, indexPath: indexPath)
        }
        
        return cell
    }

    func createPaymentCell(section: String, indexPath: NSIndexPath) -> UITableViewCell {
        let last = tableView.numberOfRowsInSection(indexPath.section) - 1
        if indexPath.row == last {
            let cell = tableView.dequeueReusableCellWithIdentifier("NewPaymentCell", forIndexPath: indexPath) as! NewPaymentTableViewCell
            cell.configure()
            return cell
        }
        else {
            let category = client.categories[section]!
            let cell = tableView.dequeueReusableCellWithIdentifier("PaymentCell", forIndexPath: indexPath) as! PaymentDataTableViewCell
            if indexPath.row == 0 {
                let leftLabel = UILabel(frame: CGRectMake(0, 0, 5, 20))
                leftLabel.text = "Total: "
                leftLabel.sizeToFit()
                cell.valueField.leftView = leftLabel
                cell.valueField.leftViewMode = .UnlessEditing
                
                cell.paymentField.text = section
                cell.paymentField.enabled = false
                cell.valueField.text = "\(category.total)"
                cell.backgroundColor = UIColor.lightTextColor()
            } else {
                if expanded[section] == indexPath.row {
                    //
                }
                let payment = category.payments[indexPath.row - 1]
                cell.paymentField.text = payment.name
                cell.valueField.text = "\(payment.value)"
                cell.addTargets(self)
            }
            return cell
        }
    }

    func createInfoCell(section: String, indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as! TextInputTableViewCell
        
        var title = ""
        var value = ""
        cell.textField.enabled = false
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
            cell.detailTextLabel?.lineBreakMode = .ByWordWrapping;
            cell.detailTextLabel?.numberOfLines = 0;
            cell.textField.enabled = true
        case "Categories":
            if client.categories.count == 0 {
                title = "Add a Category +"
            }
        default:
            print("?")
        }
        
        if section == "Contact" || section == "Driving" {
            cell.selectionStyle = .Default
            cell.accessoryType = .DisclosureIndicator
        }
        else {
            cell.accessoryType = .None
            cell.selectionStyle = .None
        }
        
        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value
        
        return cell
    }
    
    func paymentFieldDidChange(textField: UITextField) {
        textFieldDidChange(textField, isPayment: true)
    }
    
    func valueFieldDidChange(textField: UITextField) {
        textFieldDidChange(textField, isPayment: false)
    }
    
    func textFieldDidChange(textField: UITextField, isPayment: Bool) {
        if let cell = textField.superview?.superview as? UITableViewCell,
            let indexPath = tableView.indexPathForCell(cell),
            let category = client.categories[sections[indexPath.section]],
            let text = textField.text {
            print(text)
            if indexPath.row > 0 {
                let payment = category.payments[indexPath.row - 1]
                if isPayment {
                    print(payment.name + " " + text)
                    payment.name = text
                }
                else {
                    if let value = Double(text) {
                        payment.value = value
                    }
                }
            }
            else if !isPayment {
                if let total = Double(text) {
                    category.total = total
                }
            }
        }
    }
    
    func tableView(tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let category = sections[section]
        if client.categories[category] != nil || category == "Categories" {
            return 0.0
        }
        return 18.0;
    }
    
    func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let category = sections[section]
        if client.categories[category] != nil {
            return 0.0
        }
        else if category == "Contact" || category == "Driving" {
            return 36.0
        }
        return 18.0;
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        let last = tableView.numberOfRowsInSection(indexPath.section) - 1
        let category = sections[indexPath.section]
        if client.categories[category] != nil && indexPath.row != last && indexPath.row != 0 {
            return true
        }
        return false
    }
    
    // Allow deletion
    func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let category = sections[indexPath.section]
            client.categories[category]?.payments.removeAtIndex(indexPath.row - 1)
            NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    
    // Tapped on cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let section = sections[indexPath.section]
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)! as UITableViewCell
        if let text = cell.detailTextLabel?.text where text == "Go to Contact" {
            if (client.contact.givenName == "") {
                showContactsPicker()
            }
            else {
                loadContact()
            }
        }
        else if let text = cell.textLabel?.text where text == "Miles Driven" {
            performSegueWithIdentifier("toMiles", sender: nil)
        }
        else if cell is NewPaymentTableViewCell {
            let category = client.categories[section]
            let payment = Payment(name: "Payment", value: 0.0, type: "", date: NSDate())
            category?.payments.append(payment)
            expanded[section] = indexPath.row
            
            tableView.beginUpdates()
            tableView.insertRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            tableView.endUpdates()
            
            NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
        } else if cell is PaymentDataTableViewCell {
            if expanded[section] == nil {
                expanded = [:]
                expanded[section] = indexPath.row
            }
            else {
                expanded = [:]
            }
            tableView.beginUpdates()
            tableView.endUpdates()
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
            let contact = try CNContactStore().unifiedContactWithIdentifier(client.contact.identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            let viewController = CNContactViewController(forContact: contact)
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
        self.presentViewController(contactPicker, animated: true, completion: nil)
    }
    
    func contactPicker(picker: CNContactPickerViewController, didSelectContact contactSelected: CNContact) {
        client.contact = contactSelected
        let cell = tableView.cellForRowAtIndexPath(tableView.indexPathsForVisibleRows![0]) as! TextInputTableViewCell
        let name = "\(contactSelected.givenName) \(contactSelected.familyName)"
        cell.textLabel!.text = "\(name)"
        
        NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
    }

    // Setup reponse
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    @IBAction func unwindAndAddCategory(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! NewCategoryViewController
        let category = source.category
        let name = source.name
        client.categories[name] = category
        print("\(name) \(category.total)")
        
        NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
    }
    
    @IBAction func unwindToClient(segue: UIStoryboardSegue) {
        //Cancelled
    }


    // Prepare to edit client or go to mileage
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let id = segue.identifier {
            if id == "toMiles", let destination = segue.destinationViewController as? MileageTableViewController {
                destination.mileage = client.mileage
                destination.client = client
            }
        }
    }
    
    override func didMoveToParentViewController(parent: UIViewController?) {
        if let clientsViewController = parent as? ClientsViewController {
            clientsViewController.clients.append(client)
        }
    }
}
