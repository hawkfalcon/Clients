import UIKit

class MileageTableViewController: UITableViewController {

    var mileage: [Mileage]!
    var client: Client!

    // Initialize
    override func viewDidLoad() {
        super.viewDidLoad()
    }

    // Setup layout
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return mileage.count
    }

    // Populate data
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("MilesCell")! as UITableViewCell
        let formatter = NSDateFormatter()
        formatter.dateFormat = "MM/dd/yyyy"
        let date = formatter.stringFromDate(mileage[indexPath.row].date)
        cell.textLabel?.text = String(stringInterpolationSegment: date)
        cell.detailTextLabel?.text = String(stringInterpolationSegment: mileage[indexPath.row].miles)
        return cell
    }

    // Allow deletion
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            mileage.removeAtIndex(indexPath.row)
            client.mileage = mileage
            NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }

    // MARK Segues

    @IBAction func unwindAndToData(segue: UIStoryboardSegue) {
        let source = segue.sourceViewController as! NewMileageViewController
        let data: Mileage = source.mileage
        mileage.append(data)
        client.mileage = mileage
        NSNotificationCenter.defaultCenter().postNotificationName("save", object: nil)
        self.tableView.reloadData()
    }

    @IBAction func unwindBack(segue: UIStoryboardSegue) {
        //Cancelled
    }

}
