
import UIKit

class DrivingPDFstringTableViewCell: UITableViewCell {

    @IBOutlet weak var lblWholerstr: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
