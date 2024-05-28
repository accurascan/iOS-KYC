
import UIKit
import AVFoundation
import AccuraOCR

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
    
    var activityIndicator: UIActivityIndicatorView!
    var backgroundView: UIView!
    
    var accuraCameraWrapper: AccuraCameraWrapper? = nil
    
    var shareScanningListing: NSMutableDictionary = [:]
    
    var documentImage: UIImage? = nil
    var docfrontImage: UIImage? = nil
    
    var frontImageRotation = ""
    var backImageRotation = ""
    
    var docName = "Document"
    
    
    //MARK:- Variable
    var cardid : Int? = 0
    var countryid : Int? = 0
    var imgViewCard : UIImage?
    var isCheckCard : Bool = false
    var isCheckCardMRZ : Bool = false
    var isCheckcardBack : Bool = false
    var isCheckCardBackFrint : Bool = false
    var isCheckScanOCR : Bool = false
    var arrCardSide : [String] = [String]()
    var isCardSide : Bool?
    var isBack : Bool?
    var isFront : Bool?
    var isConnection : Bool?
    var imgViewCardFront : UIImage?
    var dictSecuretyData : NSMutableDictionary = [:]
    var dictFaceDataFront: NSMutableDictionary = [:]
    var dictFaceDataBack: NSMutableDictionary = [:]
    var dictOCRTypeData:NSMutableDictionary = [:]
    var arrBackFrontImage : [UIImageView] = [UIImageView]()
    var isbothSideAvailable = false
    var stUrl : String?
    var arrimgCountData = [String]()
    var cardType: Int? = 0
    var MRZDocType:Int? = 0
    
    var arrImageName : [String] = [String]()
    
    var dictScanningData:NSDictionary = NSDictionary()
    
    var isflipanimation : Bool?
    
    var isChangeMRZ : Bool?
    var imgPhoto : UIImage?
    
    var isCheckFirstTime : Bool?
    var mrzElementName: String = ""
    var dictScanningMRZData: NSMutableDictionary = [:]
    var setImage : Bool?
    var isFrontDataComplate: Bool?
    var isBackDataComplate: Bool?
    var stCountryCardName: String?
    var cardImage: UIImage?
    var isBackSide: Bool?
    
    var arrFrontResultKey : [String] = []
    var arrFrontResultValue : [String] = []
    var arrBackResultKey : [String] = []
    var arrBackResultValue : [String] = []
    var isCheckMRZData: Bool?
    var secondCallData: Bool?
    
    var isFirstTimeStartCamara: Bool?
    var countface = 0
    var statusBarRect = CGRect()
    var bottomPadding:CGFloat = 0.0
    var topPadding: CGFloat = 0.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Create background view
        backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: 100, height: 100)) // Increase the size as needed
        backgroundView.backgroundColor = UIColor.white
        backgroundView.alpha = 0.5 // Adjust transparency as needed
        backgroundView.layer.cornerRadius = 10 // Adjust corner radius as needed
        backgroundView.center = view.center
        view.addSubview(backgroundView)
        backgroundView.isHidden = true
        
        // Create activity indicator
        let indicatorSize: CGFloat = 120 // Increase the size as needed
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        activityIndicator.color = UIColor.black // Set color
        activityIndicator.frame = CGRect(x: (backgroundView.bounds.size.width - indicatorSize) / 2, y: (backgroundView.bounds.size.height - indicatorSize) / 2, width: indicatorSize, height: indicatorSize)
        backgroundView.addSubview(activityIndicator)
        
        // Do any additional setup after loading the view.
        
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
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
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
        _viewLayer.layer.borderColor = UIColor.red.cgColor
        _viewLayer.layer.borderWidth = 3.0
        self._imgFlipView.isHidden = true
        if status == .authorized {
           isCheckFirstTime = true
            self.setOCRData()
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
                        self.setOCRData()
                        if(self.isCheckScanOCR)
                        {

                        }
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
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        self._imageView.setNeedsLayout()
        self._imageView.layoutSubviews()
        self._imageView.layoutIfNeeded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        countface = 0
        self.shareScanningListing.removeAllObjects()
        isBackSide = false
        isCheckMRZData = false
         self.ChangedOrientation()
        if self.accuraCameraWrapper == nil {
                setOCRData()
        }

        if isFirstTimeStartCamara!{

          accuraCameraWrapper?.startCamera()
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
        accuraCameraWrapper?.closeOCR()
        accuraCameraWrapper = nil
        _imageView.image = nil
        super.viewWillDisappear(animated)
    }
    
    @IBAction func backAction(_ sender: Any) {
        accuraCameraWrapper?.stopCamera()
        accuraCameraWrapper?.closeOCR()
        arrFrontResultKey.removeAll()
        arrBackResultKey.removeAll()
        arrFrontResultValue.removeAll()
        arrBackResultValue.removeAll()
        dictSecuretyData.removeAllObjects()
        dictFaceDataBack.removeAllObjects()
        dictFaceDataFront.removeAllObjects()
        dictScanningMRZData.removeAllObjects()
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonFlipAction(_ sender: UIButton) {
        accuraCameraWrapper?.switchCamera()
    }
    
    //MARK:- Other Method
    func setOCRData(){
        arrFrontResultKey.removeAll()
        arrBackResultKey.removeAll()
        arrFrontResultValue.removeAll()
        arrBackResultValue.removeAll()
        dictSecuretyData.removeAllObjects()
        dictFaceDataBack.removeAllObjects()
        dictFaceDataFront.removeAllObjects()
        dictScanningMRZData.removeAllObjects()
        isCheckCard = false
        isCheckcardBack = false
        isCheckCardBackFrint = false
        isflipanimation = false
        imgPhoto = nil
        isFrontDataComplate = false
        isBackDataComplate = false
         
        accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: _imageView, andLabelMsg: lblOCRMsg, andurl: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: Int32(cardid!), countryID: Int32(countryid!), isScanOCR: isCheckScanOCR, andcardName: docName, andcardType: Int32(cardType!), andMRZDocType: Int32(MRZDocType!))
        accuraCameraWrapper?.setMinFrameForValidate(5)
    }
    
    @objc private func ChangedOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        
        let orientastion = UIApplication.shared.statusBarOrientation
        if(orientastion ==  UIInterfaceOrientation.portrait) {
            width = UIScreen.main.bounds.size.width * 0.95
            
            height  = (UIScreen.main.bounds.size.height - (self.bottomPadding + self.topPadding + self.statusBarRect.height)) * 0.35
            viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        } else {

            self.viewNavigationBar.backgroundColor = .clear
            height = UIScreen.main.bounds.size.height * 0.62
            width = UIScreen.main.bounds.size.width * 0.51
        }
       
        _constant_width.constant = width
        if(self.cardType == 2) {
            self._constant_height.constant = height / 2
        } else {
            self._constant_height.constant = height
        }
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
    
    func flipAnimation() {
        DispatchQueue.main.async {
            self._imgFlipView.isHidden = false
            UIView.animate(withDuration: 1.5, animations: {
                UIView.setAnimationTransition(.flipFromLeft, for: self._imgFlipView, cache: true)
                AudioServicesPlaySystemSound(1315)
            }) { _ in
                self._imgFlipView.isHidden = true
            }
        }
    }
    
    
    func startActivityIndicator() {
        backgroundView.isHidden = false // Show the background view
        activityIndicator.startAnimating()
    }
    
    func stopActivityIndicator() {
        activityIndicator.stopAnimating()
        backgroundView.isHidden = true
    }
    
}

