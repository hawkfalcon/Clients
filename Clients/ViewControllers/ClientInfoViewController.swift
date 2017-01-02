import UIKit
import Contacts
import ContactsUI
import CoreData

class ClientInfoViewController: UITableViewController {

    var sections = [String]()
    var dataContext: NSManagedObjectContext!

    var client: Client!

    // MARK: - Setup
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self

        var title = "New Contact"
        sections = ["Contact", "Categories", "Driving", "Other"]

        if !Settings.enabledMileage {
            sections.remove(at: 2)
        }

        if let client = client {
            if let first = client.firstName, let last = client.lastName {
                title = "\(first) \(last)"
            }

            for category in client.categories! {
                let category = category as! Category
                sections.insert(category.name!, at: 2)
            }
        } else {
            client = Client(context: dataContext)
            client.timestamp = NSDate()
            client.notes = ""
            client.firstName = "First"
            client.lastName = "Last"
        }

        navigationItem.title = title
        dataContext.saveChanges()
    }

    override func viewWillAppear(_ animated: Bool) {
        tableView.reloadData()

        client!.complete = client.owed() == 0.0
        dataContext.saveChanges()

        super.viewWillAppear(animated)
    }

    // MARK: - Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = indexPath.section
        var cell: UITableViewCell
        if sections[section] == "Other"  {
            cell = createNotesCell(indexPath: indexPath)
        } else if isCategory(section) {
            cell = createPaymentCell(section: section, indexPath: indexPath)
        } else {
            cell = createInfoCell(section: sections[section], indexPath: indexPath)
        }

        return cell
    }
    
    func createNotesCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotesCell", for: indexPath) as! TextInputCell
        
        cell.textLabel?.text = "Notes"
        if let notes = client.notes {
            cell.textField.text = notes
        }
        cell.detailTextLabel?.lineBreakMode = .byWordWrapping;
        cell.detailTextLabel?.numberOfLines = 0;
        cell.textField.delegate = self
        cell.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
        cell.textField.placeholder = "Notes..."
        cell.textField.isEnabled = true
        cell.textField.keyboardType = .default
        cell.textField.frame.size.height = cell.frame.size.height * (9 / 10)
        
        return cell
    }

    func createPaymentCell(section: Int, indexPath: IndexPath) -> UITableViewCell {
        let last = tableView.numberOfRows(inSection: indexPath.section) - 1
        if indexPath.row == last {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewPaymentCell", for: indexPath) as! NewPaymentCell
            cell.configure(type: "Payment")

            return cell
        } else {
            let category = client.category(section: section)!

            let identifier = indexPath.row == 0 ? "PaymentTotalCell" : "PaymentCell"
            let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as! PaymentDataCell

            if indexPath.row == 0 {
                configure(cell, for: category)
            } else {
                let payment = category.payments!.object(at: indexPath.row - 1) as! Payment

                cell.paymentField.text = payment.name
                cell.valueField.text = "\(payment.value.currency)"
                cell.valueField.isEnabled = false
            }

            cell.addTargets(viewController: self)

            return cell
        }
    }

    func configure(_ cell: PaymentDataCell, for category: Category) {
        let leftLabel = UILabel()
        leftLabel.text = "Total: "
        leftLabel.textAlignment = .right
        leftLabel.font = UIFont.boldSystemFont(ofSize: 16)
        leftLabel.sizeToFit()
        cell.valueField.leftView = leftLabel
        cell.valueField.leftViewMode = .unlessEditing

        cell.paymentField.text = category.name
        cell.paymentField.isEnabled = false
        cell.paymentField.font = UIFont.boldSystemFont(ofSize: 16)

        cell.valueField.text = "\(category.total.currency)"
        cell.valueField.sizeToFit()

        cell.backgroundColor = UIColor.lightText

        cell.selectionStyle = .none
        cell.accessoryType = .none
    }

    func createInfoCell(section: String, indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "InfoCell", for: indexPath)

        var title = ""
        var value = ""
        switch section {
        case "Contact":
            title = navigationItem.title!
            if (title == "New Contact") {
                title = "Choose a Contact"
            }
            value = "Go to Contact"
        case "Driving":
            title = "Miles Driven"
            //TODO recalcuate on segue from Mileage
            var mileTotal: Double = 0.0
            for mile in client.mileage! {
                let mile = mile as! Mileage
                mileTotal += mile.miles
            }
            value = "\(mileTotal)"
        case "Categories":
            if client.categories!.count == 0 {
                title = "Add a Category +"
            }
        default:
            print("?")
        }

        if section == "Contact" || section == "Driving" {
            cell.selectionStyle = .default
            cell.accessoryType = .disclosureIndicator
        } else {
            cell.accessoryType = .none
            cell.selectionStyle = .none
        }

        cell.textLabel?.text = title
        cell.detailTextLabel?.text = value

        return cell
    }

    // MARK: - Tapped on cell
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if let text = cell.detailTextLabel?.text, text == "Go to Contact" {
            if let contact = client.contact {
                loadContact(identifier: contact)
            } else {
                showContactsPicker()
            }
        } else if let text = cell.textLabel?.text, text == "Miles Driven" {
            performSegue(withIdentifier: "toMiles", sender: nil)
        } else if let text = cell.textLabel?.text, text == "Add a Category +" {
            performSegue(withIdentifier: "addCategory", sender: nil)
        } else if cell is NewPaymentCell {
            let category = client.category(section: indexPath.section)
            let payment = Payment(context: dataContext)
            payment.name = Settings.defaultPaymentNames[0]
            payment.type = Settings.defaultPaymentType
            payment.value = 0.0
            payment.date = NSDate()
            
            category?.addToPayments(payment)
            dataContext.saveChanges()

            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none)
            self.performSegue(withIdentifier: "toPayment", sender: self)
        } else {
            if let textCell = cell as? TextInputCell, textCell.textField != nil {
                textCell.textField.becomeFirstResponder()
            }
        }
    }

    // MARK: - Setup layout
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if isCategory(section) {
            let category = client.category(section: section)!
            return category.payments!.count + 2
        }
        return 1
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = sections[section]
        if isCategory(section) {
            return nil
        }
        return category
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
        case "Other":
            return 150.0
        case "Categories":
            if client.categories!.count == 0 {
                return 55.0
            }
            return 0
        case "Driving":
            return 55.0
        case "Contact":
            return 55.0
        default:
            if indexPath.row == 0 {
                return 35.0
            }
            return 55.0
        }
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if isCategory(indexPath.section) && indexPath.row == 0 {
            return nil
        }
        return indexPath
    }

    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        let category = sections[section]
        if isCategory(section) || category == "Categories" {
            return 0.0001
        }
        return 18.0;
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let category = sections[section]
        if isCategory(section) {
            return 0.0001
        } else if category == "Contact" || category == "Driving" || (category == "Other" && !Settings.enabledMileage) {
            return 36.0
        }
        return 18.0;
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        let last = tableView.numberOfRows(inSection: indexPath.section) - 1
        if isCategory(indexPath.section) && indexPath.row != last {
            return true
        }
        return false
    }

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }

    // MARK: - Allow deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            if indexPath.row == 0 {
                client.removeFromCategories(at: indexPath.section - 2)
                sections.remove(at: 2)
                tableView.deleteSections([indexPath.section], with: .automatic)

                if client.categories!.count == 0 {
                    let cell = tableView.cellForRow(at: IndexPath(row: 0, section: 1))
                    cell!.textLabel!.text = "Add a Category +"
                }
            } else {
                let category = client.category(section: indexPath.section)!
                category.removeFromPayments(at: indexPath.row - 1)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            dataContext.saveChanges()
            tableView.endUpdates()
        }
    }

    // MARK: - Return from new category

    @IBAction func unwindAndAddCategory(_ segue: UIStoryboardSegue) {
        let source = segue.source as! NewCategoryViewController

        let category = Category(context: dataContext)
        category.name = source.name
        category.total = source.total

        client.addToCategories(category)

        dataContext.saveChanges()
        sections.insert(category.name!, at: 2)
        tableView.reloadData()
    }

    @IBAction func unwindToClient(_ segue: UIStoryboardSegue) {
        //Cancelled
    }

    // Prepare to edit client or go to mileage
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let id = segue.identifier {
            if id == "toMiles", let destination = segue.destination as? MileageTableViewController {
                destination.mileage = client.mileage!
                destination.client = client

                destination.dataContext = dataContext
            } else if id == "toPayment", let destination = segue.destination as? PaymentInfoViewController {
                if let index = tableView.indexPathForSelectedRow {
                    let category = client.category(section: index.section)!
                    let payment = category.payments!.object(at: index.row - 1) as! Payment
                    
                    destination.payment = payment
                }
            }
        }
    }

    func isCategory(_ section: Int) -> Bool {
        return section > 1 && section < client.categories!.count + 2
    }
}

