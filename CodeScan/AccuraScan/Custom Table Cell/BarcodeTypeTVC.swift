//
//  BarcodeTypeTVC.swift
//  CodeScan
//
// ************************** file use to display different bar code list ********************

import UIKit
import AVFoundation

let APP_NAME: String = "Accura Scan"

let FLASH_WHITE: String = "flash-white"
let FLASH_OFF_WHITE: String = "flash-off-white"
let MENU_WHITE: String = "menu-white"
let BACK_WHITE: String = "back-white"
let CHECK_BLUE: String = "check-blue"

let CODE_SCAN_VC: String = "CodeScanVC"
let SELECT_CODE_VC: String = "SelectCodeVC"

let BARCODE_TYPE_TVC: String = "BarcodeTypeTVC"
let MENU_TYPE_TVC: String = "MenuTableViewCell"
let CONTACT_CODE_VC: String = "ContactUsViewController"
let ABOUT_CODE_VC: String = "AboutUsViewController"

let DOC_CODE_VC: String = "DocumentViewController"
let Contact_us: String = "Contact US"

class BarcodeTypeTVC: UITableViewCell {
    
    //MARK:- Outlet
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var validationImageView: UIImageView!
    
    //MARK:- Variable
    var code: String!
    
    //MARK:- UIView methods
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    class func nib() -> UINib {
        return UINib(nibName: self.nameOfClass, bundle: nil)
    }

    //MARK:- Custom methods
    func setSelected(code: String) {
        self.code = code
        
//        var stringCode: String!

//        switch code
//        {
//        case AVMetadataObject.ObjectType.ean8:
//            stringCode = "EAN-8"
//        case AVMetadataObject.ObjectType.ean13:
//            stringCode = "EAN-13"
//        case AVMetadataObject.ObjectType.pdf417:
//            stringCode = "PDF417"
//        case AVMetadataObject.ObjectType.aztec:
//            stringCode = "Aztec"
//        case AVMetadataObject.ObjectType.code128:
//            stringCode = "Code128"
//        case AVMetadataObject.ObjectType.code39:
//            stringCode = "Code39"
//        case AVMetadataObject.ObjectType.code39Mod43:
//            stringCode = "Code39Mod43"
//        case AVMetadataObject.ObjectType.code93:
//            stringCode = "Code93"
//        case AVMetadataObject.ObjectType.dataMatrix:
//            stringCode = "DataMatrix"
//        case AVMetadataObject.ObjectType.face:
//            stringCode = "Face"
//        case AVMetadataObject.ObjectType.interleaved2of5:
//            stringCode = "Interleaved2of5"
//        case AVMetadataObject.ObjectType.itf14:
//            stringCode = "ITF14"
//        case AVMetadataObject.ObjectType.qr:
//            stringCode = "QRCode"
//        case AVMetadataObject.ObjectType.upce:
//            stringCode = "UPC-E"
//        default:
//            break
//        }
        
        nameLbl.text = code
        nameLbl.textColor = UIColor.metallicSeaweed
//        validationImageView.image = UIImage(named: CHECK_BLUE)
    }
    
    func setUnselected(code: String) {
        self.code = code

//        var stringCode: String!
        
//        switch code {
//        case AVMetadataObject.ObjectType.ean8:
//            stringCode = "EAN-8"
//        case AVMetadataObject.ObjectType.ean13:
//            stringCode = "EAN-13"
//        case AVMetadataObject.ObjectType.pdf417:
//            stringCode = "PDF417"
//        case AVMetadataObject.ObjectType.aztec:
//            stringCode = "Aztec"
//        case AVMetadataObject.ObjectType.code128:
//            stringCode = "Code128"
//        case AVMetadataObject.ObjectType.code39:
//            stringCode = "Code39"
//        case AVMetadataObject.ObjectType.code39Mod43:
//            stringCode = "Code39Mod43"
//        case AVMetadataObject.ObjectType.code93:
//            stringCode = "Code93"
//        case AVMetadataObject.ObjectType.dataMatrix:
//            stringCode = "DataMatrix"
//        case AVMetadataObject.ObjectType.face:
//            stringCode = "Face"
//        case AVMetadataObject.ObjectType.interleaved2of5:
//            stringCode = "Interleaved2of5"
//        case AVMetadataObject.ObjectType.itf14:
//            stringCode = "ITF14"
//        case AVMetadataObject.ObjectType.qr:
//            stringCode = "QRCode"
//        case AVMetadataObject.ObjectType.upce:
//            stringCode = "UPC-E"
//        default:
//            break
//        }

        nameLbl.text = code
        nameLbl.textColor = UIColor.black
//        validationImageView.image = nil
    }
    
}


extension UIColor {
    
    static var metallicSeaweed: UIColor {
        return UIColor(red: 213.0 / 255.0, green: 50.0 / 255.0, blue: 63.0 / 255.0, alpha: 1.0) //#0E7F9C
    }
    
    static var isabelline: UIColor {
        return UIColor(red: 238.0 / 255.0, green: 238.0 / 255.0, blue: 238.0 / 255.0, alpha: 1.0) //#EEEEEE
    }
    
    static var indianRed: UIColor {
        return UIColor(red: 218.0 / 255.0, green: 90.0 / 255.0, blue: 99.0 / 255.0, alpha: 1.0) //#DA5A63
    }
    static var btnRed: UIColor {
        return UIColor(red: 137.0 / 255.0, green: 28.0 / 255.0, blue: 36.0 / 255.0, alpha: 1.0) //#891C24
    }

    
}
