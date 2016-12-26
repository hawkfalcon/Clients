import UIKit

public class NewPaymentTableViewCell: UITableViewCell {
    func configure(type: String) {
        if tag == 1 {
            return
        }
        self.tag = 1

        let cellHeight: CGFloat = 55.0

        let label = UILabel()
        label.frame = CGRect(x: 0, y: 0, width: 120, height: 40)
        label.center = CGPoint(x: 9 * self.bounds.width / 20.0, y: cellHeight / 2.0)
        label.text = "Add " + type
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: 16.0)

        self.addSubview(label)

        let button = UIButton(type: .contactAdd)
        button.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        button.center = CGPoint(x: 13 * self.bounds.width / 20.0, y: cellHeight / 2.0)
        button.isUserInteractionEnabled = false
        self.addSubview(button)
    }
}
