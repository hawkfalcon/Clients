import Foundation

class Category: NSObject, NSCoding {
    var categoryName: String
    var sections: [Section]

    init(categoryName: String, sections: [Section]) {
        self.categoryName = categoryName
        self.sections = sections
    }

    func totalValue() -> Double {
        return 0.0
    }

    func displayedValue() -> NSMutableAttributedString {
        return NSMutableAttributedString(string: "\(totalValue())")
    }

    func importance() -> Int {
        return 0
    }

    required init(coder: NSCoder) {
        self.categoryName = coder.decodeObjectForKey("categoryName") as! String
        self.sections = coder.decodeObjectForKey("sections") as! [Section]

        super.init()
    }

    func encodeWithCoder(coder: NSCoder) {
        coder.encodeObject(self.categoryName, forKey: "categoryName")
        coder.encodeObject(self.sections, forKey: "sections")
    }
}