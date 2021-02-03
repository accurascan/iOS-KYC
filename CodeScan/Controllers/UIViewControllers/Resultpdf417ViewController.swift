
import UIKit
import SVProgressHUD
import AccuraOCR
import FaceMatchSDK
import Alamofire

class Resultpdf417ViewController: UIViewController,UITableViewDataSource,UITableViewDelegate ,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomAFNetWorkingDelegate,LivenessData {
    
   
    //MARK:- Outlet
    @IBOutlet weak var tblResult: UITableView!
 
    //MARK:- Variable
    var keyArr = [String]()
    var valueArr = [String]()
    var passStr:String!
    var BtnCheck : Bool!
    var photoImage : UIImage?
    var imgViewFront : UIImage?
    var imgViewBack : UIImage?
    var faceImage: UIImage?
    var arrFaceLivenessScor  = [Objects]()
    let picker: UIImagePickerController = UIImagePickerController()
    var stLivenessResult: String = ""
    var faceRegion: NSFaceRegion?
    var isCheckLiveNess: Bool?
    var isCheckIDMRZ: Bool = false
    var faceScoreData: String?
    var uniqStr = ""
    var pageType: NAV_PAGETYPE = .Default
    var arrDocumentData: [[String:AnyObject]] = [[String:AnyObject]]()
    var imgCamaraFace: UIImage?
    var matchImage: UIImage?
    var liveImage: UIImage?
    var stFace : String?
    var livenessValue: String = ""
    var isFLpershow = false
    var intID: Int?
    //MARK:- ViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        var dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
        arrDocumentData.append(dict)
        dict = [KEY_VALUE_FACE_MATCH: "0 %",KEY_TITLE_FACE_MATCH:"0 %"] as [String : AnyObject]
        arrDocumentData.append(dict)
        setFaceImage()
        //Set tableview height
        tblResult.estimatedRowHeight = 65.0;
        tblResult.rowHeight = UITableView.automaticDimension
        isCheckLiveNess = false
        /*
         FaceMatch SDK method to check if engine is initiated or not
         Return: true or false
         */
        let fmInit = EngineWrapper.isEngineInit()
        if !fmInit{
            
            /*
             FaceMatch SDK method initiate SDK engine
             */
            
            EngineWrapper.faceEngineInit()
        }
        
        /*
         Facematch SDK method to get SDK engine status after initialization
         Return: -20 = Face Match license key not found, -15 = Face Match license is invalid.
         */
        let fmValue = EngineWrapper.getEngineInitValue() //get engineWrapper load status
        if fmValue == -20{
            GlobalMethods.showAlertView("key not found", with: self)
        }else if fmValue == -15{
            GlobalMethods.showAlertView("License Invalid", with: self)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(loadPhotoCaptured), name: NSNotification.Name("_UIImagePickerControllerUserDidCaptureItem"), object: nil)
        
