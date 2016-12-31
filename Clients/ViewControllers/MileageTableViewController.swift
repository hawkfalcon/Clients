import UIKit
import CoreData

class MileageTableViewController: UITableViewController {

    var mileage: NSOrderedSet!
    var client: Client!

    var dataContext: NSManagedObjectContext!

    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MilesCell")! as UITableViewCell
        if indexPath.row == client.mileage!.count {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewMileageCell", for: indexPath) as! NewPaymentCell
            cell.configure(type: "Mileage")
            return cell
        }
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"

        let miles = mileage.object(at: indexPath.row) as? Mileage
        let date = formatter.string(from: miles!.date as! Date)
        cell.textLabel?.text = String(stringInterpolationSegment: date)
        cell.detailTextLabel?.text = String(stringInterpolationSegment: miles!.miles)
        return cell
    }
    
    // MARK: - Header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerFrame = tableView.frame
        
        let view = UIView(frame: CGRect(x: 0, y: 0, width: headerFrame.size.width, height: headerFrame.size.height))
        let left = UILabel(frame: CGRect(x: 15, y: 0, width: 300, height: 40))
        let right = UILabel()
        if let navigationBar = self.navigationController?.navigationBar {
            right.frame = CGRect(x: navigationBar.frame.width / 2 - 15, y: 0, width: navigationBar.frame.width / 2, height: navigationBar.frame.height)
        }

        left.backgroundColor = UIColor.clear
        left.textColor = Settings.themeColor
        left.text = "Date"
        
        right.text = "Miles"
        right.textColor = UIColor.gray
        right.textAlignment = .right
        right.backgroundColor = UIColor.clear
        
        view.addSubview(left)
        view.addSubview(right)
        
        return view
    }

    // Allow deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            client.removeFromMileage(at: indexPath.row)
            dataContext.saveChanges()
            tableView.deleteRows(at: [indexPath], with: .automatic)
            tableView.endUpdates()
        }
    }
    
    // Setup layout
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return indexPath.row != client.mileage!.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mileage.count + 1
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55.0
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 35.0
    }
    
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.01
    }

    // Tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if cell is NewPaymentCell {
            performSegue(withIdentifier: "milesSegue", sender: self)
        }
    }


    // MARK Segues

    @IBAction func unwindAndToData(_ segue: UIStoryboardSegue) {
        let source = segue.source as! NewMileageViewController

        let miles = Mileage(context: dataContext)
        miles.miles = source.mileage
        miles.date = source.mileageDate

        client.addToMileage(miles)

        dataContext.saveChanges()
        self.tableView.reloadData()
    }

    @IBAction func unwindBack(_ segue: UIStoryboardSegue) {
        //Cancelled
    }
}
