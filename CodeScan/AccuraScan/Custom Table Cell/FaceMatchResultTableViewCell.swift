
import UIKit
class FaceMatchResultTableViewCell: UITableViewCell {

    @IBOutlet weak var lblValueLiveness: UILabel!
    @IBOutlet weak var viewBG: UIView!
    @IBOutlet weak var lblValueFaceMatch: UILabel!
    @IBOutlet weak var imageViewIcon: UIImageView!
    
    @IBOutlet weak var viewLiveness: UIView!
    @IBOutlet weak var viewFaceMatch: UIView!
    @IBOutlet weak var viewlabelLiveness: UIView!
    
    @IBOutlet weak var viewlabelFaceMatch: UIView!
    @IBOutlet weak var btnLiveness: UIButton!
    @IBOutlet weak var btnFaceMatch: UIButton!

    @IBOutlet weak var constraintHeight: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    
}