        //Register tableview cell
        tblResult.register(UINib(nibName: "DrivePDFTableViewCell", bundle: nil), forCellReuseIdentifier: "drivePDF")
        tblResult.register(UINib(nibName: "DrivingPDFstringTableViewCell", bundle: nil), forCellReuseIdentifier: "Stringcell")
        tblResult!.dataSource = self as UITableViewDataSource
        self.tblResult.register(UINib.init(nibName: "UserImgTableCell", bundle: nil), forCellReuseIdentifier: "UserImgTableCell")
        tblResult.register(UINib.init(nibName: "DocumentTableCell", bundle: nil), forCellReuseIdentifier: "DocumentTableCell")
        self.tblResult.register(UINib.init(nibName: "FaceMatchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "FaceMatchResultTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
    }
    
    override func viewWillAppear(_ animated: Bool) {
        Liveness.setLivenessURL(livenessURL: "Your URL")
        Liveness.setBackGroundColor(backGroundColor: "#C4C4C5")
        Liveness.setCloseIconColor(closeIconColor: "#000000")
        Liveness.setFeedbackBackGroundColor(feedbackBackGroundColor: "#C4C4C5")
        Liveness.setFeedbackTextColor(feedbackTextColor: "#000000")
        Liveness.setFeedbackTextSize(feedbackTextSize: 18)
        Liveness.setFeedBackframeMessage(feedBackframeMessage: "Frame Your Face")
        Liveness.setFeedBackAwayMessage(feedBackAwayMessage: "Move Phone Away")
        Liveness.setFeedBackOpenEyesMessage(feedBackOpenEyesMessage: "Keep Open Your Eyes")
        Liveness.setFeedBackCloserMessage(feedBackCloserMessage: "Move Phone Closer")
        Liveness.setFeedBackCenterMessage(feedBackCenterMessage: "Center Your Face")
        Liveness.setFeedbackMultipleFaceMessage(feedBackMultipleFaceMessage: "Multiple face detected")
        Liveness.setFeedBackFaceSteadymessage(feedBackFaceSteadymessage: "Keep Your Head Straight")
        Liveness.setFeedBackLowLightMessage(feedBackLowLightMessage: "Low light detected")
        Liveness.setFeedBackBlurFaceMessage(feedBackBlurFaceMessage: "Blur detected over face")
        Liveness.setFeedBackGlareFaceMessage(feedBackGlareFaceMessage: "Glare detected")
    }
    
    
    
    //MARK:- UITableview Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        if(isCheckIDMRZ)
        {
            return 6
        }
        else{
            return 2
        }
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        if(isCheckIDMRZ)
        {
            if(section == 1)
            {
                if arrFaceLivenessScor.isEmpty{
                    return 1
                }else{
                    return arrFaceLivenessScor.count
                }
            }
            else if(section == 2)
            {
                return keyArr.count
            }
            else{
                return 1
            }
        }
        else{
            if(section == 0)
            {
                return keyArr.count
            }
            else{
                return 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(isCheckIDMRZ)
        {
            if section == 2 || section == 3{
                return 60
            }
            else{
                return CGFloat.leastNonzeroMagnitude
            }
        }
        else{
            return 60
        }
    }
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if(isCheckIDMRZ)
        {
            if section == 2 || section == 3{
                return 20
            }
            else{
                return CGFloat.leastNonzeroMagnitude
            }
        }
        else{
            return 20
        }
    }
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(isCheckIDMRZ)
        {
            if section == 2 || section == 3{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
                headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                let label = UILabel()
                label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = .clear
                
                if(section == 2)
                {
                    label.text = "USA DL Result"
                }
                else{
                    label.text = "PDF417 Barcode"
                }
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .left
                label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1)// my custom colour
                
                headerView.addSubview(label)
                
                return headerView
            }
            else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
                return headerView
            }
        }
        else{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
            headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
            label.backgroundColor = .clear
            
            if(section == 2)
            {
                label.text = "USA DL Result"
            }
            else{
                label.text = "PDF417 Barcode"
            }
            label.font = UIFont.init(name: "Aller-Bold", size: 16)
            label.textAlignment = .left
            label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1)// my custom colour
            
            headerView.addSubview(label)
            
            return headerView
        }
    }
  
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if(isCheckIDMRZ)
        {
            if(indexPath.section == 1)
            {
                if(isFLpershow)
                {
                    return 116
                }
                return 76
            }
            else if indexPath.section == 0{
                return UITableView.automaticDimension
            }else if(indexPath.section == 4 || indexPath.section == 5){
                return 310.0
            }else{
                return UITableView.automaticDimension
            }
        }
        else{
            return UITableView.automaticDimension
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if(isCheckIDMRZ)
        {
            if indexPath.section == 0{
                let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserImgTableCell") as! UserImgTableCell
                cell.selectionStyle = .none
                if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE]  as? UIImage{
                    cell.User_img2.isHidden = true
                    cell.view2.isHidden = true
                    if (UIDevice.current.orientation == .landscapeRight) {
                        cell.user_img.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                    } else if (UIDevice.current.orientation == .landscapeLeft) {
                        cell.user_img.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
                    }
                    cell.user_img.image = imageFace
                }
                if imgCamaraFace != nil{
                    cell.User_img2.isHidden = false
                    cell.view2.isHidden = false
                    cell.User_img2.image = imgCamaraFace
                }
                return cell
            }else if(indexPath.section == 1){
                let  dictResultData: [String:AnyObject] = arrDocumentData[1]
                let cell: FaceMatchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FaceMatchResultTableViewCell") as! FaceMatchResultTableViewCell
                if(!isFLpershow)
                {
                    cell.constraintHeight.constant = 0
                }
                else{
                    cell.constraintHeight.constant = 40
                }
                cell.btnFaceMatch.addTarget(self, action: #selector(buttonClickedFaceMatch(sender:)), for: .touchUpInside)
                cell.btnLiveness.addTarget(self, action: #selector(buttonClickedLiveness(sender:)), for: .touchUpInside)
                if(dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("FACEMATCH SCORE : ") ?? false || dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("LIVENESS SCORE : ") ?? false){
                    if isCheckLiveNess!{
//                        isCheckLiveNess = false
                        cell.lblValueLiveness.text = "\(livenessValue) %"
                        cell.lblValueFaceMatch.text = "\(String(describing: faceScoreData!)) %"
                    }else{
                        
                        if ((dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("FACEMATCH SCORE : ")) ?? false){
                            cell.lblValueLiveness.text = "0 %"
                            cell.lblValueFaceMatch.text = "\(dictResultData[KEY_VALUE_FACE_MATCH] as? String ?? "") %"
                        }
                    }
                }else{
                    cell.lblValueFaceMatch.text = "0 %"
                    cell.lblValueLiveness.text = "0 %"
                }
                return cell
            }else if(indexPath.section == 2){
                let cell = tableView.dequeueReusableCell(withIdentifier: "drivePDF", for: indexPath) as! DrivePDFTableViewCell
                cell.lblpreTitle.text = keyArr[indexPath.row] as  String;
                cell.lblValuetitle.text = valueArr[indexPath.row] as  String;
                return cell
            }else if(indexPath.section == 3){
                let cell = tableView.dequeueReusableCell(withIdentifier: "Stringcell", for: indexPath) as! DrivingPDFstringTableViewCell
                cell.lblWholerstr.text = passStr
                return cell
            }else if(indexPath.section == 4){
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                cell.selectionStyle = .none
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                cell.lblDocName.text = "FRONT SIDE"
                cell.imgDocument.image = imgViewFront
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                cell.selectionStyle = .none
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                cell.lblDocName.text = "BACK SIDE"
                cell.imgDocument.image = imgViewBack
                return cell
            }
        }
        else{
            if(indexPath.section == 0){
                let cell = tableView.dequeueReusableCell(withIdentifier: "drivePDF", for: indexPath) as! DrivePDFTableViewCell
                cell.lblpreTitle.text = keyArr[indexPath.row] as  String;
                cell.lblValuetitle.text = valueArr[indexPath.row] as  String;
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "Stringcell", for: indexPath) as! DrivingPDFstringTableViewCell
                cell.lblWholerstr.text = passStr
                return cell
            }
        }
    }
    
    func LivenessData(stLivenessValue: String, livenessImage: UIImage, status: Bool) {
        isFLpershow = true
        self.livenessValue = stLivenessValue
        self.imgCamaraFace = livenessImage
        if status == false{
            GlobalMethods.showAlertView("Please try again", with: self)
        }
        
        if (faceRegion != nil)
        {
            /*
             FaceMatch SDK method call to detect Face in back image
             @Params: BackImage, Front Face Image faceRegion
             @Return: Face Image Frame
             */
            
            let face2 = EngineWrapper.detectTargetFaces(livenessImage, feature1: faceRegion?.feature)
            let face11 = faceRegion?.image
            /*
             FaceMatch SDK method call to get FaceMatch Score
             @Params: FrontImage Face, BackImage Face
             @Return: Match Score
             
             */
            
            let fm_Score = EngineWrapper.identify(faceRegion?.feature, featurebuff2: face2?.feature)
            if(fm_Score != 0.0){
            let data = face2?.bound
            let image = self.resizeImage(image: livenessImage, targetSize: data!)
            imgCamaraFace = image
            let twoDecimalPlaces = String(format: "%.2f", fm_Score*100) //Face Match score convert to float value
                faceScoreData = twoDecimalPlaces
            self.removeOldValue("FACEMATCH SCORE : ")
            self.removeOldValue1("0 %")
            isCheckLiveNess = true
                if self.pageType != .ScanOCR{
                    let dict = [KEY_VALUE_FACE_MATCH: "\(twoDecimalPlaces)",KEY_TITLE_FACE_MATCH:"FACEMATCH SCORE : "] as [String : AnyObject]
                    self.arrDocumentData.insert(dict, at: 1)
                }else{
                    let ansData = Objects.init(sName: "FACEMATCH SCORE : ", sObjects: "\(twoDecimalPlaces)")
                    self.arrFaceLivenessScor.insert(ansData, at: 0)
                }
                
                let stFaceImage = convertImageToBase64(image: image)
                let stLivenessInage = convertImageToBase64(image: livenessImage)
//                print(intID as Any)
                var dictParam: [String: String] = [String: String]()
                dictParam["kyc_id"] = "\(intID ?? 0)"
                dictParam["face_match"] = "True"
                dictParam["liveness"] = "True"
                dictParam["face_match_score"] = "\(faceScoreData)"

                dictParam["liveness_score"] = stLivenessValue
                dictParam["facematch_image"] = stFaceImage
                dictParam["liveness_image"] = stLivenessInage
                    let sharedInstance = NetworkReachabilityManager()!
                    var isConnectedToInternet:Bool {
                        return sharedInstance.isReachable
                    }
                
                // print(twoDecimalPlaces)
//                if pageType != .ScanOCR{
//                    let dict = [KEY_VALUE_FACE_MATCH: "\((stLivenessValue))",KEY_TITLE_FACE_MATCH:"LIVENESS SCORE : "] as [String : AnyObject]
//                    arrDocumentData.insert(dict, at: 1)
//                }else{
//                    let ansData = Objects.init(sName: "LIVENESS SCORE : ", sObjects: "\(stLivenessResult)")
//                    self.arrFaceLivenessScor.insert(ansData, at: 0)
//                }
        }
            tblResult.reloadData()
        }
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.jpeg(.medium)
      return imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
    }

    func configureGradientBackground(arrcolors:[AnyObject],inLayer:CALayer){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = arrcolors
        gradient.startPoint =  CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        inLayer.addSublayer(gradient)
    }

    @objc func loadPhotoCaptured() {
        let img = allImageViewsSubViews(picker.viewControllers.first?.view)?.last
        if img != nil {
            if let imgView: UIImageView = img as? UIImageView{
                imagePickerController(picker, didFinishPickingMediaWithInfo: convertToUIImagePickerControllerInfoKeyDictionary([convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage) : imgView.image!]))
            }
        } else {
            picker.dismiss(animated: true)
        }
    }

    @objc func buttonClickedFaceMatch(sender:UIButton)
        {
        isCheckLiveNess = false
        Liveness.setLivenessAndFacematch(livenessView: self, ischeckLiveness: false)
//            picker.delegate = self
//            picker.allowsEditing = false
//            picker.sourceType = .camera
//            picker.cameraDevice = .front
//            picker.mediaTypes = ["public.image"]
//            self.present(picker, animated: true, completion: nil)
        }
        
       @objc func buttonClickedLiveness(sender:UIButton)
        {
        isCheckLiveNess = true
        Liveness.setLivenessAndFacematch(livenessView: self, ischeckLiveness: true)
//            isCheckLiveNess = true
        }

    /**
     * This method is used to get captured view
     * Param: UIView
     * Return: array of UIImageview
     */
    func allImageViewsSubViews(_ view: UIView?) -> [AnyHashable]? {
        var arrImageViews: [AnyHashable] = []
        if (view is UIImageView) {
            if let view = view {
                arrImageViews.append(view)
            }
        } else {
            for subview in view?.subviews ?? [] {
                if let all = allImageViewsSubViews(subview) {
                    arrImageViews.append(contentsOf: all)
                }
            }
        }
        return arrImageViews
    }

    /**
     * This method is used to compress image in particular size
     * Param: UIImage and covert size
     * Return: compress UIImage
     */
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
     //MARK:- UIImagePickerController Delegate
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            // Local variable inserted by Swift 4.2 migrator.
            let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
            picker.dismiss(animated: true, completion: nil)
            isFLpershow = true
            SVProgressHUD.show(withStatus: "Loading...")
