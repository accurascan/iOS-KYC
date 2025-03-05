//
//  MICRVC.swift
//  AccuraSDK
//
//  Created by Mac on 05/12/24.
//  Copyright © 2024 Elite Development LLC. All rights reserved.
//

import UIKit
import AccuraMICR

class MICRVC: UIViewController {
    
    
    
    @IBOutlet weak var startScanningBtn: UIButton!

    var accuraCameraWrapper: AccuraMICRWrapper? = nil
    var selectedBank: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        accuraCameraWrapper = AccuraMICRWrapper.init()
        
            let sdkModel = self.accuraCameraWrapper?.loadEngine(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)
            if sdkModel!.i > 0 {
                print(sdkModel?.isMICREnable)
            }
            self.accuraCameraWrapper?.setGlarePercentage(-1, intMax: -1)
            self.accuraCameraWrapper?.setBlurPercentage(-1)

    }
    
    override func viewWillAppear(_ animated: Bool) {

    }
    
    @IBAction func startScanning(_ sender: UIButton) {   
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5){
            self.showCheckTypeSelection(in: self) { selectedType in
                   if let type = selectedType {
                       print("User selected: \(type)")
                       let vc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                       vc.selectedBankName = type
                       self.navigationController?.pushViewController(vc, animated: true)
                   } else {
                       print("User canceled selection")
                   }
               }

        }
    }
    
    func showCheckTypeSelection(in viewController: UIViewController, completion: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "Select Cheque Type", message: "Please choose an option", preferredStyle: .alert)

        // E13B Option
        alertController.addAction(UIAlertAction(title: "E13B", style: .default, handler: { _ in
            completion("E13B")
        }))
        
        // CMC7 Option
        alertController.addAction(UIAlertAction(title: "CMC7", style: .default, handler: { _ in
            completion("CMC7")
        }))

        // Cancel Option
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { _ in
            completion(nil) // User canceled
        }))

        // Present the alert
        viewController.present(alertController, animated: true, completion: nil)
    }

    @IBAction func orientationBtn(_ sender: UIButton) {
        if(sender.isSelected == true) {
            sender.isSelected = false
            AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        } else {
            sender.isSelected = true
            AppDelegate.AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        }
    }
    
}
