# Accura KYC iOS SDK - OCR, Face Match & Liveness Check
iOS KYC SDK - OCR &amp; Face Match <br/><br/>
Accura OCR is used for Optical character recognition.<br/><br/>
Accura Face Match is used for Matching 2 Faces. Source and Target. It matches the User Image from a Selfie vs User Image in document.<br/><br/>
Accura Authentication is used for your customer verification and authentication.Unlock the True Identity of Your Users with 3D Selfie Technology<br/><br/>


Below steps to setup Accura SDK's to your project.


## 1. Setup Accura OCR

Step 1: install the AccuraOCR pod <br />
         pod 'AccuraOCRSDK', '1.0.5'

Step 2: Add licence file in to your project. <br />        
            - key.licence // for Accura OCR <br />
            Generate your Accura licence from https://accurascan.com/developer/dashboard <br />
            
Step 3: Add AccuraOCRSDK.swift file in your projrct.<br /> 

Step 4:  Run the App in Simulator.  ( Optional ) <br /> 
      Download and extract the AccuraOCR.framework.(can download From
             https://accurascan.com/iOSSDK/AccuraOCR.framework.zip) <br/>

Step 5: Appdelegate.swift file in add<br />

      func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
      
        AccuraOCRSDK.configure()
        
        return true
    }
 
Step 6 : To initialize sdk on app start:

    import AccuraOCR

    var accuraCameraWrapper: AccuraCameraWrapper? = nil
    var arrCountryList = NSMutableArray()
    
     accuraCameraWrapper = AccuraCameraWrapper.init()
     DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
     let sdkModel = accuraCameraWrapper.loadEngine(your PathForDirectories)
      if (sdkModel.i > 0) {
          // if sdkModel.isOCREnable then get card data
          if (sdkModel.isOCREnable) let countryListStr = self.videoCameraWrapper?.getOCRList();
          
          if (countryListStr != null) {
            for i in countryListStr!{
              self.arrCountryList.add(i)
          }
          }
      }
     
     }

    arrCountryList to get value(forKey: "card_name") // get card Name
    arrCountryList to get value(forKey: "country_id") // get country id
    arrCountryList to get value(forKey: "card_id") // get card id

    Some customized function below.
    Call this function after initialize sdk

    /**
     * Set Blur Percentage to allow blur on document
     *
     * @param blurPercentage is 0 to 100, 0 - clean document and 100 - Blurry document
     * @return 1 if success else 0
     */
     accuraCameraWrapper?.setFaceBlurPercentage(int /*blurPercentage*/60);
         
    /**
     * Set Blur Face Percentage to allow blur on detected Face
     *
     * @param faceBlurPercentage is 0 to 100, 0 - clean face and 100 - Blurry face
     * @return 1 if success else 0
     */
     accuraCameraWrapper?.setFaceBlurPercentage(int /*faceBlurPercentage*/80);
    
    /**
     * @param minPercentage Min value
     * @param maxPercentage Max value
     * @return 1 if success else 0
     */
     accuraCameraWrapper?.setGlarePercentage(int /*minPercentage*/6, int /*maxPercentage*/98);
    
    /**
     * Set CheckPhotoCopy to allow photocopy document or not
     *
     * @param isCheckPhotoCopy if true then reject photo copy document else vice versa
     * @return 1 if success else 0
     */
     accuraCameraWrapper?.setCheckPhotoCopy(bool /*isCheckPhotoCopy*/false);
    
    /**
     * set Hologram detection to allow hologram on face or not
     *
     * @param isDetectHologram if true then reject face if hologram in face else it is allow .
     * @return 1 if success else 0
     */
     accuraCameraWrapper?.setHologramDetection(boolean /*isDetectHologram*/true);
     
     /**
      * Set Low Light Tolerance to allow lighting to detect documant
      *
      * @param setLowLightTolerance is 0 to 100, 100 - clean light and 0 -  no light to detect
      * @return 1 if success else 0
      */
      accuraCameraWrapper?.setLowLightTolerance(int /*lowlighttolerance*/10);
      
      /**
        * Set Motion Threshold to allow frame motion
        *
        * @param setMotionThreshold is 0 to 100, 100 - motion Work and 0 - no motion work
        * @param setMotionThreshold is set message to display
        * @return 1 if success else 0
        */
        accuraCameraWrapper?.setMotionThreshold(int /*setMotionThreshold*/4 string /*message*/ "Keep Document Steady");
     
