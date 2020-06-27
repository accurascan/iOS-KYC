
import UIKit

class CodeInfoV: UIView {
    
    //MARK:- Outlet
    @IBOutlet weak var codeLbl: UILabel!
    
    //MARK:- UIView Methods
    override func awakeFromNib() {
        super.awakeFromNib()
        layer.cornerRadius = 3.0
    }
    
    class func nib() -> CodeInfoV {
        return UINib(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! CodeInfoV
    }

}
