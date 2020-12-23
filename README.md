# Accura KYC iOS SDK - OCR, Face Match & Liveness Check
iOS KYC SDK - OCR &amp; Face Match <br/><br/>
Accura OCR is used for Optical character recognition.<br/><br/>
Accura Face Match is used for Matching 2 Faces. Source and Target. It matches the User Image from a Selfie vs User Image in document.<br/><br/>
Accura Authentication is used for your customer verification and authentication.Unlock the True Identity of Your Users with 3D Selfie Technology<br/><br/>


Below steps to setup Accura SDK's in your project.


## 1. Setup Accura OCR

Step 1: install the AccuraOCR pod <br />
         pod 'AccuraOCRSDK', '1.1.0'

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

    arrCountryList to get value(forKey: "card_name") //get card Name
    arrCountryList to get value(forKey: "country_id") //get country id
    arrCountryList to get value(forKey: "card_id") //get card id

   Some customized function below. Call this function after initialize sdk
	
   * Sets camera Facing front or back camera
     ```
     accuraCameraWrapper?.setCameraFacing(.CAMERA_FACING_BACK)
     ```
     
   * Flip camera
     ```
     accuraCameraWrapper?.switchCamera()
     ```
   
   * Set Blur Percentage to allow blur on document
     ```
     // 0 for clean document and 100 for Blurry document
     accuraCameraWrapper?.setFaceBlurPercentage(int /*blurPercentage*/60)
     ```    
    
   * Set Blur Face Percentage to allow blur on detected Face
     ```
     // 0 for clean face and 100 for Blurry face
     accuraCameraWrapper?.setFaceBlurPercentage(int /*faceBlurPercentage*/80)
     ```
   
   * Set Glare Percentage to detect Glare on document
   	 ```
     // Set min and max percentage for glare
     accuraCameraWrapper?.setGlarePercentage(int /*minPercentage*/6, int /*maxPercentage*/98)
   	 ``` 
     
   * Set Photo Copy to allow photocopy document or not
     ```
     // Set allow photocopy document or not
     accuraCameraWrapper?.setCheckPhotoCopy(bool /*isCheckPhotoCopy*/false)
     ```
     
   * Set Hologram detection to verify the hologram on the face
	 ```
	 // true to check hologram on face
	 accuraCameraWrapper?.setHologramDetection(boolean /*isDetectHologram*/true)
	 ```
     
   * Set Low Light Tolerance to allow lighting to detect documant
     ```
     // 0 for full dark document and 100 for full bright document
     accuraCameraWrapper?.setLowLightTolerance(int /*lowlighttolerance*/10)
     ``` 
   * Set motion threshold to detect motion on camera document
   	 ```
     // 1 - allows 1% motion on document and
	 // 100 - it can not detect motion and allow document to scan.
     accuraCameraWrapper?.setMotionThreshold(int /*setMotionThreshold*/4 string /*message*/ "Keep Document Steady")
     ```
     