extension ViewController: VideoCameraWrapperDelegate {
    
    func isBothSideAvailable(_ isBothAvailable: Bool) {
        isbothSideAvailable = isBothAvailable
        accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
    }
    
    func  onUpdateLayout(_ frameSize: CGSize, _ borderRatio: Float) {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
        if(isCheckScanOCR) {
            if(cardType != 2 && cardType != 3) {
                let orientastion = UIApplication.shared.statusBarOrientation
                if(orientastion ==  UIInterfaceOrientation.portrait) {
                    width = frameSize.width
                    if(frameSize.width < frameSize.height){
                        height  = frameSize.height - 100
                    }else{
                        height  = frameSize.height
                    }
                    
                    viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                } else {

                    self.viewNavigationBar.backgroundColor = .clear
                    height = (((UIScreen.main.bounds.size.height - 100) * 5) / 5.6)
                    if(frameSize.width < frameSize.height){
                        width = (height / CGFloat(0.66))
                    }else{
                        width = (height / CGFloat(borderRatio))
                    }
                    
                    print("boreder ratio :- ", borderRatio)
                }
                print("layer", width)
                DispatchQueue.main.async {
                    self._constant_width.constant = width
                   
                    self._constant_height.constant = height
                }
                
            }
            
        }
       
        
    }
    
