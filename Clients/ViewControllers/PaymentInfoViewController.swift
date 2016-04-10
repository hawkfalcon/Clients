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
        
        tableView.reloadData()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        print("TEST")
        /*var mileAmount = 0.0
        if let miles = Double(miles.text!) {
            mileAmount = miles
        }*/
        //mileage = Mileage(miles: mileAmount, date: date.date)
    }
}
