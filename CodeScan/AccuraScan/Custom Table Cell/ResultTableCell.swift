
import UIKit

class ResultTableCell: UITableViewCell {

    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblValue: UILabel!
    @IBOutlet weak var lblSinglevalue: UILabel!
    
    @IBOutlet weak var constarintViewHaderHeight: NSLayoutConstraint!
    @IBOutlet weak var lblSide: UILabel!
    @IBOutlet weak var viewHeader: UIView!
    @IBOutlet weak var viewData: UIView!
    
    @IBOutlet weak var imageViewSignHeight: NSLayoutConstraint!
    @IBOutlet weak var imageViewSign: UIImageView!
    @IBOutlet weak var SignImageBG: UIView!
    
    var isCheckCell: Bool?
       var pageType: NAV_PAGETYPE = .Default
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
}
