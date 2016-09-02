import UIKit

class MileageTableViewController: UITableViewController {

    var mileage: [Mileage]!
    var client: Client!

    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Setup layout
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mileage.count
    }

    // Populate data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MilesCell")! as UITableViewCell
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.string(from: mileage[(indexPath as NSIndexPath).row].date as Date)
        cell.textLabel?.text = String(stringInterpolationSegment: date)
        cell.detailTextLabel?.text = String(stringInterpolationSegment: mileage[(indexPath as NSIndexPath).row].miles)
        return cell
    }

    // Allow deletion
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            mileage.remove(at: (indexPath as NSIndexPath).row)
            client.mileage = mileage
            NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }

    // MARK Segues

    @IBAction func unwindAndToData(_ segue: UIStoryboardSegue) {
        let source = segue.source as! NewMileageViewController
        let data: Mileage = source.mileage
        mileage.append(data)
        client.mileage = mileage
        NotificationCenter.default.post(name: Notification.Name(rawValue: "save"), object: nil)
        self.tableView.reloadData()
    }

    @IBAction func unwindBack(_ segue: UIStoryboardSegue) {
        //Cancelled
    }

}
