
import UIKit

class CountryListCell: UITableViewCell {

    //MARK:- Outlet
    @IBOutlet weak var lblCountryName: UILabel!
    @IBOutlet weak var viewCountryName: UIView!
    
    //MARK:- View Controller Method
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    
    }

}
