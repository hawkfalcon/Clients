import UIKit

public class NewPaymentTableViewCell: UITableViewCell {
    func configure() {
        let cellHeight: CGFloat = 55.0

        let label = UILabel()
        label.frame = CGRectMake(0, 0, 120, 40)
        label.center = CGPoint(x:  9 * self.bounds.width / 20.0, y: cellHeight / 2.0)
        label.text = "Add Payment"
        label.textAlignment = .Center
        label.font = UIFont.boldSystemFontOfSize(16.0)
        
        self.addSubview(label)
    
        let button = UIButton(type: .ContactAdd)
        button.frame = CGRectMake(0, 0, 40, 40)
        button.center = CGPoint(x: 13 * self.bounds.width / 20.0, y: cellHeight / 2.0)
        button.userInteractionEnabled = false
        self.addSubview(button)
    }
}