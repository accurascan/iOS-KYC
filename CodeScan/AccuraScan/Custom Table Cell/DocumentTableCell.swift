
import UIKit

class DocumentTableCell: UITableViewCell {
   
    @IBOutlet weak var lblDocName: UILabel!
    @IBOutlet weak var imgDocument: UIImageView!
    @IBOutlet weak var constraintLblHeight: NSLayoutConstraint!
    @IBOutlet weak var viewBG: UIView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.selectionStyle = .none
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
