
import UIKit
import Foundation

class DrivePDFTableViewCell: UITableViewCell {

    @IBOutlet weak var lblValuetitle: UILabel!
    @IBOutlet weak var lblpreTitle: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
