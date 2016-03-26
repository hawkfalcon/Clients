import UIKit
import Contacts
import ContactsUI

class ClientInfoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, CNContactViewControllerDelegate {

    let sections = ["Contact", "Payments", "Driving", "Other"]

    @IBOutlet var tableView: UITableView!

    var client: Client!

    // Initialize
    override func viewWillAppear(animated: Bool) {
        let name = client.contact.givenName + " " + client.contact.familyName
        navigationItem.title = "\(name)"
        //TODO generify
        if client.category is Contract {
            let owed = client.category.sections[0].value - client.category.totalValue()
            let color = owed <= 0 ? UIColor.blackColor() : UIColor.redColor()
            client.category.sections[3].color = color
        }
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
        if sections[section] == "Payments" {
            return client.category.sections.count
        }
        return 1
    }

    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if (indexPath.section == 3) {
            return 150.0;
        }
        return 55.0
    }

    // Populate data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("InfoCell", forIndexPath: indexPath) as UITableViewCell

        let section = indexPath.section
        var text: String
        var value: String
        var color = UIColor.blackColor()
        switch section {
        case 0:
            text = client.contact.givenName + " " + client.contact.familyName
            value = "Go to Contacts"
        case 2:
            text = "Miles Driven"
            //TODO recalcuate on segue from Mileage
            var mileTotal: Double = 0.0
            for mile in client.mileage {
                mileTotal += mile.miles
            }
            value = "\(mileTotal)"
        case 3:
            text = "Notes"
            value = client.notes
            cell.detailTextLabel?.lineBreakMode = .ByWordWrapping;
            cell.detailTextLabel?.numberOfLines = 0;

        default:
            let section = client.category.sections[indexPath.row]
            text = section.name
            color = section.color
            value = "\(section.value)"
        }

        if section == 0 || section == 2 {
            cell.selectionStyle = .Default
            cell.accessoryType = .DisclosureIndicator
        }
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = value
        cell.detailTextLabel?.textColor = color

        return cell
    }

    // Tapped on cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath)
        if let text = cell?.detailTextLabel?.text where text == "Go to Contacts" {
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
        if let text = cell?.textLabel?.text where text == "Miles Driven" {
            performSegueWithIdentifier("toMiles", sender: nil)
        }
    }

    // Prepare to edit client or go to mileage
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if let id = segue.identifier {
            if id == "toEdit", let nav = segue.destinationViewController as? UINavigationController {
                if let destination = nav.topViewController as? NewClientViewController {
                    destination.newClient = false
                    destination.client = client
                    destination.previous = client
                }
            } else if id == "toMiles", let destination = segue.destinationViewController as? MileageTableViewController {
                destination.mileage = client.mileage
                destination.client = client
            }
        }
    }
}
