import UIKit
import Contacts
import ContactsUI

class NewClientViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {

    @IBOutlet var done: UIBarButtonItem!

    @IBOutlet var tableView: UITableView!

    let sections = ["Contact Info", "Payments", "Other"]
    let categories = [Contract(), Consultation()]

    var segment = 0

    var client: Client!

    var previous: Client!
    var newClient = true

    var firstLoad = true

    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()

        done.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], forState: UIControlState.Normal)

        if !newClient {
            for i in 0 ... categories.count - 1 {
                if (client.category.categoryName == categories[i]) {
                    segment = i
                }
            }
            self.title = "Edit Client"
        } else {
            client = Client(contact: CNContact(), category: categories[0], mileage: [], notes: "", timestamp: NSDate())
            done.enabled = false
        }
        tableView.delegate = self
        tableView.dataSource = self
    }

    // Setup reponse
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }

    func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }

    // Setup layout
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return sections.count
    }

    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return client.category.sections.count + 1
        default:
            return 1;
        }
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 2 {
            return 150.0;
        }
        return 55.0
    }

    // Populate data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        // Setup segment cell
        if indexPath.section == 1 && indexPath.row == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier("SegmentCell", forIndexPath: indexPath) as UITableViewCell
            cell.selectionStyle = .None

            let segmentControl = cell.viewWithTag(1) as! UISegmentedControl
            if firstLoad {
                segmentControl.removeAllSegments()
                for i in 0 ... categories.count - 1 {
                    segmentControl.insertSegmentWithTitle(categories[i].categoryName, atIndex: i, animated: true)
                }
                if client.contact.familyName != "" {
                    segmentControl.enabled = false
                }
                firstLoad = false
            }
            segmentControl.selectedSegmentIndex = segment
            segmentControl.addTarget(self, action: #selector(segmentAction), forControlEvents: .ValueChanged)
            return cell
        }

        let cell = tableView.dequeueReusableCellWithIdentifier("NewCell", forIndexPath: indexPath) as! TextInputTableViewCell

        var text = ""
        var detail = ""

        switch indexPath.section {
        case 0:
            text = "Contact"
            if client.contact.familyName != "" {
                detail = client.contact.givenName + " " + client.contact.familyName
            } else {
                detail = "Choose"
            }
            cell.selectionStyle = .Default
            cell.accessoryType = .DisclosureIndicator
            cell.textField.enabled = false
        case 2:
            text = "Notes"
            cell.configure(client.notes, placeholder: "")
            cell.textField.keyboardType = .Default
        default:
            if indexPath.row > 0 {
                // Populate sections
                let section = client.category.sections[indexPath.row - 1]
                text = section.name
                cell.detailTextLabel?.textColor = section.color
                cell.configure("\(section.value)", placeholder: "")
            }
        }

        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detail
        cell.textField.delegate = self

        return cell
    }

    // Switch between categories
    func segmentAction(sender: UISegmentedControl) {
        segment = sender.selectedSegmentIndex
        client.category = categories[sender.selectedSegmentIndex]

        tableView.reloadData()
    }

    // Tapped on cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextInputTableViewCell
        if let text = cell.textLabel?.text where text == "Contact" {
            showContactsPicker()
        } else {
            if cell.textField != nil {
                cell.textField.becomeFirstResponder()
            }
        }
    }

    // Populate client
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let numSections = client.category.sections.count
        for i in 0 ... numSections - 1 {
            let sectionCell = tableView.cellForRowAtIndexPath(tableView.indexPathsForVisibleRows![i + 2]) as! TextInputTableViewCell
            if let value = Double(sectionCell.textField.text!) {
                client.category.sections[i].value = value
            }
        }
        let notesCell = tableView.cellForRowAtIndexPath(tableView.indexPathsForVisibleRows![numSections + 2]) as! TextInputTableViewCell
        client.notes = notesCell.textField.text!
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
        cell.detailTextLabel!.text = "\(name)"
        done.enabled = true
    }
}
