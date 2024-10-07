
import UIKit

class ListTableCell: UITableViewCell {

    @IBOutlet weak var lbl_list_title: UILabel!
    @IBOutlet weak var vw: UIView!
    @IBOutlet weak var img: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        vw.setShadowToView()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
