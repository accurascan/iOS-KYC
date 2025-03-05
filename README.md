# AccuraScan's iOS SDK for MICR Cheque Scanning

### Download

1. install and initialize the Git LFS

2. Clone the demo app and get the AccuraMICR.framework file and add it in your project

3. After adding the framework go to targets->general and there select AccuraMICR.framework and chandge the embed symbol to `Embed & Sign`

4. Open `AccuraSDK.xcworkspace` in xcode for a better understanding of the project


## 1. Setup Accura MICR


#### Step 1: Add license file in to your project.


`key.license`


Generate your Accura license contact sales@accurascan.com <br/>


#### Step 2: To initialize sdk on app start:
```
import AccuraOCR
var accuraMICRWrapper: AccuraMICRWrapper? = nil
accuraMICRWrapper = AccuraMICRWrapper.init()
        let sdkModel = accuraMICRWrapper.loadEngine(your PathForDirectories)
        if (sdkModel.i > 0) {
                if(sdkModel?.isMICREnable) {
                
                }
        }
```
  


##### Update filters config like below.


Call this function after initialize sdk if license is valid(sdkModel.i > 0)


* Set Blur Percentage to allow blur on document
```
// 0 for clean document and 100 for Blurry document
self.accuraCameraWrapper?.setBlurPercentage(60/*blurPercentage*/)
```

* Set Glare Percentage to detect Glare on document
```
// Set min and max percentage for glare
accuraCameraWrapper?.setGlarePercentage(6/*minPercentage*/, 98/*maxPercentage*/)
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
    // initialize Camera for MICR
    accuraCameraWrapper = AccuraMICRWrapper.init(delegate: self, andImageView: /*setImageView*/ _imageView, andLabelMsg: */setLable*/ lblOCRMsg, andurl: */your PathForDirectories*/ NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String, type: bankCode/*MICRTYPE*/)   
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
	//it sets ViewLayer border according to card image
	func  onUpdateLayout(_ frameSize: CGSize, borderRatio: Float) {
	frameSize:- get layer frame size
	borderRatio:- get layer ratio
	}

	//  it calls continues when detect frame from camera
	func processedImage(_ image: UIImage!) {
		image:- get camara image.
	}

	// it call when license key wrong or didnt get key.license file
	func recognizeFailed(_ message: String!) {
		message:- message is a set alert message.
	}
	//it calls when get MICR data
    func recognizeSucceedMICR(_ scanedInfo: String!, photoImage: UIImage!) {
		
	}

	// it calls when recieve error message
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
		print(message)
	}
}
```
