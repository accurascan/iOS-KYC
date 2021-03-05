//
//  BarcodeTypeHFV.swift
//  CodeScan
//
// ************************** file use for set header and footer of barcode list screen ********************

import UIKit

class BarcodeTypeHFV: UITableViewHeaderFooterView {
    //MARK:- Outlet
    @IBOutlet weak var barcodeHeaderView: UIView!
    
    //MARK:- UIView Methods
    class func nib() -> BarcodeTypeHFV {
        return UINib(nibName: "BarcodeTypeHFV", bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! BarcodeTypeHFV
    }

}
