import UIKit

class NewMileageViewController: UITableViewController, UITextFieldDelegate {

    @IBOutlet var miles: UITextField!
    @IBOutlet var date: UIDatePicker!

    var mileage: Mileage!

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject!) {
        var mileAmount = 0.0
        if let miles = Double(miles.text!) {
            mileAmount = miles
        }
        mileage = Mileage(miles: mileAmount, date: date.date)
    }
}