    func dlPlateNumber(_ plateNumber: String!, andImageNumberPlate imageNumberPlate: UIImage!) {
        shareScanningListing["plate_number"] = plateNumber
        let vc : ShowResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
        vc.plateNumber = plateNumber
        vc.DLPlateImage = imageNumberPlate
        vc.pageType = .DLPlate
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func resultData(_ resultmodel: ResultModel!) {
        AudioServicesPlaySystemSound(SystemSoundID(1315))
        imgPhoto = resultmodel.faceImage
        self.dictScanningMRZData = resultmodel.shareScanningMRZListing
        self.dictFaceDataFront = resultmodel.ocrFaceFrontData
        self.dictFaceDataBack = resultmodel.ocrFaceBackData
        self.dictSecuretyData = resultmodel.ocrSecurityData
        self.arrFrontResultKey = resultmodel.arrayocrFrontSideDataKey as! [String]
        self.arrFrontResultValue = resultmodel.arrayocrFrontSideDataValue as! [String]
        self.arrBackResultKey = resultmodel.arrayocrBackSideDataKey as! [String]
        self.arrBackResultValue = resultmodel.arrayocrBackSideDataValue as! [String]
        self.dictOCRTypeData = resultmodel.ocrTypeData
        self.imgViewCard = resultmodel.backSideImage
        self.imgViewCardFront =  resultmodel.frontSideImage
        if isbothSideAvailable {
            accuraCameraWrapper?.cardSide(.BACK_CARD_SCAN)
            if(resultmodel.arrayocrBackSideDataKey.count > 0) {
              
                passDataOtherViewController()
            }
        } else {
            passDataOtherViewController()
        }
    }
    
    func screenSound() {
        AudioServicesPlaySystemSound(SystemSoundID(1315))
         if !self.isflipanimation!{
            self.isflipanimation = true
             self.flipAnimation()
        }
       
    }
    
    func recognizeSucceedBarcode(_ message: String!) {
        
    }
    

    func processedImage(_ image: UIImage!) {
//        _imageView.image = image
    }
    
    func recognizeFailed(_ message: String!) {
        let alert = UIAlertController(title: "AccuraSDK", message: message, preferredStyle: .alert)
        let yesButton = UIAlertAction(title: "OK", style: .default) { _ in
        }
        alert.addAction(yesButton)
        self.present(alert, animated: true, completion: nil)
    }
    
    func recognizeSucceed(_ scanedInfo: NSMutableDictionary!, recType: RecType, bRecDone: Bool, bFaceReplace: Bool, bMrzFirst: Bool, photoImage: UIImage, docFrontImage: UIImage!, docbackImage: UIImage!) {
                if(bMrzFirst)
                    
                {
                    if isBackSide!{
                        
                      documentImage = docbackImage
                        if(docFrontImage != nil) {
                            self.docfrontImage = docFrontImage
                        }
                    }else{
                       documentImage = nil
                       self.docfrontImage = docFrontImage
                        
                    }
                    self.imageRotation(rotation: "BackImg")
                    self.accuraCameraWrapper?.stopCamera()
                    self._imageView.image = nil
            
                    AudioServicesPlaySystemSound(1315)
                    
                    self.shareScanningListing = scanedInfo
                    let shareScanningListing: NSMutableDictionary = self.shareScanningListing
                    if documentImage != nil{
                        shareScanningListing["documentImage"] = documentImage?.jpegData(compressionQuality: 1.0)
                    }
                    shareScanningListing["docfrontImage"] = docfrontImage?.jpegData(compressionQuality: 1.0)
                    shareScanningListing["fontImageRotation"] = frontImageRotation
                    shareScanningListing["backImageRotation"] = backImageRotation
                    let vc : ShowResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
                    vc.scannedData = shareScanningListing
                    vc.stCountryCardName = stCountryCardName
                    vc.imageCountryCard = cardImage
                    vc.isBackSide = isBackSide
                    vc.pageType = .ScanPassport
                    self.navigationController?.pushViewController(vc, animated: true)
                }
                else{
                    countface += 1
                    if !isBackSide!{
                    if(countface > 2)
                    {
                        countface = 0
                        self.docfrontImage = self._imageView.image
                        self.imageRotation(rotation: "FrontImage")
                        isBackSide = true
                        self.flipAnimation()
//                        return
                    }
                    }
                    else{
//                        return
                    }
                }
        }
    
    func recognizSuccessBankCard(_ cardDetail: NSMutableDictionary!, andBankCardImage bankCardImage: UIImage!) {
        let vc : ShowResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
        vc.scannedData = cardDetail
        vc.pageType = .BankCard
        vc.bankCardImage = bankCardImage
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    func matchedItem(_ image: UIImage!, isCardSide1 cs: Bool, isBack b: Bool, isFront f: Bool, imagePhoto imgp: UIImage!, imageResult: UIImage!) {
        if f == true{
            imgViewCardFront = imageResult
        }else{
            imgViewCard = imageResult
        }
        isCardSide = cs
        isBack = b
        isFront = f
    }
    
    func postMethodForArabicOCR(parameters: [String: Any], image: UIImage, completion: @escaping ([String:Any]) -> Void) {
        let url = URL(string: "http://110.5.77.162:8005/api_all.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.timeoutInterval = .infinity

        // Add the API-Key header if needed
        // request.addValue("1647411108z2jNE2Uqq06CRbSjOXEl8qkhlbMA68Tj6A7IEr6R", forHTTPHeaderField: "API-Key")

        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()

        // Append parameters to the body
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Append image data to the body
        if let imageData = image.jpegData(compressionQuality: 1.0) {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"file\"; filename=\"file.jpg\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
            body.append(imageData)
            body.append("\r\n".data(using: .utf8)!)
        }

        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("Error \(error.localizedDescription)")
                    return
                }

                if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    if let data = data {
                        do {
                            if let responseObject = try JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] {
                                print("Parsed response: \(responseObject)")
                                completion(responseObject)
                            } else {
                                print("Failed to cast response to NSMutableDictionary")
                            }
                        } catch {
                            print("JSON parsing error: \(error.localizedDescription)")
                            if let responseString = String(data: data, encoding: .utf8) {
                                print("Response data: \(responseString)")
                            }
                        }
                    }
                } else {
                    // Handle non-200 status code
                    let errorDescription = HTTPURLResponse.localizedString(forStatusCode: (response as? HTTPURLResponse)?.statusCode ?? 0)
                    print("Error \(errorDescription)")
                }
            }
        }

        task.resume()
    }
    
    func passDataOtherViewController(){
        var code = "KWT"
        
        if countryid == 9 {
            code = "KWT"
        }
        if countryid == 26 {
            code = "BHR"
        }
        let parameters: [String: Any] = [
            "country_code": code
        ]
        if countryid == 9 || countryid == 26 {
            startActivityIndicator()
            postMethodForArabicOCR(parameters: parameters, image: imgViewCardFront!) { response in
                // Handle the response
//                print("Response: \(response["data"])")
                self.stopActivityIndicator()
                if let data = response["data"] as? [String:Any]
                {
                    if let ocrData = data["OCRdata"] as? [String:String] {
                        if !ocrData.keys.isEmpty {
                            let dataKey: [String] = (ocrData.keys.map { String($0) })
                            let dataValue: [String] = (ocrData.values.map { String($0) })
                            
                            self.arrFrontResultKey = self.arrFrontResultKey + dataKey
                            self.arrFrontResultValue = self.arrFrontResultValue + dataValue
                        }
                    }
                }
                
                let vc : ShowResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
                vc.imgViewCountryCard = self.imgViewCard
                vc.imgViewBack = self.imgViewCard
                vc.imgViewFront = self.imgViewCardFront
                vc.dictScanningData = self.dictScanningData
                vc.pageType = .ScanOCR
                vc.imagePhoto = self.imgPhoto
                vc.scannedData = self.dictScanningMRZData
                vc.stCountryCardName = self.stCountryCardName
                vc.imageCountryCard = self.cardImage
                vc.dictFaceData = self.dictFaceDataFront
                vc.dictSecurityData = self.dictSecuretyData
                vc.dictFaceBackData = self.dictFaceDataBack
                vc.arrDataForntKey = self.arrFrontResultKey
                vc.arrDataForntValue = self.arrFrontResultValue
                vc.arrDataBackKey = self.arrBackResultKey
                vc.arrDataBackValue = self.arrBackResultValue
                vc.dictOCRTypeData = self.dictOCRTypeData
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }else{
                let vc : ShowResultVC = self.storyboard?.instantiateViewController(withIdentifier: "ShowResultVC") as! ShowResultVC
                vc.imgViewCountryCard = self.imgViewCard
                vc.imgViewBack = self.imgViewCard
                vc.imgViewFront = self.imgViewCardFront
                vc.dictScanningData = self.dictScanningData
                vc.pageType = .ScanOCR
                vc.imagePhoto = self.imgPhoto
                vc.scannedData = self.dictScanningMRZData
                vc.stCountryCardName = self.stCountryCardName
                vc.imageCountryCard = self.cardImage
                vc.dictFaceData = self.dictFaceDataFront
                vc.dictSecurityData = self.dictSecuretyData
                vc.dictFaceBackData = self.dictFaceDataBack
                vc.arrDataForntKey = self.arrFrontResultKey
                vc.arrDataForntValue = self.arrFrontResultValue
                vc.arrDataBackKey = self.arrBackResultKey
                vc.arrDataBackValue = self.arrBackResultValue
                vc.dictOCRTypeData = self.dictOCRTypeData
                self.navigationController?.pushViewController(vc, animated: true)
        }
    }
    
    func imageRotation(rotation: String) {
        var strRotation = ""
        if UIDevice.current.orientation == .landscapeRight {
            strRotation = "Right"
        } else if UIDevice.current.orientation == .landscapeLeft {
            strRotation = "Left"
        }
        if rotation == "FrontImg" {
            frontImageRotation = strRotation
        } else if rotation == "BackImg" {
            backImageRotation = strRotation
        } else {
            frontImageRotation = strRotation
        }
    }
    func reco_msg(_ message: String!) {
        var msg = String();
        if(message == ACCURA_ERROR_CODE_MOTION) {
            msg = "Keep Document Steady";
        } else if(message == ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME) {
            msg = "Keep document in frame";
        } else if(message == ACCURA_ERROR_CODE_BRING_DOCUMENT_IN_FRAME) {
            msg = "Bring card near to frame";
        } else if(message == ACCURA_ERROR_CODE_PROCESSING) {
            msg = "Processing...";
        } else if(message == ACCURA_ERROR_CODE_BLUR_DOCUMENT) {
            msg = "Blur detect in document";
        } else if(message == ACCURA_ERROR_CODE_FACE_BLUR) {
            msg = "Blur detected over face";
        } else if(message == ACCURA_ERROR_CODE_GLARE_DOCUMENT) {
            msg = "Glare detect in document";
        } else if(message == ACCURA_ERROR_CODE_HOLOGRAM) {
            msg = "Hologram Detected";
        } else if(message == ACCURA_ERROR_CODE_DARK_DOCUMENT) {
            msg = "Low lighting detected";
        } else if(message == ACCURA_ERROR_CODE_PHOTO_COPY_DOCUMENT) {
            msg = "Can not accept Photo Copy Document";
        } else if(message == ACCURA_ERROR_CODE_FACE) {
            msg = "Face not detected";
        } else if(message == ACCURA_ERROR_CODE_MRZ) {
            msg = "MRZ not detected";
        } else if(message == ACCURA_ERROR_CODE_PASSPORT_MRZ) {
            msg = "Passport MRZ not detected";
        } else if(message == ACCURA_ERROR_CODE_ID_MRZ) {
            msg = "ID MRZ not detected"
        } else if(message == ACCURA_ERROR_CODE_VISA_MRZ) {
            msg = "Visa MRZ not detected"
        }else if(message == ACCURA_ERROR_CODE_UPSIDE_DOWN_SIDE) {
            msg = "Document is upside down. Place it properly"
        }else if(message == ACCURA_ERROR_CODE_WRONG_SIDE) {
            msg = "Scanning wrong side of Document"
        }else {
            msg = message;
        }
        lblOCRMsg.text = msg
    }
    
    func reco_titleMessage(_ messageCode: Int32) {
        print("msgcode:- ",messageCode)
        switch messageCode {
        case SCAN_TITLE_OCR_FRONT:
            var frontMsg = "Scan Front side of ";
            frontMsg = frontMsg.appending(docName)
            _lblTitle.text = frontMsg
            break
        case SCAN_TITLE_OCR_BACK:
            var backMsg = "Scan Back side of ";
            backMsg = backMsg.appending(docName)
            _lblTitle.text = backMsg
            break
        case SCAN_TITLE_OCR:
            var backMsg = "Scan ";
            backMsg = backMsg.appending(docName)
            _lblTitle.text = backMsg
            break
        case SCAN_TITLE_MRZ_PDF417_FRONT:
            _lblTitle.text = "Scan Front Side of Document"
            break
        case SCAN_TITLE_MRZ_PDF417_BACK:
            _lblTitle.text = "Scan Back Side of Document"
            break
        case SCAN_TITLE_DLPLATE:
            _lblTitle.text = "Scan Number plate"
            break
        case SCAN_TITLE_BARCODE:
            _lblTitle.text = "Scan Barcode"
            break
        case SCAN_TITLE_BANKCARD:
            _lblTitle.text = "Scan BankCard"
            break
        default:
            break
            
        }
    }
}
extension Data {
    mutating func append(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
