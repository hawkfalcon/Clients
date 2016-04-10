import UIKit

class PaymentInfoViewController: UITableViewController, UITextFieldDelegate {
    
    var payment: Payment!
    
    @IBOutlet weak var value: UITextField!
    @IBOutlet weak var name: UITextField!
    @IBOutlet weak var type: UITextField!
    
    @IBOutlet weak var date: UIDatePicker!
    
    override func viewWillAppear(animated: Bool) {
        navigationItem.title = payment.name
        
        date.date = payment.date
        name.text = payment.name
        value.text = payment.value.currency
        type.text = payment.type
        
        value.addTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
        name.addTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
        type.addTarget(self, action: #selector(fieldDidChange), forControlEvents: .EditingChanged)
        
        date.addTarget(self, action: #selector(dateDidChange), forControlEvents: .ValueChanged)
        
        value.delegate = self
        name.delegate = self
        type.delegate = self
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func fieldDidChange(textField: UITextField) {
        if let placeholder = textField.placeholder {
            switch placeholder {
            case "Name":
                if let paymentName = name.text {
                    payment.name = paymentName
                    navigationItem.title = paymentName
                }
            case "Value":
                if let paymentValue = value.text, let rawValue = paymentValue.rawDouble {
                    payment.value = rawValue
                }
            case "Type":
                if let paymentType = type.text {
                    payment.type = paymentType
                }
            default:
                print("?")
            }
        }
    }
    
    func dateDidChange(datePicker: UIDatePicker) {
        payment.date = datePicker.date
    }
    
    // Setup reponse
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if let money = textField.text?.rawDouble {
            textField.text = money.currency
        }
    }
    
    override func scrollViewWillBeginDragging(scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
}
