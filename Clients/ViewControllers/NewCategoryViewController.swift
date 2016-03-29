import UIKit
import Contacts
import ContactsUI

class NewCategoryViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, CNContactPickerDelegate {
    
    @IBOutlet var done: UIBarButtonItem!
    
    @IBOutlet var tableView: UITableView!
    
    var category: Category!
    var name: String = ""
    
    let defaults = ["Contract", "Consultation", "Time and Materials", "Plan", "Custom"]
    let sections = ["Total Amount", "Category Name"]
    
    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
        
        done.setTitleTextAttributes([NSFontAttributeName: UIFont.boldSystemFontOfSize(16.0)], forState: UIControlState.Normal)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        category = Category(total: 0.0, payments: [])
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
        return 2
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 1:
            return defaults.count
        default:
            return 1;
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 55.0
    }
    
    // Populate data
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("NewCell", forIndexPath: indexPath) as! TextInputTableViewCell
        
        var text = ""
        var detail = ""
        
        switch indexPath.section {
        case 0:
            text = "Total"
            detail = "0.0"
            cell.selectionStyle = .None
            cell.textField.keyboardType = .DecimalPad
        default:
            text = defaults[indexPath.row]
            if text == defaults[0] {
                self.tableView.selectRowAtIndexPath(indexPath, animated: true, scrollPosition: .None);
            }
            if text != "Custom" {
                cell.textField.enabled = false
            }
        }
        
        cell.textLabel?.text = text
        cell.detailTextLabel?.text = detail
        cell.textField.delegate = self
        
        return cell
    }
    
    // Tapped on cell
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let cell = tableView.cellForRowAtIndexPath(indexPath) as! TextInputTableViewCell
        if cell.textField != nil {
            cell.textField.becomeFirstResponder()
        }
    }
    
    // Populate client
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        let totalCell = tableView.cellForRowAtIndexPath(tableView.indexPathsForVisibleRows![0]) as! TextInputTableViewCell
        if let total = Double(totalCell.textField.text!) {
            category.total = total
        }
        if let selected = tableView.indexPathForSelectedRow, cell = tableView.cellForRowAtIndexPath(selected),
            section = cell.textLabel?.text {
            name = section
        }
        print(name)
    }
}
