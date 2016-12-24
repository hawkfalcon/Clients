import UIKit
import ChameleonFramework

class SettingsViewController: UITableViewController {
    @IBOutlet weak var includeMileage: UISwitch!
    @IBOutlet weak var colorView: UICollectionView!
    
    let colors: [UIColor] = [.flatWhite, .flatGray, .flatBlack,
                             .flatRed, .flatOrange, .flatYellow,
                             .flatGreen, .flatGreenDark, .flatBlue,
                             .flatBlueDark, .flatPurple, .flatPurpleDark]

    override func viewDidLoad() {
        super.viewDidLoad()
        colorView.delegate = self
        colorView.dataSource = self
        
        self.includeMileage.onTintColor = Settings.themeColor
    }
}

extension SettingsViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return colors.count
    }
    
    // Setup colors
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath as IndexPath)
        
        cell.backgroundColor = colors[indexPath.row]
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let color = colors[indexPath.row]
        Settings.themeColor = color
        Settings.colorUI()

        self.navigationController?.navigationBar.barTintColor = color
        self.navigationController?.navigationBar.tintColor = color
        self.navigationController?.navigationBar.backgroundColor = color
        self.includeMileage.onTintColor = color
        
        /* Outline if tapped?
        if let cell = collectionView.cellForItem(at: indexPath) {
            cell.layer.borderColor = UIColor.flatBlack.cgColor
            cell.layer.borderWidth = 5
        }*/
    }
}
