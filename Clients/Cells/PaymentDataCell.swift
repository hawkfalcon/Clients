import UIKit

public class PaymentDataCell: UITableViewCell {

    @IBOutlet weak var paymentField: UITextField!
    @IBOutlet weak var valueField: UITextField!

    func addTargets(viewController: ClientInfoViewController) {
        paymentField.addTarget(viewController, action: Selector(("fieldDidChange:")), for: .editingChanged)
        valueField.addTarget(viewController, action: Selector(("fieldDidChange:")), for: .editingChanged)
        paymentField.delegate = viewController
        valueField.delegate = viewController
    }
}
