import UIKit
import ChameleonFramework

class SettingsViewController: UITableViewController {
    
    let sections = ["Content", "Appearance", "Default Categories"]

    let colors: [UIColor] = [.flatRedDark, .flatOrange, .flatYellow,
                             .flatGreenDark, .flatForestGreenDark, .flatSkyBlueDark,
                             .flatBlueDark, .flatPlum, .flatPurpleDark, .flatPinkDark,
                             .flatGray, .flatBlackDark
                            ]

    override func viewDidLoad() {
        super.viewDidLoad()

        /*defaultPaymentName.text = Settings.defaultPaymentName
        defaultPaymentType.text = Settings.defaultPaymentType*/
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let section = sections[indexPath.section]
        switch section {
        case "Content":
            return createSwitchCell(indexPath: indexPath)
        case "Appearance":
            let cell = tableView.dequeueReusableCell(withIdentifier: "collectionCell", for: indexPath) as! SettingsCollectionCell
            cell.addTargets(viewController: self)
            return cell
        default:
            if indexPath.row == Settings.defaultCategories.count {
                let cell = tableView.dequeueReusableCell(withIdentifier: "newCell", for: indexPath) as! NewPaymentCell
                cell.configure(type: "Category")
                
                return cell
            }
            let cell = tableView.dequeueReusableCell(withIdentifier: "inputCell", for: indexPath) as! TextInputCell
            cell.configure(text: Settings.defaultCategories[indexPath.row], placeholder: "Category")
            cell.textField.tag = indexPath.row
            
            return cell
        }
    }
        
    func createSwitchCell(indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "basicCell", for: indexPath)
            
        cell.textLabel?.text = "Include Mileage"
            
        let toggle = UISwitch() as UISwitch
        toggle.isOn =  Settings.enabledMileage
        toggle.onTintColor = Settings.themeColor
        toggle.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
            
        cell.accessoryView = toggle
            
        return cell
    }
    
    func switchChanged(_ toggle: UISwitch) {
        Settings.enabledMileage = toggle.isOn
    }
    
    // Tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if cell is NewPaymentCell {
            tableView.beginUpdates()
            Settings.defaultCategories.insert("Category", at: indexPath.row)
            tableView.insertRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // Allow deletion
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return sections[indexPath.section].contains("Default") && (indexPath.row != Settings.defaultCategories.count)
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            Settings.defaultCategories.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    
    // Setup layout
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let section = sections[indexPath.section]
        switch section {
        case "Appearance":
            return 135.0
        case "Default Categories":
            if indexPath.row == Settings.defaultCategories.count {
                return 55.0
            }
            return 35.0
        default:
            return 55.0
        }
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let category = sections[section]
        return category
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return sections.count
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if sections[section] == "Default Categories" {
            return Settings.defaultCategories.count + 1
        }
        return 1
    }

    @IBAction func fieldChanged(_ sender: UITextField) {
        if let name = sender.placeholder {
            switch name {
            case "Category":
                Settings.updateDefaultCategories(index: sender.tag, category: sender.text!)
            case "Type":
                Settings.defaultPaymentType = sender.text!
            default:
                return
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
        
        let toggleCell = tableView.cellForRow(at: IndexPath(row: 0, section: 0))
        let toggle = toggleCell?.accessoryView as! UISwitch
        toggle.onTintColor = color
    }
}
