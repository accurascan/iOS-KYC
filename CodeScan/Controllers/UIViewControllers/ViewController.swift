
import UIKit
import AVFoundation
import AccuraMICR
//import TesseractOCRSDKiOS

class ViewController: UIViewController {
    
    @IBOutlet weak var _viewLayer: UIView!
    @IBOutlet weak var _imageView: UIImageView!
    @IBOutlet weak var _imgFlipView: UIImageView!
    @IBOutlet weak var _lblTitle: UILabel!
    @IBOutlet weak var _constant_height: NSLayoutConstraint!
    @IBOutlet weak var _constant_width: NSLayoutConstraint!
    
    @IBOutlet weak var AspectRatio: NSLayoutConstraint!
    @IBOutlet weak var lblOCRMsg: UILabel!
    @IBOutlet weak var lblTitleCountryName: UILabel!
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var viewNavigationBar: UIView!
    
    
    //MARK:- Variable
    var accuraCameraWrapper: AccuraMICRWrapper? = nil
    var isFirstTimeCome = true
    var selectedBankName = ""
    var isCheckFirstTime : Bool?
    var isFirstTimeStartCamara: Bool?
    var statusBarRect = CGRect()
    var bottomPadding:CGFloat = 0.0
    var topPadding: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
         
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self._imageView.setNeedsLayout()
        self._imageView.layoutSubviews()
        self._imageView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _lblTitle.text = "Scan Cheque"
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0, execute: {
            self.isFirstTimeCome = true
        })
        
        statusBarRect = UIApplication.shared.statusBarFrame
        let window = UIApplication.shared.windows.first
       
        if #available(iOS 11.0, *) {
            bottomPadding = window!.safeAreaInsets.bottom
            topPadding = window!.safeAreaInsets.top
        } else {
            // Fallback on earlier versions
        }
        
        isFirstTimeStartCamara = false
        isCheckFirstTime = false
        _imageView.layer.masksToBounds = false
        _imageView.clipsToBounds = true
        ChangedOrientation()
        var width : CGFloat = 0
        var height : CGFloat = 0
        width = UIScreen.main.bounds.size.width
        height = UIScreen.main.bounds.size.height
        width = width * 0.95
        height = height * 0.35

        let status = AVCaptureDevice.authorizationStatus(for: .video)
        _viewLayer.layer.borderColor = UIColor.white.cgColor
        _viewLayer.layer.borderWidth = 3.0
        self._imgFlipView.isHidden = true
        if status == .authorized {
           isCheckFirstTime = true
            self.setMICRData()
            let shortTap = UITapGestureRecognizer(target: self, action: #selector(handleTapToFocus(_:)))
            shortTap.numberOfTapsRequired = 1
            shortTap.numberOfTouchesRequired = 1
            self.view.addGestureRecognizer(shortTap)
        } else if status == .denied {
            let alert = UIAlertController(title: "AccuraSdk", message: "It looks like your privacy settings are preventing us from accessing your camera.", preferredStyle: .alert)
            let yesButton = UIAlertAction(title: "OK", style: .default) { _ in
                if #available(iOS 10.0, *) {
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
            alert.addAction(yesButton)
            self.present(alert, animated: true, completion: nil)
        } else if status == .restricted {
        } else if status == .notDetermined  {
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                   self.isCheckFirstTime = true
                    self.isFirstTimeStartCamara = true
                    DispatchQueue.main.async {
                        self._imageView.setNeedsLayout()
                        self._imageView.layoutSubviews()
                        self.setMICRData()

                        self.ChangedOrientation()
                        self.accuraCameraWrapper?.startCamera()
                    }
                    let shortTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapToFocus(_:)))
                    shortTap.numberOfTapsRequired = 1
                    shortTap.numberOfTouchesRequired = 1
                } else {
                    // print("Not granted access")
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isFirstTimeStartCamara! && isCheckFirstTime!{

          isFirstTimeStartCamara = true
          accuraCameraWrapper?.startCamera()
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        accuraCameraWrapper?.stopCamera()
        accuraCameraWrapper = nil
        _imageView.image = nil
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        accuraCameraWrapper?.stopCamera()
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Other Method
    func setMICRData(){
        let bankCode = whichBankCode(name: selectedBankName)
        accuraCameraWrapper = AccuraMICRWrapper.init(delegate: self, andImageView: _imageView, andLabelMsg: lblOCRMsg, andurl: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, type: bankCode)
    }
    
    @objc private func ChangedOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        let orientastion = UIApplication.shared.statusBarOrientation
        if(orientastion ==  UIInterfaceOrientation.portrait) {
            width = UIScreen.main.bounds.size.width * 0.85
            
            height  = (UIScreen.main.bounds.size.height - (self.bottomPadding + self.topPadding + self.statusBarRect.height)) * 0.35
//            viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        } else {

            self.viewNavigationBar.backgroundColor = .clear
            height = UIScreen.main.bounds.size.height * 0.62
            width = UIScreen.main.bounds.size.width * 0.51
        }
       
        _constant_width.constant = width
        self._constant_height.constant = 170
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
                self.view.layoutIfNeeded()
            }) { _ in
                
            }
        }
    }
    
    @objc func handleTapToFocus(_ tapGesture: UITapGestureRecognizer?) {
        let acd = AVCaptureDevice.default(for: .video)
        if tapGesture!.state == .ended {
            let thisFocusPoint = tapGesture!.location(in: _viewLayer)
            let focus_x = Double(thisFocusPoint.x / _viewLayer.frame.size.width)
            let focus_y = Double(thisFocusPoint.y / _viewLayer.frame.size.height)
            if acd?.isFocusModeSupported(.autoFocus) ?? false && acd?.isFocusPointOfInterestSupported != nil {
                do {
                    try acd?.lockForConfiguration()
                    
                    if try acd?.lockForConfiguration() != nil {
                        acd?.focusMode = .autoFocus
                        acd?.focusPointOfInterest = CGPoint(x: CGFloat(focus_x), y: CGFloat(focus_y))
                        acd?.unlockForConfiguration()
                    }
                } catch {
                }
            }
        }
    }
    
}



