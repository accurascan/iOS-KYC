//
//  ResultVC.swift
//  AccuraSDK
//
//  Created by Mac on 05/12/24.
//

import UIKit
//import SVProgressHUD

class ResultVC: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    var imageMICR:UIImage?
    var data = ""
    var type = ""
    
    @IBOutlet weak var micrLBL: UILabel!
    @IBOutlet weak var chequeNoLBL: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var branchLbl: UILabel!
    @IBOutlet weak var AccountLbl: UILabel!

    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var imgStView: UIView!
    @IBOutlet weak var hidecmcView: UIView!
    override func viewDidLoad() {
        super.viewDidLoad()

        print("\(self.data)")
        if type == "CMC7" {
            hidecmcView.isHidden = false
            let extractArray = extractStringsBetweenAlphabets(from: self.data)


            if extractArray.count == 4 {
                self.micrLBL.text = extractArray[1]//Bank Code
                self.codeLbl.text = extractArray[0]//Checque No.
                self.branchLbl.text = extractArray[2]// Branch
                self.AccountLbl.text = extractArray[3]// Account Number
            }else{
                self.micrLBL.text = ""
                self.codeLbl.text = ""
                self.branchLbl.text = ""
                self.AccountLbl.text = ""
            }
            
            imgStView.layer.cornerRadius = 10
            titleView.layer.cornerRadius = 10
            imageView.image = imageMICR
            self.chequeNoLBL.font = UIFont(name: "Cmc7", size: 17)//label.font = UIFont(name: "CMC-7", size: 30)
            //        self.typeView.text = self.type
            self.chequeNoLBL.text = self.data
        }else{
            hidecmcView.isHidden = true
            imgStView.layer.cornerRadius = 10
            titleView.layer.cornerRadius = 10
            imageView.image = imageMICR
            self.chequeNoLBL.text = self.data
        }
    }
    
    func extractStringsBetweenAlphabets(from input: String) -> [String] {
        var result = [String]()
        let pattern = "[A-Z]([0-9]+)" // Regular expression to find digits after a letter

        if let regex = try? NSRegularExpression(pattern: pattern, options: []) {
            let matches = regex.matches(in: input, options: [], range: NSRange(input.startIndex..., in: input))
            
            for match in matches {
                if match.numberOfRanges > 1, let range = Range(match.range(at: 1), in: input) {
                    result.append(String(input[range]))
                }
            }
        }

        return result
    }

    @IBAction func backBtn(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}
