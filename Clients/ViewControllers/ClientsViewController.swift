import UIKit
import Contacts
import SwiftCSV

class ClientsViewController: UITableViewController, UIDocumentPickerDelegate {

    @IBOutlet var total: UILabel!

    var clients: [Client] = []

    // Initialize data
    override func viewDidLoad() {
        super.viewDidLoad()
        iCloudManager.setup()
        let defaults = NSUserDefaults.standardUserDefaults()
        if let clientsData = defaults.objectForKey("clients") as? NSData {
            clients = NSKeyedUnarchiver.unarchiveObjectWithData(clientsData) as! [Client]
            updateTotal()
        } else {
            //TODO help message
        }
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "save:", name: "save", object: nil)
    }

    // Setup layout
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }

    // Populate data
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("ClientCell")! as UITableViewCell
        let client = clients[indexPath.row]
        let name = "\(client.contact.familyName) \(client.contact.givenName)".trunc(18)
        let coloredName = NSMutableAttributedString(string: name)
        let startPos = client.contact.familyName.characters.count + 1
        coloredName.addAttribute(NSForegroundColorAttributeName, value: UIColor.grayColor(), range: NSRange(location: startPos, length: name.characters.count - startPos))

        cell.textLabel?.attributedText = coloredName
        cell.detailTextLabel?.attributedText = client.category.displayedValue()

        return cell
    }


    // Allow deletion
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            clients.removeAtIndex(indexPath.row)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
            saveAndUpdateTotal()
        }
    }

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }

    // MARK Helper functions

    // Sort and refresh data
    func updatedClient() {
        self.clients.sortInPlace {
            if $0.category.importance() == $1.category.importance() {
                return $0.contact.familyName < $1.contact.familyName
            }
            return $0.category.importance() > $1.category.importance()
        }
        self.tableView.reloadData()
        saveAndUpdateTotal()
    }

    func saveAndUpdateTotal() {
        updateTotal()
        saveClientData()
        iCloudManager.backupClientData(clients, type: "Clients")
    }

    func updateTotal() {
        var totalincome: Double = 0.0
        for client in clients {
            totalincome += client.category.totalValue()
        }
        total.text = "$\(totalincome)"
    }

    func save(notification: NSNotification) {
        saveClientData()
    }

    func saveClientData() {
        let clientsData = NSKeyedArchiver.archivedDataWithRootObject(clients)
        NSUserDefaults.standardUserDefaults().setObject(clientsData, forKey: "clients")
    }

    // MARK Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        if segue.identifier == "clientInfo", let destination = segue.destinationViewController as? ClientInfoViewController, index = tableView.indexPathForSelectedRow?.row {
            destination.client = clients[index]
        }
    }

    @IBAction func unwindAndAddToList(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! NewClientViewController
        let client: Client = source.client

        if source.newClient == false {
            if let previous = source.previous, index = clients.indexOf(previous) {
                clients.removeAtIndex(index)
            }
        }
        self.clients.append(client)
        updatedClient()
    }

    @IBAction func unwindToList(segue: UIStoryboardSegue) {
        //Cancelled
    }

    // Export data
    @IBAction func export(sender: AnyObject) {
        let optionMenu = UIAlertController(title: "Export File", message: nil, preferredStyle: .ActionSheet)

        for type in CSVManager.types {
            let action = UIAlertAction(title: type, style: .Default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.exportToCSV(type)
            })
            optionMenu.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)

        self.presentViewController(optionMenu, animated: true, completion: nil)
    }

    func exportToCSV(type: String) {
        let file = iCloudManager.backupClientData(clients, type: type)
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        self.presentViewController(activityVC, animated: true, completion: nil)
    }

    // Import data
    @IBAction func importData(sender: AnyObject) {
        //TODO fix "Unbalanced calls to begin/end appearance transitions"
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], inMode: .Import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.FullScreen
        self.presentViewController(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(controller: UIDocumentPickerViewController, didPickDocumentAtURL url: NSURL) {
        if controller.documentPickerMode != UIDocumentPickerMode.Import {
            return
        }
        let error: NSErrorPointer = nil
        if let csv = CSV(contentsOfFile: url.path!, error: error) {
            for client in CSVManager.parseClients(csv) {
                clients.append(client)
            }
        }
    }
}

extension String {
    func trunc(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substringToIndex(self.startIndex.advancedBy(length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
