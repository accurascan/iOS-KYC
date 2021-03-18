
import UIKit
import SVProgressHUD
import Photos
import AccuraOCR
import PhotosUI

class FaceMatchViewController: UIViewController,UIImagePickerControllerDelegate,UINavigationControllerDelegate,FacematchData, PHPickerViewControllerDelegate {
    
    

    
    //MARK:- Outlet
    @IBOutlet weak var image1: UIImageView!
    @IBOutlet weak var image2: UIImageView!
    
    @IBOutlet weak var faceView1: FaceView!
    @IBOutlet weak var faceView2: FaceView!
    
    @IBOutlet weak var imgUpload: UIImageView!
    @IBOutlet weak var imgUpload2: UIImageView!
    @IBOutlet weak var txtUpload: UILabel!
    @IBOutlet weak var txtUpload2: UILabel!
    @IBOutlet var lableMatchRate: UILabel!
    
    //MARK:- Variable
    var imagePicker = UIImagePickerController()
    var arrDocument: [UIImage] = [UIImage]()
    var selectFirstImage = false
    var facematch = Facematch()
    
    //MARK:- UIViewController Methods
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
        imagePicker.delegate = self
        
        lableMatchRate.text = "Match Score : 0 %";
        NotificationCenter.default.addObserver(self, selector: #selector(loadPhotoCaptured), name: NSNotification.Name("_UIImagePickerControllerUserDidCaptureItem"), object: nil)
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
    override func viewWillAppear(_ animated: Bool) {
        facematch = Facematch.init()
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
        facematch.setGlarePercentage(-1, 99) //set glaremin -1 to remove this filter
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    //MARK:- UIButton Action
    @IBAction func actionBack(_ sender: Any) {
        faceView1 = nil
        faceView2 = nil
        EngineWrapper.faceEngineClose()
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func imageCamera1(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.facematch.setFacematch(self)
        })
        selectFirstImage = true

    }
    
    @IBAction func imageGallery1(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: true)
    }
    
    @IBAction func imageCamera2(_ sender: Any) {
        DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
            self.facematch.setFacematch(self)
            self.view.setNeedsLayout()
        })
        selectFirstImage = false

    }
    
    @IBAction func imageGallery2(_ sender: Any) {
        self.openPhotosLibrary(_isFirst: false)
    }
    
    //MARK:- Custom Methods
    
    /**
     * This method use to check permission photoLibrary and camera
     * Parameters to Pass: bool value first time page open
     */
    
    func openPhotosLibrary(_isFirst: Bool){
        //Check camera permission
        let photos = PHPhotoLibrary.authorizationStatus()
        if photos == .denied || photos == .notDetermined{
            PHPhotoLibrary.requestAuthorization({status in
                if status == .authorized{
                    DispatchQueue.main.async {
                        self.openGallary(_isFirst)
                    }
                    
                } else {
                    let alert = UIAlertController(title: "AccuraFrame", message: "Please allow Photos access to AccuraFrame \n Goto \n  Setting >> AccuraFrame >> Photos", preferredStyle: .alert);
                    let defaultAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                    alert.addAction(defaultAction)
                    self.present(alert, animated: true, completion: nil)
                }
            })
        }else if photos == .authorized{
            DispatchQueue.main.async {
                self.openGallary(_isFirst)
            }
        }
    }
    
    /**
     * This method use to opem camera
     * Parameters to Pass: bool value first time page open
     *
     */
    func openGallary(_ isFirst: Bool){
        if #available(iOS 14, *) {
            selectFirstImage = isFirst
                    // using PHPickerViewController
                    var config = PHPickerConfiguration(photoLibrary: PHPhotoLibrary.shared())
                    config.selectionLimit = 1
                    config.filter = .images
                    config.preferredAssetRepresentationMode = .current
                    let picker = PHPickerViewController(configuration: config)
                    picker.delegate = self
                    self.present(picker, animated: true, completion: nil)
            
        } else {
            selectFirstImage = isFirst
            self.imagePicker.sourceType = .photoLibrary
            self.imagePicker.allowsEditing = false
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
    }
    
    //MARK:- Image Rotation
    @objc func loadPhotoCaptured() {
        let img = allImageViewsSubViews(imagePicker.viewControllers.first?.view)?.last
        if img != nil {
            if let imgView: UIImageView = img as? UIImageView{
                imagePickerController(imagePicker, didFinishPickingMediaWithInfo: convertToUIImagePickerControllerInfoKeyDictionary([convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage) : imgView.image!]))
            }
        } else {
            imagePicker.dismiss(animated: true)
        }
    }
    
    /**
     * This method use get captured view
     * Parameters to Pass: UIView
     *
     * This method will return array of UIImageview
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
    
    //MARK:- ImagePicker delegate
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        
        dismiss(animated: true, completion: nil)
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            guard var originalImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else { return }
            
            
            //Image Resize
            let ratio = CGFloat(originalImage.size.width) / originalImage.size.height
            originalImage = self.compressimage(with: originalImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
            
            let compressData = UIImage(data: originalImage.jpegData(compressionQuality: 1.0)!)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.setFaceRegion(compressData!)//Set FaceMatch score
                SVProgressHUD.dismiss()
            })
        }
        
    }
    @available(iOS 14, *)
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        dismiss(animated: true, completion: nil)
        guard !results.isEmpty else { return }
        // request image urls
        for result in results {
            result.itemProvider.loadObject(ofClass: UIImage.self, completionHandler: { (object, error) in
                if let image = object as? UIImage {
                    DispatchQueue.main.async {
                        // Use UIImage
                        let ratio = CGFloat(image.size.width) / image.size.height
                        let originalImage = self.compressimage(with: image, convertTo: CGSize(width: 600 * ratio, height: 600))!
                        
                        let compressData = UIImage(data: originalImage.jpegData(compressionQuality: 1.0)!)
                        
                        self.setFaceRegion(compressData!)//Set FaceMatch score
                        SVProgressHUD.dismiss()
                        print("Selected image: \(image)")
                    }
                }
            })
        }
    }
    
    
    func facematchData(_ FaceImage: UIImage!) {
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            var originalImage = FaceImage
            
            
            //Image Resize
            let ratio = CGFloat(FaceImage.size.width) / originalImage!.size.height
            originalImage = self.compressimage(with: originalImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
            
            let compressData = UIImage(data: FaceImage.jpegData(compressionQuality: 1.0)!)
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                self.setFaceRegion(compressData!)//Set FaceMatch score
                SVProgressHUD.dismiss()
            })
        }
    }
    
    
    func facematchViewDisappear() {
        
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
 

extension UIImage {
    func resizeWithPercent(percentage: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: size.width * percentage, height: size.height * percentage)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat, height:CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: height)))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
    func resizeWithWidth(width: CGFloat) -> UIImage? {
        let imageView = UIImageView(frame: CGRect(origin: .zero, size: CGSize(width: width, height: CGFloat(ceil(width/size.width * size.height)))))
        imageView.contentMode = .scaleAspectFit
        imageView.image = self
        UIGraphicsBeginImageContextWithOptions(imageView.bounds.size, false, scale)
        guard let context = UIGraphicsGetCurrentContext() else { return nil }
        imageView.layer.render(in: context)
        guard let result = UIGraphicsGetImageFromCurrentImageContext() else { return nil }
        UIGraphicsEndImageContext()
        return result
    }
}