Step 7 : Set CameraView

   Important Grant Camera and storage Permission.
    
    import AccuraOCR
    import AVFoundation
    
    var accuraCameraWrapper: AccuraCameraWrapper? = nil

  	override func viewDidLoad() {
    	super.viewDidLoad()
    	let status = AVCaptureDevice.authorizationStatus(for: .video)
    
    	if status == .authorized {
         	accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: /*setCardId*/ Int32(cardid!), countryID: /*setcountryid*/ Int32(countryid!), isScanOCR:/*Bool*/ isCheckScanOCR, andLabelMsgTop:/*Lable*/ _lblTitle, andcardName:/*string*/  docName, andcardType: Int32(cardType!), andMRZDocType: /*SetMRZDocumentType*/ Int32(MRZDocType!))
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
        			accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: /*setCardId*/ Int32(cardid!), countryID: /*setcountryid*/ Int32(countryid!), isScanOCR:/*Bool*/ isCheckScanOCR, andLabelMsgTop:/*Lable*/ _lblTitle, andcardName:/*string*/  docName, andcardType: Int32(cardType!), andMRZDocType: /*SetMRZDocumentType*/Int32(MRZDocType!))
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
        accuraCameraWrapper?.closeOCR()
        accuraCameraWrapper = nil
        super.viewWillDisappear(animated)
    }
    
    
    extension ViewController: VideoCameraWrapperDelegate{
    	func recognizeSucceedBarcode(_ message: String!) {
    
    	}
    
   		//  it calls continues when scan cards
   		func processedImage(_ image: UIImage!) {
    		image:- get camara image.
    	}
    
    	// it call when license key wrong otherwise didnt get key
    	func recognizeFailed(_ message: String!) {
    		message:- message is a set alert message.
    	}
    
    	// it calls when get MRZ data
    	func recognizeSucceed(_ scanedInfo: NSMutableDictionary!, recType: RecType, bRecDone: Bool, bFaceReplace: Bool, bMrzFirst: Bool, photoImage: UIImage, docFrontImage: UIImage!, docbackImage: UIImage!) {
    		scanedInfo :- get MRZ data.
    		photoImage:- get a document face Image.
    		docFrontImage:- get document frontside image.
   		 	docbackImage:- get document backside image.
    	}
    
    	//   it calls when get front or back side image
    	func matchedItem(_ image: UIImage!, isCardSide1 cs: Bool, isBack b: Bool, isFront f: Bool, imagePhoto imgp: UIImage!, imageResult: UIImage!) {
    		if f == true to set frontside document Image.
    		if f == false to set backside document Image.
    	}
    
    	//  it calls when get OCR data
        func resultData(_ resultmodel: ResultModel!) {
        	resultmodel:- get OCR data
        }
        
        //  it calls when detect vehicle numberplate
        func dlPlateNumber(_ plateNumber: String!, andImageNumberPlate imageNumberPlate: UIImage!) {
        	plateNumber:- get data of numberplate
            imageNumberPlate:- get image of numberplate
            
        }
        
        //  it calls when recieve error message
        func reco_msg(_ messageCode: String!) {
   			var message = String()
    		if messageCode == ACCURA_ERROR_CODE_MOTION {
        		message = "Keep Document Steady"
    		} else if messageCode == ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME {
        		message = "Bring card near to frame"
    		} else if messageCode == ACCURA_ERROR_CODE_BRING_DOCUMENT_IN_FRAME {
        		message = "Bring card near to frame"
    		} else if messageCode == ACCURA_ERROR_CODE_PROCESSING {
        		message = "Processing..."
    		} else if messageCode == ACCURA_ERROR_CODE_BLUR_DOCUMENT {
        		message = "Blur detect in document"
    		} else if messageCode == ACCURA_ERROR_CODE_FACE_BLUR {
        		message = "Blur detected over face"
    		} else if messageCode == ACCURA_ERROR_CODE_GLARE_DOCUMENT {
        		message = "Glare detect in document"
    		} else if messageCode == ACCURA_ERROR_CODE_HOLOGRAM {
        		message = "Hologram Detected"
    		} else if messageCode == ACCURA_ERROR_CODE_DARK_DOCUMENT {
        		message = "Low lighting detected"
    		} else if messageCode == ACCURA_ERROR_CODE_PHOTO_COPY_DOCUMENT {
        		message = "Can not accept Photo Copy Document"
    		} else if messageCode == ACCURA_ERROR_CODE_FACE {
        		message = "Face not detected"
    		} else if messageCode == ACCURA_ERROR_CODE_MRZ {
        		message = "MRZ not detected"
    		} else if messageCode == ACCURA_ERROR_CODE_PASSPORT_MRZ {
        		message = "Passport MRZ not detected"
    		} else if messageCode == ACCURA_ERROR_CODE_RETRYING {
         	  	message = "Retrying..."
       		} else if(message == ACCURA_ERROR_CODE_ID_MRZ) {
            	message = "ID MRZ not detected"
       		} else if(message == ACCURA_ERROR_CODE_VISA_MRZ) {
            	message = "Visa MRZ not detected"
        	}else {
           	 	message = ""
        	}
    		print(message)
		}
 	}


