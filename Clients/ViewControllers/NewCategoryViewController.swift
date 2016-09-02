import UIKit
import Contacts
import ContactsUI

class NewCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
    @IBOutlet var done: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
    
    var category: Category!
    var name: String = ""
    
    let defaults = ["Contract", "Consultation", "Time and Materials", "Other"]
    let sections = ["Total Amount", "Category Name"]
    
    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFont(ofSize: 16.0)], for: UIControlState())
        
        tableView.delegate = self
        tableView.dataSource = self
        
        category = Category(total: 0.0, payments: [])
    }
    
    // Setup reponse
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    // Setup layout
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return defaults.count
        default:
            return 1;
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    // Populate data
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell", for: indexPath) as! TextInputTableViewCell
        
        var text = ""
        var detail = ""
        
        switch (indexPath as NSIndexPath).section {
        case 0:
            text = "Total"
            detail = "0.0"
            cell.selectionStyle = .none
            cell.textField.keyboardType = .decimalPad
        default:
            text = defaults[(indexPath as NSIndexPath).row]
            if text == defaults[0] {
                self.tableView.selectRow(at: indexPath, animated: true, scrollPosition: .none);
            }
            if text != "Custom" {
                cell.textField.isEnabled = false
            }
        }
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detail
        cell.textField.delegate = self
        
        return cell
    }
    
    // Tapped on cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath) as! TextInputTableViewCell
        if cell.textField != nil {
            cell.textField.becomeFirstResponder()
        }
    }
    
    // Populate client
    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        let totalCell = tableView.cellForRow(at: tableView.indexPathsForVisibleRows![0]) as! TextInputTableViewCell
        if let total = Double(totalCell.textField.text!) {
            category.total = total
        }
        if let selected = tableView.indexPathForSelectedRow, let cell = tableView.cellForRow(at: selected),
            let section = cell.textLabel?.text {
            name = section
        }
        print(name)
    }
}