Step 7 : Set CameraView

    Important Grant Camera and storage Permission.
    
    import AccuraOCR
    import AVFoundation
    
    var accuraCameraWrapper: AccuraCameraWrapper? = nil

    override func viewDidLoad() {
    super.viewDidLoad()
    let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    if status == .authorized {
         accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: /*setCardId*/ Int32(cardid!), countryID: /*setcountryid*/ Int32(countryid!), isScanOCR:/*Bool*/ isCheckScanOCR, andLabelMsgTop:/*Lable*/ _lblTitle, andcardName:/*string*/  docName)
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
        accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: /*setCardId*/ Int32(cardid!), countryID: /*setcountryid*/ Int32(countryid!), isScanOCR:/*Bool*/ isCheckScanOCR, andLabelMsgTop:/*Lable*/ _lblTitle, andcardName:/*string*/  docName)
    } else {
    // print("Not granted access")
    }
    }
    }
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
          accuraCameraWrapper?.startCamera()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        accuraCameraWrapper?.stopCamera()
        accuraCameraWrapper = nil
        super.viewWillDisappear(animated)
    }
    
    
    extension ViewController: VideoCameraWrapperDelegate{
    func recognizeSucceedBarcode(_ message: String!) {
    
    }
    
    //  it calls continues when scan cards
    func processedImage(_ image: UIImage!) {
    image:- image is a get camara image.
    }
    
    // it call when license key wrong otherwise didnt get key
    func recognizeFailed(_ message: String!) {
    message:- message is a set alert message.
    }
    
    // it calls when get MRZ data
    func recognizeSucceed(_ scanedInfo: NSMutableDictionary!, recType: RecType, bRecDone: Bool, bFaceReplace: Bool, bMrzFirst: Bool, photoImage: UIImage, docFrontImage: UIImage!, docbackImage: UIImage!) {
    scanedInfo :- scanedInfo is a NSMutableDictionary in get MRZ data.
    photoImage:- photoImage in get a document face Image.
    docFrontImage:- docFrontImage is adocumant frontside image.
    docbackImage:- docbackImage is adocumant frontside image.
    }
    
    //   it calls when get front or back side image
    func matchedItem(_ image: UIImage!, isCardSide1 cs: Bool, isBack b: Bool, isFront f: Bool, imagePhoto imgp: UIImage!, imageResult: UIImage!) {
    if f == true to set frontside document Image.
    if f == false to set backside document Image.
    }
    
    //  it calls when get OCR data
    func matchedItem(_ setDataFrontKey: NSMutableArray!, andsetDataFrontvalue setDataFrontvalue: NSMutableArray!, andmrzDatasacn mrzDataSacn: NSMutableDictionary!, setDataBackKey: NSMutableArray!, setDataBackValue: NSMutableArray!, setFaceData: NSMutableDictionary!, setSecurityData: NSMutableDictionary!, setFaceBackData: NSMutableDictionary!, setPhotoImage: UIImage!) {
    setDataFrontKey  :-  setDataFrontKey is a NSMutableArray to get frontside data key.
    setDataFrontvalue:- setDataFrontvalue is a NSMutableArray to get frontside data                        value.
    mrzDataSacn      :- mrzDataSacn is a NSMutableArray to get MRZ data.
    setDataBackKey   :- setDataBackKey is a NSMutableArray to get backside data key.
    setDataBackValue :- setDataBackValue is a NSMutableArray to get backside data value.
     }


## 2. Setup Accura Face Match

Step 1: install the AccuraFaceMatch pod <br />
            pod 'AccuraFaceMatchSDK', '1.0.5'
            
Step 2: Add licence file in to your project.<br />
            - accuraface.license // for Accura Face Match <br />
            Generate your Accura licence from https://accurascan.com/developer/sdk-license  
            
Step 3: Add FaceView.swift file in your project.            

Step 4: Implement face match code manually to your activity.

    Important Grant Camera and storage Permission.
    
    ImageView image1,image2;
      override func viewDidLoad() {
        super.viewDidLoad()
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
      super.viewDidAppear(animated)
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
    }
    
       /**
     * This method use calculate faceMatch score
     * Parameters to Pass: selected uiimage
     *
     */
    func setFaceRegion(_ image: UIImage) {
        var faceRegion : NSFaceRegion?
        if(selectFirstImage){
            /*
             Accura Face SDK method to detect user face from document image
             Param: Document image
             Return: User Face
             */
            faceRegion = EngineWrapper.detectSourceFaces(image)
        }else{
            let face1 : NSFaceRegion? = faceView1.getFaceRegion(); // Get image data
            if (face1 == nil) {
                /*
                 Accura Face SDK method to detect user face from document image
                 Param: Document image
                 Return: User Face
                 */
                faceRegion = EngineWrapper.detectSourceFaces(image);
            } else {
                /*
                 Accura Face SDK method to detect user face from selfie or camera stream
                 Params: User photo, user face found in document scanning
                 Return: User face from user photo
                 */
                faceRegion = EngineWrapper.detectTargetFaces(image, feature1: face1?.feature);
            }
        }
        
        if (selectFirstImage){
            if (faceRegion != nil){
                image1.isHidden = true
                /*
                 SDK method call to draw square face around
                 @Params: BackImage, Front Image faceRegion Data
                 */
                faceView1.setFaceRegion(faceRegion)
                
                /*
                 SDK method call to draw square face around
                 @Params: BackImage, Front faceRegion Image
                 */
                faceView1.setImage(faceRegion?.image)
                faceView1.setNeedsDisplay()
                faceView1.isHidden = false
                imgUpload.isHidden = true
                txtUpload.isHidden = true
            }
            
            let face2 : NSFaceRegion? = faceView2.getFaceRegion(); // Get image data
            if (face2 != nil) {
                let face1 : NSFaceRegion? = faceView1.getFaceRegion(); // Get image data
                var faceRegion2 : NSFaceRegion?
                if (face1 == nil){
                    /*
                     Accura Face SDK method to detect user face from document image
                     Param: Document image
                     Return: User Face
                     */
                    faceRegion2 = EngineWrapper.detectSourceFaces(face2?.image)
                }else{
                    /*
                     Accura Face SDK method to detect user face from selfie or camera stream
                     Params: User photo, user face found in document scanning
                     Return: User face from user photo
                     */
                    faceRegion2 = EngineWrapper.detectTargetFaces(face2?.image, feature1: face2?.feature)  //Identify face in back image which found in front
                }
                
                if(faceRegion2 != nil){
                    image2.isHidden = true
                    /*
                     SDK method call to draw square face around
                     @Params: BackImage, Front Image faceRegion Data
                     */
                    faceView2.setFaceRegion(faceRegion2)
                    /*
                     SDK method call to draw square face around
                     @Params: BackImage, Front faceRegion Image
                     */
                    faceView2.setImage(faceRegion2?.image)
                    
                    faceView2.setNeedsDisplay()
                    imgUpload2.isHidden = true
                    txtUpload2.isHidden = true
                }
                
            }
        } else if(faceRegion != nil){
            image1.isHidden = true
            image2.isHidden = true
            
            /*
             SDK method call to draw square face around
             @Params: BackImage, Front Image faceRegion Data
             */
            faceView2.setFaceRegion(faceRegion)
            /*
             SDK method call to draw square face around
             @Params: BackImage, Front faceRegion Image
             */
            faceView2.setImage(faceRegion?.image)
            faceView2.setNeedsDisplay()
            imgUpload2.isHidden = true
            txtUpload2.isHidden = true
        }
        let face1:NSFaceRegion? = faceView1.getFaceRegion() // Get image data
        let face2:NSFaceRegion? = faceView2.getFaceRegion() // Get image data
        
        if ((face1?.face == 0 || face1 == nil) || (face2?.face == 0 || face2 == nil)){
            lableMatchRate.text = "Match Score : 0.0 %";
            return
        }
        arrDocument.removeAll()
        arrDocument.append(face1?.image ?? UIImage())
        arrDocument.append(face2?.image ?? UIImage())
        
        /*
         FaceMatch SDK method call to get FaceMatch Score
         @Params: FrontImage Face, BackImage Face
         @Return: Match Score
         
         */
        let fmSore = EngineWrapper.identify(face1?.feature, featurebuff2: face2?.feature)
        let twoDecimalPlaces = String(format: "%.2f", fmSore*100) //Match score Convert Float Value
        lableMatchRate.text = "Match Score : \(twoDecimalPlaces) %"
    }

    And take a look FaceMatch for full working example.

5. Liveness Check

    Integrating Zoom SDK for liveness <br/> <br/>
    Integration steps :<br/>
    1. Download and extract the Zoom iOS SDK.(can download From
        https://dev.zoomlogin.com/zoomsdk/#/downloads) <br/>
        
    2. Copy 'ZoomAuthenticationHybrid.framework' to your project <br/>
    
    3. Zoom initialization <br/>
        a. Zoom must be initialized with a valid Device SDK License before it will function. <br/>
        
        b. Copy your Device SDK License Key from your Account Page. <br/>
        
        c. projetc to add CustomAFNetWorking.m file & CustomAFNetWorking.h file.
        
        d. Set ZoomAuthenticationHybrid. <br/>
        
            import ZoomAuthenticationHybrid
            
        e. Initialize the Zoom SDK with required <br/>
            
            add project to ZoomDevloperAppToken
            
            ZoomVerificationDelegate
            
            CustomAFNetWorkingDelegate
            

        f. ZoomVerification Methods <br/>
        
           //Initialize the ZoOm SDK using your app token
           Zoom.sdk.initialize(appToken: /*ZoomDevloperToken*/) { (validationResult) in
            if validationResult {
                // print("AppToken validated successfully")
            } else {
                if Zoom.sdk.getStatus() != .initialized {
                    self.showInitFailedDialog()
                }
            }
           }
        
            func onZoomVerificationResult(result: ZoomVerificationResult){}
            
            /**
           * This method use lunchZoom setup
           * Make sure initialization was successful before launcing ZoOm
           *
            */
            func launchZoomToVerifyLivenessAndRetrieveFacemap() {}
            
            /**
            * This method use to get liveness image and face match score
            * Parameters to Pass: ZoomVerificationResult data
            *
            */
            
            
           func handleVerificationSuccessResult(result:ZoomVerificationResult){}
           
            /**
            * This method use to get liveness score
            * Parameters to Pass: ZoomVerificationResult user scanning data
            *
            */
            func handleResultFromFaceTecManagedRESTAPICall(_result:ZoomVerificationResult){}
                        
            
        g. Set  customURLConnection Delegate
            
            func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, withResponse response: Any!) {
       
             }
    
            func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive response: URLResponse!) {
        
            }
    
           func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didFailWithError error: Error!) {
    
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
            
