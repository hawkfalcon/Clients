import UIKit
import ChameleonFramework

class SettingsViewController: UITableViewController {
    @IBOutlet weak var includeMileage: UISwitch!
    @IBOutlet weak var colorView: UICollectionView!
    
    @IBOutlet weak var defaultPaymentName: UITextField!
    @IBOutlet weak var defaultPaymentType: UITextField!
    
    let colors: [UIColor] = [.flatWhite, .flatGray, .flatBlack,
                             .flatRed, .flatOrange, .flatYellow,
                             .flatGreen, .flatGreenDark, .flatBlue,
                             .flatBlueDark, .flatPurple, .flatPurpleDark]

    override func viewDidLoad() {
        super.viewDidLoad()
        colorView.delegate = self
        colorView.dataSource = self
        
        defaultPaymentName.delegate = self
        defaultPaymentType.delegate = self
        
        includeMileage.onTintColor = Settings.themeColor
        
        defaultPaymentName.text = Settings.defaultPaymentName
        defaultPaymentType.text = Settings.defaultPaymentType
        
        includeMileage.isOn = Settings.enabledMileage
    }
    
    @IBAction func switchToggle(_ sender: UISwitch) {
        Settings.enabledMileage = sender.isOn
    }
    
    @IBAction func fieldChanged(_ sender: UITextField) {
        if let name = sender.placeholder {
            if name == "Name" {
                Settings.defaultPaymentName = sender.text!
            }
            if name == "Type" {
                Settings.defaultPaymentType = sender.text!
            }
        }
    }
}

extension SettingsViewController: UITextFieldDelegate {
    
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        tableView.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
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
