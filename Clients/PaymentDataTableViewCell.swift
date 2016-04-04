import UIKit

public class PaymentDataTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    @IBOutlet weak var typeField: UITextField!
    
    func addTargets(viewController: UIViewController) {
        paymentField.addTarget(viewController, action: Selector("paymentFieldDidChange:"), forControlEvents: .EditingChanged)
        valueField.addTarget(viewController, action: Selector("valueFieldDidChange:"), forControlEvents: .EditingChanged)
    }
}