extension ViewController: VideoCameraWrapperDelegate {

    func  onUpdateLayout(_ frameSize: CGSize, _ borderRatio: Float) {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
//        if(isCheckScanOCR) {
                let orientastion = UIApplication.shared.statusBarOrientation
                if(orientastion ==  UIInterfaceOrientation.portrait) {
                    width = frameSize.width
                    height  = frameSize.height
//                    viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                } else {

//                    self.viewNavigationBar.backgroundColor = .clear
                    height = (((UIScreen.main.bounds.size.height - 100) * 5) / 5.6)
                    width = (height / CGFloat(borderRatio))
                    print("boreder ratio :- ", borderRatio)
                }
                print("layer", width)
                DispatchQueue.main.async {
                    self._constant_width.constant = width
                   
                    self._constant_height.constant = height
                }
                
            
//        }
       
        
    }
    
    

    func recognizeSucceedMICR(_ scanedInfo: String!, photoImage: UIImage!) {
        if isFirstTimeCome {
            isFirstTimeCome = false
//            var data = "\(scanedInfo) \n \(type)"
            showResultVC(with: photoImage, data: scanedInfo)
        }
    }

    // Function to navigate to the ResultVC
    func showResultVC(with image: UIImage, data: String) {
        DispatchQueue.main.async{
            let vc: ResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ResultVC") as! ResultVC
            vc.imageMICR = image
            vc.data = data
            vc.type = self.selectedBankName
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    
    func recognizeFailed(_ message: String!) {
        let alert = UIAlertController(title: "AccuraSDK", message: message, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(yesButton)
        self.present(alert, animated: true, completion: nil)
    }

    func reco_msg(_ message: String!) {
        var msg = String();
        if(message == ACCURA_ERROR_CODE_MOTION) {
            msg = "Keep Document Steady";
        } else if(message == ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME) {
            msg = "Keep document in frame";
        } else if(message == ACCURA_ERROR_CODE_PROCESSING) {
            msg = "Processing...";
        } else if(message == ACCURA_ERROR_CODE_MOVE_CLOSER) {
            msg = "Move Phone Closer"
        }else if(message == ACCURA_ERROR_CODE_MOVE_AWAY) {
            msg = "Move Phone Away"
        }else if(message == ACCURA_ERROR_CODE_KEEP_MICR_IN_FRAME) {
            msg = "Please Keep MICR in Frame"
        }else {
            msg = message;
        }
        lblOCRMsg.text = msg
    }
    
    func whichBankCode(name: String) -> MICRTYPE {
        switch name {
        case "E13B":
            return .E13B
        case "CMC7":
            return .CMC7
        default:
            return .E13B  // Default case if no match is found
        }
    }

    func processedImage(_ image: UIImage!) {
        
    }

}
