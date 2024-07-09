# AccuraScan's iOS SDK for KYC & ID Verification - OCR, Face Biometrics and Liveness Check

1. High Accuracy OCR (Optical Character Recognition) Includes English, Latin, Chinese, Korean and Japanese Languages.<br/>

2. Face Biometrics Is Used for Matching Both The Source And The Target Image. It Matches the User's Selfie Image with The Image on The Document.<br/>

3. User Authentication and Liveness Check Is Used for Customer Verification and Authentication. It Protects You from Identity Theft & Spoofing Attacks Through the Use of Active and Passive Selfie Technology for Liveness Check.<br/>


Below steps to setup Accura SDK's in your project.
1. install Git LFS using command `install git-lfs` 

2. Add below pod in podfile
```
    # install the AccuraKYC pod for  AccuraOCR, AccuraFacematch And AccuraLiveness </br>
    pod 'AccuraKYC', '3.2.7'

    # not require below pods if you are installing AccuraKYC pod

    # install the AccuraOCR pod for AccuraOCR only.
    pod 'AccuraOCR', '3.2.2'
    
    # install the AccuraLiveness_FM pod for AccuraLiveness And AccuraFacematch both.</br>
    pod 'AccuraLiveness_FM', '4.2.7'
```
  Note:-If you want to use Framework instead of pods, you can use the below git link, You can clone the project and take the respective .framework file
  * [Accura KYC](https://github.com/accurascan/KYC-SDK-iOS)
  * [Accura OCR](https://github.com/accurascan/AccuraOCR-SDK-iOS/tree/master)
  * [Accura Liveness and Face Match](https://github.com/accurascan/Accura-iOS-SDK-FM-Liveness)
  
  Note:- If you are using frameworks, you need to add the pods present in their respective .podspec file (e.g spec.dependency 'SVProgressHUD' as pod 'SVProgressHUD')

3. Run `pod install`

Note :- after pod install, make sure to check the pod size as mentioned below </br>
* If you are using `AccuraKYC` pod </br>
    `your Project's root dicrectory/Pods/AccuraKYC/Framework/AccuraOCR.framework` </br>
    the `AccuraOCR.framework` size should be around 420 MB
            
* If you are using `AccuraOCR` pod </br>
   ` your Project's root dicrectory/Pods/AccuraOCR/Framework/AccuraOCR.framework` </br>
    the `AccuraOCR.framework` size should be around 310 MB
* If you are using `AccuraLiveness_FM` pod </br>
   ` your Project's root dicrectory/Pods/AccuraLiveness_FM/Framework/AccuraLiveness_FM.framework` </br>
    the `AccuraLiveness_FM.framework` size should be around 160 MB
    
    
            

 4. Solving pod issue (follow this step only if pod size doesnt match as said in point 3) </br>
     i.   Clean the pod using `pod clean` command </br>
     ii.  install Git LFS using `install git-lfs` command </br>
     iii. Run `pod install` </br>

 5. Run the App in Simulator.  ( Optional )</br>
 Note:- Comment the previous pods and use the below pods to run the app in simulator. </br>
```
    # install the AccuraKYC pod for  AccuraOCR, AccuraFacematch And AccuraLiveness </br>
    pod 'AccuraKYC_Sim', '3.2.7'

    # not require below pods if you are installing AccuraKYC pod

    # install the AccuraOCR pod for AccuraOCR only.
    pod 'AccuraOCR_Sim', '3.2.3'
    
    # install the AccuraLiveness_FM pod for AccuraLiveness And AccuraFacematch both.</br>
    pod 'AccuraLiveness_FM_Sim', '4.2.7'
```
  Note:-If you want to use Framework instead of pods, you can use the below git link. You can clone the project and take the respective .framework file
  * [Accura KYC Simulator](https://github.com/accurascan/KYC-SDK-iOS/tree/sim)
  * [Accura OCR Simulator](https://github.com/accurascan/AccuraOCR-SDK-iOS/tree/sim)
  * [Accura Liveness and Face Match Simulator](https://github.com/accurascan/Accura-iOS-SDK-FM-Liveness/tree/sim)
  
  Note:- If you are using frameworks, you need to add the pods present in their respective .podspec file (e.g spec.dependency 'SVProgressHUD' as pod 'SVProgressHUD')

## 1. Setup Accura OCR

#### Step 1: Add license file in to your project.

`key.license`

To generate your Accura license contact sales@accurascan.com <br/>

#### Step 2: To initialize sdk on app start:
```
import AccuraOCR
var accuraCameraWrapper: AccuraCameraWrapper? = nil
var arrCountryList = NSMutableArray()
accuraCameraWrapper = AccuraCameraWrapper.init()
	let sdkModel = accuraCameraWrapper.loadEngine(your PathForDirectories)
	if (sdkModel.i > 0) {
		if(sdkModel!.isBankCardEnable) {
			self.arrCountryList.add("Bank Card")
		}
		if(sdkModel!.isMRZEnable) {
			self.arrCountryList.add("All MRZ")
			// ID MRZ
			// Visa MRZ
			// Passport MRZ
			// All MRZ
		}
		
		// if sdkModel.isOCREnable then get card data

		if (sdkModel.isOCREnable) let countryListStr = self.videoCameraWrapper?.getOCRList();
			if (countryListStr != null) {
				for i in countryListStr!{
					self.arrCountryList.add(i)
				}
			}
		}
		if(sdkModel!.isBarcodeEnable) {
			self.arrCountryList.add("Barcode")
		}
	}
	arrCountryList to get value(forKey: "card_name") //get card Name
	arrCountryList to get value(forKey: "country_id") //get country id
	arrCountryList to get value(forKey: "card_id") //get card id
```
  
#### Optional: Load License File Dynamically
If you prefer to place the license file dynamically, you can use the following function. This method allows you to specify the license file path at runtime
```
let documentDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String

let sdkModel = accuraCameraWrapper?.loadEngine("Your License Path", documentDirectory: documentDirectory)
```

##### Update filters config like below.

Call this function after initialize sdk if license is valid(sdkModel.i > 0)

* Set Blur Percentage to allow blur on document
```
// 0 for clean document and 100 for Blurry document
self.accuraCameraWrapper?.setBlurPercentage(60/*blurPercentage*/)
```

* Set Blur Face Percentage to allow blur on detected Face
```
// 0 for clean face and 100 for Blurry face
accuraCameraWrapper?.setFaceBlurPercentage(80/*faceBlurPercentage*/)
```

* Set Glare Percentage to detect Glare on document
```
// Set min and max percentage for glare
accuraCameraWrapper?.setGlarePercentage(6/*minPercentage*/, 98/*maxPercentage*/)
```

* Set Photo Copy to allow photocopy document or not
```
// Set allow photocopy document or not
accuraCameraWrapper?.setCheckPhotoCopy(false/*isCheckPhotoCopy*/)
```

* Set Hologram detection to verify the hologram on the face
```
// true to check hologram on face
accuraCameraWrapper?.setHologramDetection(true/*isDetectHologram*/)
```

* Set Low Light Tolerance to allow lighting to detect documant
```
// 0 for full dark document and 100 for full bright document
accuraCameraWrapper?.setLowLightTolerance(10/*lowlighttolerance*/)
```

* Set motion threshold to detect motion on camera document
```
// 1 - allows 1% motion on document and
// 100 - it can not detect motion and allow document to scan.
accuraCameraWrapper?.setMotionThreshold(25/*setMotionThreshold*/)
```

* Sets camera Facing front or back camera
```
accuraCameraWrapper?.setCameraFacing(.CAMERA_FACING_BACK)
```

* Flip camera
```
accuraCameraWrapper?.switchCamera()
```

* Set Front/Back Side Scan
```
accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
```

* Enable Print logs in OCR and Liveness SDK
```
accuraCameraWrapper?.showLogFile(true) // Set true to print log from KYC SDK
```

#### Step 3: Set CameraView

Important Grant Camera and storage Permission.</br>
supports Landscape Camera
```
import AccuraOCR
import AVFoundation
var accuraCameraWrapper: AccuraCameraWrapper? = nil
override func viewDidLoad() {
	super.viewDidLoad()
    // initialize Camera for OCR,MRZ,DLplate and BankCard
    accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, cardId: /*setCardId*/ Int32(cardid!), countryID: /*setcountryid*/ Int32(countryid!), isScanOCR:/*Bool*/ isCheckScanOCR, andcardName:/*string*/  docName, andcardType: Int32(cardType/*2 = DLPlate And 3 = bankCard*/), andMRZDocType: /*SetMRZDocumentType*/ Int32(MRZDocType!/*0 = AllMRZ, 1 = PassportMRZ, 2 = IDMRZ, 3 = VisaMRZ*/))
        
    // initialize Camera for Barcode and PDF417 driving license
    accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: imageView, andLabelMsg: lblBottamMsg, andurl: 1, isBarcodeEnable: isBarcodeEnabled/*set true for barcode and false for PDF417 driving license*/, countryID: Int32(self.countryid!), setBarcodeType: .all/*set barcode types*/)
        
	//Set min frame for qatar ID card
	//call this function before start camera
	accuraCameraWrapper?.setMinFrameForValidate(3) // Supports only odd number values
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
	//it sets ViewLayer border according to card image
	func  onUpdateLayout(_ frameSize: CGSize, borderRatio: Float) {
	frameSize:- get layer frame size
	borderRatio:- get layer ratio
	}
    
    func isBothSideAvailable(_ isBothAvailable: Bool) {
        accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
    }
	
	//it calls when scan barcode an PDF417 Driving license
    func recognizeSucceedBarcode(_ message: String!, back BackSideImage: UIImage!, frontImage FrontImage: UIImage!, face FaceImage: UIImage!) {
          //message :- Barcode Data
          //BackSideImage :- back image of Document
          //FrontImage :- front image of Document
          //FaceImage :- Face image of document
          if(isBarcodeEnabled) {
              //display result of barcode
          } else {
               if(BackSideImage == nil) {
                    self.accuraCameraWrapper?.cardSide(.BACK_CARD_SCAN)
                    self.flipAnimation()
              } else if (FrontImage == nil) {
                  self.accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
                  self.flipAnimation()
              }else {
                  //Display Result
              }
         }

	//  it calls continues when detect frame from camera
	func processedImage(_ image: UIImage!) {
		image:- get camara image.
	}

	// it call when license key wrong or didnt get key.license file
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

	// it calls when get front or back side image
	func matchedItem(_ image: UIImage!, isCardSide1 cs: Bool, isBack b: Bool, isFront f: Bool, imagePhoto imgp: UIImage!, imageResult: UIImage!) {
		if f == true to set frontside document Image.
		if f == false to set backside document Image.
	}

	//  it calls when get OCR data
	func resultData(_ resultmodel: ResultModel!) {
        if isbothSideAvailable {
            accuraCameraWrapper?.cardSide(.BACK_CARD_SCAN)
            if(resultmodel.arrayocrBackSideDataKey.count > 0) {
                //Display Result
            }
        } else {
            //Display result
        }
    }

	//  it calls when detect vehicle numberplate
	func dlPlateNumber(_ plateNumber: String!, andImageNumberPlate imageNumberPlate: UIImage!) {
		plateNumber:- get data of numberplate
		imageNumberPlate:- get image of numberplate
	}

	//it calls when get Bank Card data
	func recognizSuccessBankCard(cardDetail: NSMutableDictionary!, andBankCardImage bankCardImage: UIImage!) {
		cardDetail["card_type"] :- get bank card type
		cardDetail["card_number"] :- get bank card number
		cardDetail["expiration_month"] :- get bank card expiry month
		cardDetail["expiration_year"] :- get bank card expiry year
	}

	// it calls when recieve error message
	func reco_msg(_ messageCode: String!) {
		var message = String()
		if messageCode == ACCURA_ERROR_CODE_MOTION {
			message = "Keep Document Steady";
		} else if(messageCode == ACCURA_ERROR_CODE_DOCUMENT_IN_FRAME) {
			message = "Keep document in frame";
		} else if(messageCode == ACCURA_ERROR_CODE_BRING_DOCUMENT_IN_FRAME) {
			message = "Bring card near to frame";
		} else if(messageCode == ACCURA_ERROR_CODE_PROCESSING) {
			message = "Processing...";
		} else if(messageCode == ACCURA_ERROR_CODE_BLUR_DOCUMENT) {
			message = "Blur detect in document";
		} else if(messageCode == ACCURA_ERROR_CODE_FACE_BLUR) {
			message = "Blur detected over face";
		} else if(messageCode == ACCURA_ERROR_CODE_GLARE_DOCUMENT) {
			message = "Glare detect in document";
		} else if(messageCode == ACCURA_ERROR_CODE_HOLOGRAM) {
			message = "Hologram Detected";
		} else if(messageCode == ACCURA_ERROR_CODE_DARK_DOCUMENT) {
			message = "Low lighting detected";
		} else if(messageCode == ACCURA_ERROR_CODE_PHOTO_COPY_DOCUMENT) {
			message = "Can not accept Photo Copy Document";
		} else if(messageCode == ACCURA_ERROR_CODE_FACE) {
			message = "Face not detected";
		} else if(messageCode == ACCURA_ERROR_CODE_MRZ) {
			message = "MRZ not detected";
		} else if(messageCode == ACCURA_ERROR_CODE_PASSPORT_MRZ) {
			message = "Passport MRZ not detected";
		} else if(messageCode == ACCURA_ERROR_CODE_ID_MRZ) {
			message = "ID MRZ not detected"
		} else if(messageCode == ACCURA_ERROR_CODE_VISA_MRZ) {
			message = "Visa MRZ not detected"
		}else if(messageCode == ACCURA_ERROR_CODE_UPSIDE_DOWN_SIDE) {
			message = "Document is upside down. Place it properly"
		}else if(messageCode == ACCURA_ERROR_CODE_WRONG_SIDE) {
			message = "Scanning wrong side of Document"
		}else {
			message = message;
		}
		print(message)
	}
}


// it calls when update title messages
func reco_titleMessage(_ messageCode: Int32) {
    var msg: String = ""
    switch messageCode {
        case SCAN_TITLE_OCR_FRONT:
            var frontMsg = "Scan Front side of ";
            frontMsg = frontMsg.appending(docName)
            msg = frontMsg
            break
        case SCAN_TITLE_OCR_BACK:
            var backMsg = "Scan Back side of ";
            backMsg = backMsg.appending(docName)
            msg = backMsg
            break
        case  SCAN_TITLE_OCR:
            var backMsg = "Scan ";
            backMsg = backMsg.appending(docName)
            msg = backMsg
            break
        case SCAN_TITLE_MRZ_PDF417_FRONT:
            msg = "Scan Front Side of Document"
            break
        case SCAN_TITLE_MRZ_PDF417_BACK:
            msg = "Scan Back Side of Document"
            break
        case SCAN_TITLE_DLPLATE:
            msg = "Scan Number plate"
            break
        case SCAN_TITLE_BARCODE:
            msg = "Scan Barcode"
            break
        case SCAN_TITLE_BANKCARD:
            msg = "Scan BankCard"
            break
        default:
            break
    }
    print(msg)
}
```

## 2. Setup Accura liveness

Contact to  [connect@accurascan.com](mailto:connect@accurascan.com)  to get Url for liveness </br>
Step 1: Open camera for liveness Detectcion.

* import the module name  `import AccuraLiveness_fm`  if you are using `AccuraLiveness_FM` pod


* Setup auto capture Camera

```
//set liveness url
var liveness = Liveness()
liveness.setLivenessURL("/*Your URL*/")

// To customize your screen theme and feed back messages
liveness.setBackGroundColor("#C4C4C5")
liveness.setCloseIconColor("#000000")
liveness.setFeedbackBackGroundColor("#C4C4C5")
liveness.setFeedbackTextColor("#000000")
liveness.setFeedbackTextSize(Float(18.0))
liveness.setFeedBackframeMessage("Frame Your Face")
liveness.setFeedBackAwayMessage("Move Phone Away")
liveness.setFeedBackOpenEyesMessage("Keep Open Your Eyes")
liveness.setFeedBackCloserMessage("Move Phone Closer")
liveness.setFeedBackCenterMessage("Center Your Face")
liveness.setFeedbackMultipleFaceMessage("Multiple face detected")
liveness.setFeedBackFaceSteadymessage("Keep Your Head Straight")
liveness.setFeedBackLowLightMessage("Low light detected")
liveness.setFeedBackBlurFaceMessage("Blur detected over face")
liveness.setFeedBackGlareFaceMessage("Glare detected")

// 0 for clean face and 100 for Blurry face
liveness.setBlurPercentage(80) // set blure percentage -1 to remove this filter

// Set min and max percentage for glare
liveness.setGlarePercentage(6, 99) //set glaremin -1 and glaremax -1 to remove this filter

// if you want to enable SSL certificate pinning for Liveness API set it true. 
// if 'evaluateServerTrustWIthSSLPinning()' is true must have to add SSL Certificate of Your liveness API Server in Your Proeject's Root directory
liveness.evaluateServerTrustWIthSSLPinning(true)

// If an API key is required, call the following method to set it
liveness.setApiKey("Your Api-Key");
```

Step 2: Handle Accura liveness Result
```
// it calls when get liveness result
func livenessData(_ stLivenessValue: String, livenessImage: UIImage, status: Bool){
}

// it calls when liveness camera view dissappear
func livenessViewDisappear() {
}
```


## 3. Setup Accura Face Match


Step 1: Add licence file in to your project.<br />

- `accuraface.license` for Accura Face Match <br />

To Generate Accura Face License please contact sales@accurascan.com

Step 2: Add `FaceView.swift` file in your project.

Step 3: Open auto capture camera

- import the module name  `import AccuraLiveness_fm`  if you are using `AccuraLiveness_FM` pod

```
// To customize your screen theme and feed back messages
var facematch = Facematch()
facematch.setBackGroundColor("#C4C4C5")
facematch.setCloseIconColor("#000000")
facematch.setFeedbackBackGroundColor("#C4C4C5")
facematch.setFeedbackTextColor("#000000")
facematch.setFeedbackTextSize(Float(18.0))
facematch.setFeedBackframeMessage("Frame Your Face")
facematch.setFeedBackAwayMessage("Move Phone Away")
facematch.setFeedBackOpenEyesMessage("Keep Open Your Eyes")
facematch.setFeedBackCloserMessage("Move Phone Closer")
facematch.setFeedBackCenterMessage("Center Your Face")
facematch.setFeedbackMultipleFaceMessage("Multiple face detected")
facematch.setFeedBackFaceSteadymessage("Keep Your Head Straight")
facematch.setFeedBackLowLightMessage("Low light detected")
facematch.setFeedBackBlurFaceMessage("Blur detected over face")
facematch.setFeedBackGlareFaceMessage("Glare detected")

// 0 for clean face and 100 for Blurry face
facematch.setBlurPercentage(80) // set blure percentage -1 to remove this filter

// Set min and max percentage for glare
facematch.setGlarePercentage(6, 99) //set glaremin -1 and glaremax -1 to remove this filter
```

Step 4: Detect face image

```
// it calls when Face image
func facematchData(_ FaceImage: UIImage!) {
	setFaceRegion(FaceImage)
}
// it calls when Facematch camera view dissappear
func facematchViewDisappear() {
}
```

Step 5: Implement face match code manually to your activity.

Important Grant Camera and storage Permission.

```
//if you are using Accura kyc pod need to import module 'import AccuraOCR' and if you using FaceMatchSDK pod need to import module 'import FaceMatchSDK'
import AccuraOCR
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
```

## Optional: Dynamically Place License File
If you prefer to place the license file dynamically, you can use the following method. This allows you to specify the license file path at runtime.
```
EngineWrapper.faceEngineInit("Face License Path")
```


override func viewDidAppear(_ animated: Bool) {
	super.viewDidAppear(animated)
	/*
	 * Facematch SDK method to get SDK engine status after initialization
	 * Return: -20 = Face Match license key not found, -15 = Face Match license is invalid.
	 */
	let fmValue = EngineWrapper.getEngineInitValue() //get engineWrapper load status
	if fmValue == -20{
		// key not found
	}else if fmValue == -15{
		// License Invalid
	}
}

//make sure close FaceEngine when view disappear
override func viewDidDisappear(_ animated: Bool) {
    EngineWrapper.faceEngineClose()
}

/**
 * This method use calculate faceMatch score
 * Parameters to Pass: selected uiimage
 *
 */
func setFaceRegion(_ image: UIImage) {
	var faceRegion : NSFaceRegion?
	/*
	 * Accura Face SDK method to detect user face from document image
	 * Param: Document image
	 * Return: User Face
	 */
	faceRegion = EngineWrapper.detectSourceFaces(image)
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
	if (selectFirstImage){
		if (faceRegion != nil){
			/*
			 * SDK method call to draw square face around
			 * @Params: BackImage, Front Image faceRegion Data
			 */
			faceView1.setFaceRegion(faceRegion)
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
				/*
			     * SDK method call to draw square face around
				 * @Params: BackImage, Front Image faceRegion Data
				 */
				faceView2.setFaceRegion(faceRegion2)
				/*
				 * SDK method call to draw square face around
				 * @Params: BackImage, Front faceRegion Image
				 */
			}
		}
	} else if(faceRegion != nil){
	/*
	 * SDK method call to draw square face around
	 * @Params: BackImage, Front Image faceRegion Data
	 */
	faceView2.setFaceRegion(faceRegion)
	/*
	 * SDK method call to draw square face around
	 * @Params: BackImage, Front faceRegion Image
	 *
	}
	let face1:NSFaceRegion? = faceView1.getFaceRegion() // Get image data
	let face2:NSFaceRegion? = faceView2.getFaceRegion() // Get image data
	/*
	 * FaceMatch SDK method call to get FaceMatch Score
	 * @Params: FrontImage Face, BackImage Face
	 * @Return: Match Score
	 */
	let fmSore = EngineWrapper.identify(face1?.feature, featurebuff2: face2?.feature)
	let twoDecimalPlaces = String(format: "%.2f", fmSore*100) //Match score Convert Float Value
	print(Match Score :- "\(twoDecimalPlaces) %")
}
```
