
import UIKit

class MainV: UIView {

    //MARK:- Variable
    var codeInfoV: CodeInfoV?
    var DRIVE: DrivingPDF?
    
    //MARK:- Custom Methods
    func showCodeInfoV(text: String) {
        
        let screenSize: CGRect = UIScreen.main.bounds

        codeInfoV = CodeInfoV.nib()
        codeInfoV!.frame = CGRect(x: 0, y: 0, width: screenSize.size.width - 40, height: screenSize.size.height/2)
        codeInfoV!.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        codeInfoV!.codeLbl.text = text
        addSubview(codeInfoV!)
    }
    func showCodeInfoVpdf(arrkey:Array<Any> , arrvalue:Array<Any>) {
        
        let screenSize: CGRect = UIScreen.main.bounds
        DRIVE = DrivingPDF.nib()
        DRIVE!.frame = CGRect(x: 60, y: 400, width: screenSize.size.width - 40, height: screenSize.size.height-60)
        DRIVE!.center = CGPoint(x: bounds.width / 2, y: bounds.height / 2)
        DRIVE?.keyArr = arrkey as! [String]
        DRIVE?.valueArr = arrvalue as! [String]
        addSubview(DRIVE!)
    }
    func removeAlert() {
        
        if codeInfoV != nil {
            codeInfoV!.removeFromSuperview()
            codeInfoV = nil
        }
        else if DRIVE != nil  {
            
            DRIVE!.removeFromSuperview()
            DRIVE = nil
        }
    }
    
}
