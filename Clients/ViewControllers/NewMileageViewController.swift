import UIKit

class NewMileageViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var miles: UITextField!
    @IBOutlet var date: UIDatePicker!

    var mileage: Double!
    var mileageDate: NSDate!

    override func prepare(for segue: UIStoryboardSegue, sender: Any!) {
        var mileAmount = 0.0
        if let miles = Double(miles.text!) {
            mileAmount = miles
        }
        mileage = mileAmount
        mileageDate = date.date as NSDate
    }
}