//            DispatchQueue.global(qos: .background).async {
                guard var chosenImage:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else{return}
                
                //Capture Image Left flipped
                if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == .front {
                    var flippedImage: UIImage? = nil
                    if let CGImage = chosenImage.cgImage {
                        flippedImage = UIImage(cgImage: CGImage, scale: chosenImage.scale, orientation: .leftMirrored)
                    }
                    chosenImage = flippedImage!
                }
                
                //Image Resize
                
                let ratio = CGFloat(chosenImage.size.width) / chosenImage.size.height
                chosenImage = self.compressimage(with: chosenImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
                
                
                self.faceRegion = nil;
                if (self.photoImage != nil || self.faceImage != nil){
                    /*
                     Accura Face SDK method to detect user face from document image
                     Param: Document image
                     Return: User Face
                     */
                    if self.photoImage != nil{
                        self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage)
                    }else{
                        self.faceRegion = EngineWrapper.detectSourceFaces(self.faceImage)
                    }
                    
                }
//                DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                    if (self.faceRegion != nil){
                        /*
                         Accura Face SDK method to detect user face from selfie or camera stream
                         Params: User photo, user face found in document scanning
                         Return: User face from user photo
                         */
                        let face2 : NSFaceRegion? = EngineWrapper.detectTargetFaces(chosenImage, feature1: self.faceRegion?.feature as Data?)   //identify face in back image which found in front image
                        
                        
                       
                        // print(image)

                        
                        /*
                         Accura Face SDK method to get face match score
                         Params: face image from document with user image from selfie or camera stream
                         Returns: face match score
                         */
                        let fm_Score = EngineWrapper.identify(self.faceRegion?.feature, featurebuff2: face2?.feature)
                        if(fm_Score != 0.0){
                            isCheckLiveNess = false
                            let data = face2?.bound
                            let image = self.resizeImage(image: chosenImage, targetSize: data!)
                            self.removeOldValue1("0 %")
                            var isFindImg: Bool = false
                            for (index,var dict) in self.arrDocumentData.enumerated(){
                                for st in dict.keys{
                                    if st == KEY_FACE_IMAGE{
                                        imgCamaraFace = image
                                        dict[KEY_FACE_IMAGE2] = image
                                        self.arrDocumentData[index] = dict
                                        isFindImg = true
                                        break
                                    }
                                    if isFindImg{ break }
                                }
                            }
                            self.removeOldValue("LIVENESS SCORE : ")
                            self.removeOldValue("FACEMATCH SCORE : ")
                            
                            let twoDecimalPlaces = String(format: "%.2f", fm_Score * 100) //Match score Convert Float Value
                            faceScoreData = twoDecimalPlaces
                            let dict = [KEY_VALUE_FACE_MATCH: "\(twoDecimalPlaces)",KEY_TITLE_FACE_MATCH:"FACEMATCH SCORE : "] as [String : AnyObject]
                            self.arrDocumentData.insert(dict, at: 1)
                        }else {
                        }
                        
                    }
                    self.tblResult.reloadData()
                    
                    SVProgressHUD.dismiss()