## 2. Setup Accura Face Match

Step 1: install the AccuraFaceMatch pod <br />
        pod 'AccuraFaceMatchSDK', '1.0.5'
            
Step 2: Add licence file in to your project.<br />
            - `accuraface.license` for Accura Face Match <br />
            Generate your Accura licence from <https://accurascan.com/developer/sdk-license>
            
Step 3: Add `FaceView.swift` file in your project.            

Step 4: Implement face match code manually to your activity.

   Important Grant Camera and storage Permission.
    
   	override func viewDidLoad() {
        super.viewDidLoad()
    	/*
         * FaceMatch SDK method to check if engine is initiated or not
         * Return: true or false
         */
        let fmInit = EngineWrapper.isEngineInit()
        if !fmInit{
            /*
             * FaceMatch SDK method initiate SDK engine
             */
            EngineWrapper.faceEngineInit()
    	}
    }
    
    override func viewDidAppear(_ animated: Bool) {
    	super.viewDidAppear(animated)
      	/*
      	 * Facematch SDK method to get SDK engine status after initialization
      	 * Return: -20 = Face Match license key not found, -15 = Face Match license is invalid.
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
             * Accura Face SDK method to detect user face from document image
             * Param: Document image
             * Return: User Face
             */
            faceRegion = EngineWrapper.detectSourceFaces(image)
        }else{
            let face1 : NSFaceRegion? = faceView1.getFaceRegion(); // Get image data
            if (face1 == nil) {
                /*
                 * Accura Face SDK method to detect user face from document image
                 * Param: Document image
                 * Return: User Face
                 */
                faceRegion = EngineWrapper.detectSourceFaces(image);
            } else {
                /*
                 * Accura Face SDK method to detect user face from selfie or camera stream
                 * Params: User photo, user face found in document scanning
                 * Return: User face from user photo
                 */
                faceRegion = EngineWrapper.detectTargetFaces(image, feature1: face1?.feature);
            }
        }
        
        if (selectFirstImage){
            if (faceRegion != nil){
                image1.isHidden = true
                /*
                 * SDK method call to draw square face around
                 * @Params: BackImage, Front Image faceRegion Data
                 */
                faceView1.setFaceRegion(faceRegion)
                
                /*
                 * SDK method call to draw square face around
                 * @Params: BackImage, Front faceRegion Image
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
                     * Accura Face SDK method to detect user face from document image
                     * Param: Document image
                     * Return: User Face
                     */
                    faceRegion2 = EngineWrapper.detectSourceFaces(face2?.image)
                }else{
                    /*
                     * Accura Face SDK method to detect user face from selfie or camera stream
                     * Params: User photo, user face found in document scanning
                     * Return: User face from user photo
                     */
                    faceRegion2 = EngineWrapper.detectTargetFaces(face2?.image, feature1: face2?.feature)  //Identify face in back image which found in front
                }
                
                if(faceRegion2 != nil){
                    image2.isHidden = true
                    /*
                     * SDK method call to draw square face around
                     * @Params: BackImage, Front Image faceRegion Data
                     */
                    faceView2.setFaceRegion(faceRegion2)
                    /*
                     * SDK method call to draw square face around
                     * @Params: BackImage, Front faceRegion Image
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
             * SDK method call to draw square face around
             * @Params: BackImage, Front Image faceRegion Data
             */
            faceView2.setFaceRegion(faceRegion)
            /*
             * SDK method call to draw square face around
             * @Params: BackImage, Front faceRegion Image
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
         * FaceMatch SDK method call to get FaceMatch Score
         * @Params: FrontImage Face, BackImage Face
         * @Return: Match Score
         
         */
        let fmSore = EngineWrapper.identify(face1?.feature, featurebuff2: face2?.feature)
        let twoDecimalPlaces = String(format: "%.2f", fmSore*100) //Match score Convert Float Value
        lableMatchRate.text = "Match Score : \(twoDecimalPlaces) %"
    }

Step 5. Liveness Check

Contact AccuraScan at <contact@accurascan.com> for Liveness SDK or API 
