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

    // Setup layout
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if mileage.count == 0 {
            return 1
        }
        return mileage.count
    }

    // Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MilesCell")! as UITableViewCell
        if mileage.count == 0 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "NewMileageCell", for: indexPath) as! NewPaymentTableViewCell
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

    // Allow deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            tableView.beginUpdates()
            client.removeFromMileage(at: indexPath.row)
            dataContext.saveChanges()
            if mileage.count == 0 {
                tableView.reloadData()
            } else {
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            tableView.endUpdates()
        }
    }

    // Tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)! as UITableViewCell
        if cell is NewPaymentTableViewCell {
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