//                })
//            }
        }
        
    func resizeImage(image: UIImage, targetSize: CGRect) -> UIImage {
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        var newX = targetSize.origin.x - (targetSize.size.width * 0.4)
        var newY = targetSize.origin.y - (targetSize.size.height * 0.4)
        var newWidth = targetSize.size.width * 1.8
        var newHeight = targetSize.size.height * 1.8
        if newX < 0 {
            newX = 0
        }
        if newY < 0 {
            newY = 0
        }
        if newX + newWidth > image.size.width{
            newWidth = image.size.width - newX
        }
        if newY + newHeight > image.size.height{
            newHeight = image.size.height - newY
        }
        // This is the rect that we've calculated out and this is what is actually used below
        let rect = CGRect(x: newX, y: newY, width: newWidth, height: newHeight)
        let imageRef: CGImage = contextImage.cgImage!.cropping(to: rect)!
        let image1: UIImage = UIImage(cgImage: imageRef)
        return image1
    }
        
        //MARK:-  customURLConnection Delegate
        func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, withResponse response: Any!) {
            SVProgressHUD.dismiss()
            if tagCon == LivenessTag{
                let dictResponse: NSDictionary = response as? NSDictionary ?? NSDictionary()
                // print(response as Any)
                let dictFinalResponse: NSDictionary = dictResponse["data"] as! NSDictionary
                if let livenseeScore: String = dictFinalResponse["livenessResult"] as? String{
                    stLivenessResult = livenseeScore
                }
                if let livenessScore: Double = dictFinalResponse["livenessScore"] as? Double{
                    isFLpershow = true
                    // print(livenessScore)
                    self.removeOldValue("LIVENESS SCORE : ")
                    self.removeOldValue1("0 %")
//                    btnLiveness.isHidden = true
                    isCheckLiveNess = true
                    let twoDecimalPlaces = String(format: "%.2f", livenessScore)
                    // print(twoDecimalPlaces)
                   let dict = [KEY_VALUE_FACE_MATCH: "\((twoDecimalPlaces))",KEY_TITLE_FACE_MATCH:"LIVENESS SCORE : "] as [String : AnyObject]
                   arrDocumentData.insert(dict, at: 1)
                   self.tblResult.reloadData()
                }
            }
        }
        
        func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive response: URLResponse!) {
            
        }
        
        func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didFailWithError error: Error!) {
            SVProgressHUD.dismiss()
        }
        
        func customURLConnection(_ connection: CustomAFNetWorking!, with exception: NSException!, withTag tagCon: Int32) {
            
        }
        
        func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive data: Data!) {
            
        }
        
        func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32) {
            
        }
        
        func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, with data: NSMutableData!) {
            
        }
        
        func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, with data: NSMutableData!, from url: URL!) {
            
        }
        
        //MARK:- Custom
        func date(toFormatedDate dateStr: String?) -> String? {
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "yyMMdd"
            let date: Date? = dateFormatter.date(from: dateStr ?? "")
            dateFormatter.dateFormat = "dd-MM-yyyy"
            if let date = date {
                return dateFormatter.string(from: date)
            }
            return nil
        }
        
        func date(to dateStr: String?) -> String? {
            // Convert string to date object
            let dateFormat = DateFormatter()
            dateFormat.dateFormat = "yyMMdd"
            let date: Date? = dateFormat.date(from: dateStr ?? "")
            dateFormat.dateFormat = "yyyy-MM-dd"
            if let date = date {
                return dateFormat.string(from: date)
            }
            return nil
        }
        
        func setFaceImage(){
            faceImage = photoImage
            DispatchQueue.main.async {
                self.faceRegion = nil;
                if (self.faceImage != nil){
                    self.faceRegion = EngineWrapper.detectSourceFaces(self.faceImage) //Identify face in Document scanning image
                }
            }
        }
    //Remove Same Value
        func removeOldValue(_ removeKey: String){
            var removeIndex: String = ""
            for (index,dict) in arrDocumentData.enumerated(){
                if dict[KEY_TITLE_FACE_MATCH] != nil{
                    if dict[KEY_TITLE_FACE_MATCH] as! String == removeKey{
                        removeIndex = "\(index)"
                    }
                }
            }
            if !removeIndex.isEmpty{ arrDocumentData.remove(at: Int(removeIndex)!)}
        }
        
        func removeOldValue1(_ removeKey: String){
            var removeIndex: String = ""
                for (index,dict) in arrDocumentData.enumerated(){
                    if dict[KEY_VALUE_FACE_MATCH] != nil{
                        if dict[KEY_VALUE_FACE_MATCH] as! String == removeKey{
                            removeIndex = "\(index)"
                        }
                    }
                }
                if !removeIndex.isEmpty{ arrDocumentData.remove(at: Int(removeIndex)!)}
        }
    
    
    
    //MARK:- UIButton Action
    @IBAction func btnBackpress(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKeyDictionary(_ input: [UIImagePickerController.InfoKey: Any]) -> [String: Any] {
    return Dictionary(uniqueKeysWithValues: input.map {key, value in (key.rawValue, value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIImagePickerControllerInfoKeyDictionary(_ input: [String: Any]) -> [UIImagePickerController.InfoKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIImagePickerController.InfoKey(rawValue: key), value)})
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertFromUIImagePickerControllerInfoKey(_ input: UIImagePickerController.InfoKey) -> String {
    return input.rawValue
}