extension NSManagedObjectContext {
    func saveChanges() {
        if self.hasChanges {
            do {
                try self.save()
            } catch {
                print("An error occurred while saving: \(error)")
            }
        }

    }
}

extension ClientInfoViewController: UITextFieldDelegate {
    // Allow editing in place
    func fieldDidChange(_ textField: UITextField) {
        if let name = textField.placeholder, let cell = textField.superview?.superview as? UITableViewCell,
           let indexPath = tableView.indexPath(for: cell),
           let text = textField.text {
            if name == "Notes..." {
                client.notes = text
            } else if let category = client.category(section: indexPath.section) {
                if indexPath.row > 0 {
                    let payment = category.payments!.object(at: indexPath.row - 1) as! Payment
                    if name == "Name" {
                        payment.name = text
                    } else if let value = text.rawDouble {
                        payment.value = value
                    }
                } else if let value = text.rawDouble {
                    category.total = value
                }
            }
            dataContext.saveChanges()
        }
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

    /*func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
     return range.length < 1 || range.location + range.length > 1
     }*/
}

extension ClientInfoViewController: CNContactPickerDelegate {
    func loadContact(identifier: String) {
        do {
            let contact = try CNContactStore().unifiedContact(withIdentifier: identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
            let viewController = CNContactViewController(for: contact)
            viewController.contactStore = CNContactStore()
            viewController.delegate = self
            self.navigationController?.pushViewController(viewController, animated: true)
        } catch {
            print("Can't load contact")
        }
    }

    func showContactsPicker() {
        let contactPicker = CNContactPickerViewController()
        contactPicker.delegate = self;
        // TODO: fix predicate
        // let predicate = NSPredicate(format: "phoneNumbers.@count > 0")
        // contactPicker.predicateForEnablingContact = predicate
        self.present(contactPicker, animated: true, completion: nil)
    }
}

extension ClientInfoViewController: CNContactViewControllerDelegate {
    func contactPicker(_ picker: CNContactPickerViewController, didSelect contactSelected: CNContact) {
        client.contact = contactSelected.identifier
        client.firstName = contactSelected.givenName
        client.lastName = contactSelected.familyName
        dataContext.saveChanges()

        navigationItem.title = "\(contactSelected.givenName) \(contactSelected.familyName)"
    }
}

extension Client {
    func category(section: Int) -> Category? {
        return self.categories!.object(at: section - 2) as? Category
    }
}

extension Double {
    var currency: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        return formatter.string(from: NSNumber(value: self))!
    }
}

extension String {
    var rawDouble: Double? {
        var raw = self.replacingOccurrences(of: "$", with: "")
        raw = raw.replacingOccurrences(of: ",", with: "")
        return Double(raw)
    }
}
