import UIKit
import Contacts
//import SwiftCSV

class ClientsViewController: UITableViewController {

    @IBOutlet var total: UILabel!
    
    static let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    let archive = documentDirectory.appendingPathComponent("clients")
    
    var clients = [Client]()

    // Initialize data
    override func viewDidLoad() {
        super.viewDidLoad()
        iCloudManager.setup()

        if let data = NSKeyedUnarchiver.unarchiveObject(withFile: archive.path) as? [Client] {
            clients = data
            updateTotal()
        } else {
            //TODO help message
        }
        NotificationCenter.default.addObserver(self, selector: #selector(save), name: NSNotification.Name(rawValue: "save"), object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.updatedClient()
    }

    // Setup layout
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return clients.count
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45.0
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame

        let view = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        let left = UILabel(frame: CGRect(x: 15, y: 10, width: 300, height: 40))
        let right = UILabel()
        if let navigationBar = self.navigationController?.navigationBar {
            right.frame = CGRect(x: navigationBar.frame.width/2 - 35, y: 10, width: navigationBar.frame.width/2, height: navigationBar.frame.height)
        }
        //left.font = UIFont.systemFontOfSize(14.0)
        left.backgroundColor = UIColor.clear
        left.textColor = UIColor.orange
        left.text = "Name"
        
        right.text = "Paid          Owed"
        right.textColor = UIColor.gray
        right.textAlignment = .right
        right.backgroundColor = UIColor.clear
        
        view.addSubview(left)
        view.addSubview(right)
        
        return view
    }

    // Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell") as? ClientDataTableViewCell
        let client = clients[(indexPath as NSIndexPath).row]
        let name = "\(client.contact.familyName) \(client.contact.givenName)".trunc(length: 18)
        let coloredName = NSMutableAttributedString(string: name)
        let length = client.contact.familyName.characters.count + 1
        let startPos = length < 18 ? length : 18
        coloredName.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: NSRange(location: startPos, length: name.characters.count - startPos))

        cell?.nameLabel.attributedText = coloredName
        
        cell?.paidLabel.text = "\(client.paid().currency)"
        
        let color = client.complete() ? UIColor.black : UIColor.red
        cell?.owedLabel.textColor = color
        cell?.owedLabel.text = "\(client.owed().currency)"

        return cell!
    }


    // Allow deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            clients.remove(at: (indexPath as NSIndexPath).row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            saveAndUpdateTotal()
        }
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    // MARK Helper functions

    // Sort and refresh data
    func updatedClient() {
        self.clients.sort {
            if $0.complete() == $1.complete() {
                return $0.contact.familyName < $1.contact.familyName
            }
            return !$0.complete() && $1.complete()
        }
        tableView.reloadData()
        updateTotal()
    }

    func saveAndUpdateTotal() {
        updateTotal()
        saveClientData()
        iCloudManager.backupClientData(clients, type: "Clients")
    }

    func updateTotal() {
        var totalincome: Double = 0.0
        for client in clients {
            for (_, category) in client.categories {
                totalincome += category.total
            }
        }
        total.text = "\(totalincome.currency)"
    }

    func save(_ notification: Notification) {
        saveClientData()
    }

    func saveClientData() {
        guard NSKeyedArchiver.archiveRootObject(clients, toFile: archive.path)
        else {
            print("Failed to save clients")
            return
        }
    }

    // MARK Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let id = segue.identifier , id.hasPrefix("client"), let destination = segue.destination as? ClientInfoViewController {
            if segue.identifier == "clientInfo" {
                if let index = (tableView.indexPathForSelectedRow as NSIndexPath?)?.row {
                    destination.client = clients[index]
                }
            }
            else if segue.identifier == "clientCreation" {
                let client = Client(contact: CNContact(), categories: [:], mileage: [], notes: "", timestamp: Date())
                self.clients.append(client)
                destination.client = self.clients.last
            }
        }
    }

    // Export data
    @IBAction func export(sender: AnyObject) {
        let optionMenu = UIAlertController(title: "Export File", message: nil, preferredStyle: .actionSheet)

        for type in CSVManager.types {
            let action = UIAlertAction(title: type, style: .default, handler: {
                (alert: UIAlertAction!) -> Void in
                self.exportToCSV(type: type)
            })
            optionMenu.addAction(action)
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: {
            (alert: UIAlertAction!) -> Void in
        })
        optionMenu.addAction(cancelAction)

        self.present(optionMenu, animated: true, completion: nil)
    }

    func exportToCSV(type: String) {
        let file = iCloudManager.backupClientData(clients, type: type)
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }

    /* Import data
    @IBAction func importData(_ sender: AnyObject) {
        //TODO fix "Unbalanced calls to begin/end appearance transitions"
        let documentPicker: UIDocumentPickerViewController = UIDocumentPickerViewController(documentTypes: ["public.comma-separated-values-text"], in: .import)
        documentPicker.delegate = self
        documentPicker.modalPresentationStyle = UIModalPresentationStyle.fullScreen
        self.present(documentPicker, animated: true, completion: nil)
    }

    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentAt url: URL) {
        if controller.documentPickerMode != UIDocumentPickerMode.import {
            return
        }
        let error: NSErrorPointer? = nil
        if let csv = CSV(contentsOfFile: url.path, error: error) {
            for client in CSVManager.parseClients(csv) {
                clients.append(client)
            }
        }
        updatedClient()
    }*/
}

extension String {
    func trunc(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
