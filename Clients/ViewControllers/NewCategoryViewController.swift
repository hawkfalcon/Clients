import UIKit
import Contacts
import ContactsUI
import CoreData

class NewCategoryViewController: UITableViewController, UITextFieldDelegate, CNContactPickerDelegate {

    @IBOutlet var done: UIBarButtonItem!

    var name: String = ""
    var total: Double = 0.0

    var defaults: [String]!
    let sections = ["Total Amount", "Category Name"]
    
    var lastSelected: TextInputCell!

    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()

        done.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControlState())

        tableView.delegate = self
        tableView.dataSource = self
        tableView.allowsSelectionDuringEditing = true

        defaults = Settings.defaultCategories
        defaults.append("Custom")
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

    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }

    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.placeholder! == "Category Name" {
            let indexPath = tableView.indexPathsForVisibleRows!.last!
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            let cell = tableView.cellForRow(at: indexPath) as! TextInputCell
            checkMark(indexPath: indexPath, cell: cell)
        }
    }

    // Setup layout
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return defaults.count
        default:
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section != 0 {
            return 40.0
        }
        return 55.0
    }

    // Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath) as! TextInputCell

        var text = ""

        switch indexPath.section {
        case 0:
            text = "Total"
            cell.selectionStyle = .none
            cell.textField.keyboardType = .decimalPad
            cell.textField.placeholder = "0.0"
            cell.textField.text = 0.0.currency
        default:
            text = defaults[indexPath.row]
            if text == defaults[0] {
                cell.accessoryType = .checkmark
                lastSelected = cell
            }
            if text != "Custom" {
                cell.textField.isEnabled = false
            } else {
                cell.textField.placeholder = "Category Name"
            }
        }

        cell.textLabel?.text = text
        cell.textField.delegate = self

        return cell
    }

    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.endEditing(true)
        if indexPath.section == 0 {
            return nil
        }
        tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
        return indexPath
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath) as! TextInputCell
        if cell.textField != nil {
            cell.textField.becomeFirstResponder()
        }
        checkMark(indexPath: indexPath, cell: cell)
    }
    
    func checkMark(indexPath: IndexPath, cell: UITableViewCell) {
        tableView.deselectRow(at: indexPath, animated: true)
        if lastSelected == cell {
            return
        }
        cell.accessoryType = .checkmark
        lastSelected.accessoryType = .none
        lastSelected = cell as! TextInputCell
    }
    
    // Populate client
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let totalCell = tableView.cellForRow(at: tableView.indexPathsForVisibleRows![0]) as! TextInputCell
        if let totalField = totalCell.textField.text!.rawDouble {
            total = totalField
        }
        if let section = lastSelected.textLabel?.text {
            if section == "Custom" {
                name = lastSelected.textField.text!.capitalized
            } else {
                name = section
            }
            print(name)
        }
    }
}
