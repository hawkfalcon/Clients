import Foundation
import UIKit

class Contract: Category {
    init() {
        super.init(categoryName: "Contract", sections: [
                Section(name: "Contract Total", value: 0.0, color:
                UIColor(
                red: 0.0,
                        green: 0.5,
                        blue: 0.0,
                        alpha: 1.0
                )
                ),
                Section(name: "Down", value: 0.0),
                Section(name: "Progress", value: 0.0),
                Section(name: "Final", value: 0.0)
        ])
    }

    override func totalValue() -> Double {
        return sections[1].value + sections[2].value + sections[3].value
    }

    override func displayedValue() -> NSMutableAttributedString {
        let totalContract = sections[0].value
        let owed = totalContract - totalValue()
        let amount = NSMutableAttributedString(string: "$\(totalContract)   $\(owed)")
        let color = owed <= 0 ? UIColor.blackColor() : UIColor.redColor()

        let location = String(stringInterpolationSegment: totalContract).characters.count + 4
        let length = String(stringInterpolationSegment: owed).characters.count + 1
        amount.addAttribute(NSForegroundColorAttributeName, value: color, range: NSRange(location: location, length: length))

        return amount
    }

    override func importance() -> Int {
        return Int(sections[0].value - totalValue() != 0)
    }

    required init(coder: NSCoder) {
        super.init(coder: coder)
    }
}
