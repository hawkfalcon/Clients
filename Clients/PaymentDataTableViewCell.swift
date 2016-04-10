import UIKit

public class PaymentDataTableViewCell: UITableViewCell {
    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var valueField: UITextField!
    
    func addTargets(viewController: ClientInfoViewController) {
        paymentField.addTarget(viewController, action: Selector("fieldDidChange:"), forControlEvents: .EditingChanged)
        valueField.addTarget(viewController, action: Selector("fieldDidChange:"), forControlEvents: .EditingChanged)
        paymentField.delegate = viewController
        valueField.delegate = viewController
    }
}