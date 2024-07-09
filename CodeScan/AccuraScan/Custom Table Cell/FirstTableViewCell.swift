
import UIKit

class FirstTableViewCell: UITableViewCell {
    @IBOutlet weak var view: UIView!
    
    @IBOutlet weak var iconImg: UIImageView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblContect: UILabel!
    
    @IBOutlet weak var imageView1: UIImageView!
    @IBOutlet weak var imageview2: UIImageView!
    @IBOutlet weak var imageview3: UIImageView!
    @IBOutlet weak var imageView4: UIImageView!
    @IBOutlet weak var view4: UIView!
    @IBOutlet weak var label1: UILabel!
    @IBOutlet weak var label2: UILabel!
    @IBOutlet weak var label3: UILabel!
    @IBOutlet weak var label4: UILabel!
    @IBOutlet weak var viewarrow1: UIView!
    @IBOutlet weak var viewarrow2: UIView!
    @IBOutlet weak var imageViewArrow: UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
