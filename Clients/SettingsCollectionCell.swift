import UIKit

public class SettingsCollectionCell: UITableViewCell {
    @IBOutlet private weak var collectionView: UICollectionView!
 
    func addTargets(viewController: SettingsViewController) {
        collectionView.delegate = viewController
        collectionView.dataSource = viewController
    }
}
