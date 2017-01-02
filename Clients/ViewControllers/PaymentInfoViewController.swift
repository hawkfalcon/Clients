import UIKit

class PaymentInfoViewController: UITableViewController {

    var payment: Payment!
    
    var defaults: [String]!
    let sections = ["Payment", "Payment Name", "Date", "Payment Type"]

    var lastSelected: TextInputCell!

    override func viewWillAppear(_ animated: Bool) {
        navigationItem.title = payment.name
        
        defaults = Settings.defaultPaymentNames
        defaults.append("Custom")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.delegate = self
        tableView.dataSource = self
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        switch section {
            case "Payment":
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextInputCell
                cell.configure(text: payment.value.currency, placeholder: "Amount")
                cell.textLabel?.text = "Amount"
                cell.textField.keyboardType = .decimalPad
                cell.textField.delegate = self
                
                cell.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
                return cell
            case "Payment Name":
                let cell = tableView.dequeueReusableCell(withIdentifier: "NewCell") as! TextInputCell
                let text = defaults[indexPath.row]
                let custom = !defaults.contains(payment.name!)
                if !custom && text == payment.name || custom && text == "Custom" {
                    cell.accessoryType = .checkmark
                    lastSelected = cell
                }
                if text != "Custom" {
                    cell.textField.isEnabled = false
                } else {
                    cell.textField.placeholder = "Payment Name"
                    if custom {
                        cell.textField.text = payment.name
                    }
                }
                cell.textLabel?.text = text
                cell.textField.delegate = self
            
                cell.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)
            
                return cell
            case "Payment Type":
                let cell = tableView.dequeueReusableCell(withIdentifier: "textCell") as! TextInputCell
                cell.configure(text: payment.type!, placeholder: "Payment Type")
                cell.textLabel?.text = "Payment Type"
                cell.textField.addTarget(self, action: #selector(fieldDidChange), for: .editingChanged)

                return cell
            default:
                let cell = tableView.dequeueReusableCell(withIdentifier: "dateCell") as! DatePickerCell
                cell.datePicker.addTarget(self, action: #selector(dateDidChange), for: .valueChanged)
                cell.datePicker.date = payment.date as! Date
                return cell
            
        }
    }
    
    // Setup layout
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sections[section]
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
            case "Date":
                return 220.0
            case "Payment Name":
                return 40.0
            default:
                return 55.0
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 18.0;
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0 {
            return 36.0
        }
        return 18.0;
    }
    
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        tableView.endEditing(true)
        if sections[indexPath.section] != "Payment Name" {
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

        if let section = lastSelected.textLabel?.text {
            if section != "Custom" {
                payment.name = section
                navigationItem.title = section
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == "Payment Name" {
            return defaults.count
        }
        return 1
    }
    
    func dateDidChange(_ datePicker: UIDatePicker) {
        payment.date = datePicker.date as NSDate?
    }
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
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
}


extension PaymentInfoViewController: UITextFieldDelegate {
    func fieldDidChange(_ textField: UITextField) {
        if let placeholder = textField.placeholder, let text = textField.text {
            switch placeholder {
            case "Payment Name":
                payment.name = textField.text!.capitalized
                navigationItem.title = payment.name
            case "Amount":
                if let rawValue = text.rawDouble {
                    payment.value = rawValue
                }
            case "Payment Type":
                payment.type = textField.text!.capitalized
            default:
                print("?")
            }
        }
    }
    
    // Setup reponse
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField.placeholder! == "Payment Name" {
            let indexPath = IndexPath(row: defaults.count - 1, section: 1)
            tableView.selectRow(at: indexPath, animated: true, scrollPosition: .bottom)
            let cell = tableView.cellForRow(at: indexPath) as! TextInputCell
            checkMark(indexPath: indexPath, cell: cell)
        }
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        if let money = textField.text?.rawDouble {
            textField.text = money.currency
        }
    }

}
