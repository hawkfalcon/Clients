import UIKit
import Contacts
import CoreData

class ClientsViewController: UITableViewController {

    @IBOutlet var total: UILabel!

    var dataContext: NSManagedObjectContext!

    // MARK: - Core Data Control

    lazy var dataController: NSFetchedResultsController<Client> = {
        let fetchRequest: NSFetchRequest<Client> = Client.fetchRequest()

        let sortComplete = NSSortDescriptor(key: #keyPath(Client.complete), ascending: true)
        let sortName = NSSortDescriptor(key: #keyPath(Client.lastName), ascending: true)
        fetchRequest.sortDescriptors = [sortComplete, sortName]

        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.dataContext, sectionNameKeyPath: nil, cacheName: nil)

        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            return
        }

        dataContext = appDelegate.persistentContainer.viewContext

        do {
            try self.dataController.performFetch()
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateTotal()

        tableView.reloadData()
    }

    // MARK: - Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame

        let view = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        let left = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 40))
        let right = UILabel()
        if let navigationBar = self.navigationController?.navigationBar {
            right.frame = CGRect(x: navigationBar.frame.width / 2 - 35, y: 0, width: navigationBar.frame.width / 2, height: navigationBar.frame.height)
        }
        //left.font = UIFont.systemFontOfSize(14.0)
        left.backgroundColor = UIColor.clear
        left.textColor = Settings.themeColor
        left.text = "Name"

        right.text = "Paid          Owed"
        right.textColor = UIColor.gray
        right.textAlignment = .right
        right.backgroundColor = UIColor.clear

        view.addSubview(left)
        view.addSubview(right)

        return view
    }

    // MARK: - Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ClientCell", for: indexPath) as? ClientDataCell else {
            fatalError("Unexpected Cell")
        }

        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: ClientDataCell, at indexPath: IndexPath) {
        let client = dataController.object(at: indexPath)

        // Configure Cell
        if let first = client.firstName, let last = client.lastName {
            let name = "\(last) \(first)".trunc(length: 18)
            let length = last.characters.count + 1
            let startPos = length < 18 ? length : 18

            let coloredName = NSMutableAttributedString(string: name)
            coloredName.addAttribute(NSForegroundColorAttributeName, value: UIColor.gray, range: NSRange(location: startPos, length: name.characters.count - startPos))

            cell.nameLabel.attributedText = coloredName
        }

        cell.paidLabel.text = "\(client.paid().currency)"

        let color = client.complete ? UIColor.black : UIColor.red
        cell.owedLabel.textColor = color
        cell.owedLabel.text = "\(client.owed().currency)"
    }

    // MARK: - Layout Setup
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let sectionInfo = dataController.sections?[section] else {
            return 0
        }

        return sectionInfo.numberOfObjects
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }

    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let client = dataController.object(at: indexPath)
            client.managedObjectContext?.delete(client)
            dataContext.saveChanges()
        }
    }

    // MARK: - Helper functions

    func updateTotal() {
        var totalIncome: Double = 0.0
        for client in dataController.fetchedObjects! {
            for category in client.categories! {
                let category = category as! Category
                for payment in category.payments! {
                    let payment = payment as! Payment
                    totalIncome += payment.value
                }
            }
        }
        total.text = "\(totalIncome.currency)"
    }

    // MARK: - Settings
    @IBAction func unwindSettings(_ segue: UIStoryboardSegue) {
        //let source = segue.source as! SettingsViewController

        tableView.reloadData()
    }


    // MARK: - Segue

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        if let id = segue.identifier, id.hasPrefix("client"), let destination = segue.destination as? ClientInfoViewController {

            destination.dataContext = dataContext

            if let index = tableView.indexPathForSelectedRow, segue.identifier == "clientInfo" {
                destination.client = dataController.object(at: index)
            }
        }
    }

    // MARK: - Export data
    @IBAction func export(sender: AnyObject) {
        let optionMenu = UIAlertController(title: "Export File", message: nil, preferredStyle: .actionSheet)

        for type in FileCreator.types {
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
        let file = FileCreator.createFile(clients: dataController.fetchedObjects!, type: type)
        let activityVC = UIActivityViewController(activityItems: [file], applicationActivities: nil)
        self.present(activityVC, animated: true, completion: nil)
    }

    /* Import data: TODO
     static let documentDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
     let archive = documentDirectory.appendingPathComponent("clients")
     
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

extension ClientsViewController: NSFetchedResultsControllerDelegate {

    // MARK: - Allow Deletion, Insertion, etc
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? ClientDataCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension Client {
    func owed() -> Double {
        var owed = 0.0
        for category in self.categories! {
            let category = category as! Category
            var stillOwed = category.total
            for payment in category.payments! {
                let payment = payment as! Payment
                stillOwed -= payment.value
            }
            owed += stillOwed
        }

        return owed
    }

    func paid() -> Double {
        var paid = 0.0
        for category in self.categories! {
            let category = category as! Category
            for payment in category.payments! {
                let payment = payment as! Payment
                paid += payment.value
            }
        }

        return paid
    }
}

extension String {
    // Truncates too long str...
    func trunc(length: Int, trailing: String? = "...") -> String {
        if self.characters.count > length {
            return self.substring(to: self.characters.index(self.startIndex, offsetBy: length)) + (trailing ?? "")
        } else {
            return self
        }
    }
}
