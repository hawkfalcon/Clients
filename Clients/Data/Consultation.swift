import Foundation
import UIKit

class Consultation: Category {
    init() {
        super.init(categoryName: "Consultation", sections: [
                Section(name: "Hours", value: 0.0),
                Section(name: "Rate", value: 75.0)
        ])
    }

    override func totalValue() -> Double {
        return sections[0].value * sections[1].value
    }

    override func displayedValue() -> NSMutableAttributedString {
        let amount = NSMutableAttributedString(string: "$\(totalValue())")
        amount.addAttribute(NSForegroundColorAttributeName, value: UIColor.purpleColor(), range: NSRange(location: 0, length: amount.length))
        return amount
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
