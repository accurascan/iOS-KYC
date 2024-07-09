
import UIKit
import AVFoundation
import Foundation
import AccuraOCR

class CodeScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate, UIGestureRecognizerDelegate, VideoCameraWrapperDelegate, SelectedTypesDelegate {
    
    
    
    //MARK:- Outlet
    @IBOutlet var mainV: MainV!
    @IBOutlet weak var barCodeScannerView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewScan: UIView!
    @IBOutlet weak var imageViewFilp: UIImageView!
    @IBOutlet weak var labelMsg: UILabel!
    @IBOutlet weak var lblBottamMsg: UILabel!
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var constrintViweBorderHeight: NSLayoutConstraint!
    
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var constrintVIewBorderWidth: NSLayoutConstraint!
    @IBOutlet weak var viewSelectBarcode: UIView!
    
    @IBOutlet weak var buttonBarcodeTypePotrait: UIButton!
    @IBOutlet weak var buttonBarcodeTypeLandscape: UIButton!
    @IBOutlet weak var buttonBarcodeTpeHeight: NSLayoutConstraint!
    @IBOutlet weak var buttonBarcodeTypeWidth: NSLayoutConstraint!
    
    
    //MARK:- Variable
    var mutableArray: NSMutableArray = []
    var keyArr: NSMutableArray = []
    var valueArr: NSMutableArray = []
    var keys : NSArray = []
    var passDict = [String: String]()
    var emptyDictionary = [String: String]()
    var selectedTypes: BarcodeType = .all
    var captureSession: AVCaptureSession!
    var previewLayer: AVCaptureVideoPreviewLayer!
    var scanRegionTimer: Timer!
    var metadataOutput: AVCaptureMetadataOutput!
    var tapToDismiss: UITapGestureRecognizer!
    var scanTimer: Timer?
    var scanEnabled: Bool = true
    var isBarcodeEnabled: Bool = false
    var torchOn: Bool = false
    let prefs:UserDefaults = UserDefaults.standard
    var isFrom:String!
    var photoImage1: UIImage? = nil
    var imgViewFront : UIImage? = nil
    var imgViewBack : UIImage? = nil
    var accuraCameraWrapper: AccuraCameraWrapper? = nil
    var cardid : Int? = 0
    var countryid : Int? = 0
    var stillImageOutput : AVCaptureStillImageOutput!
    var isResultShow = false
    var statusBarRect = CGRect()
    var bottomPadding:CGFloat = 0.0
    var topPadding: CGFloat = 0.0
    var isFirstTimeStartCamara: Bool?
    var isCheckFirstTime : Bool?
    var cardType: Int? = 0
    var passStr: String = ""
    var barcodeData: String = ""
    
    //MARK:- UIViewController Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBarRect = UIApplication.shared.statusBarFrame
        let window = UIApplication.shared.windows.first
       
        if #available(iOS 11.0, *) {
            bottomPadding = window!.safeAreaInsets.bottom
            topPadding = window!.safeAreaInsets.top
        } else {
            // Fallback on earlier versions
        }

        ChangedOrientation()
        isFirstTimeStartCamara = false
        isCheckFirstTime = false
        var width : CGFloat = 0
        var height : CGFloat = 0
        
        width = UIScreen.main.bounds.size.width
        height = UIScreen.main.bounds.size.height
        width = width * 0.95
        height = height * 0.35
        
        constrintVIewBorderWidth.constant = width
        constrintViweBorderHeight.constant = height
        
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        viewScan.layer.borderColor = UIColor.red.cgColor
        viewScan.layer.borderWidth = 3.0
        
        self.imageViewFilp.isHidden = true
        
        if status == .authorized {
            isCheckFirstTime = true
            accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: imageView, andLabelMsg: lblBottamMsg, andurl: 1, isBarcodeEnable: isBarcodeEnabled, countryID: Int32(countryid!), setBarcodeType: selectedTypes)
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
                    self.accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: self.imageView, andLabelMsg: self.lblBottamMsg, andurl: 1, isBarcodeEnable: self.isBarcodeEnabled, countryID: Int32(self.countryid!), setBarcodeType: self.selectedTypes)
        
                    self.accuraCameraWrapper?.startCamera()
                    
                    let shortTap = UITapGestureRecognizer(target: self, action: #selector(self.handleTapToFocus(_:)))
                    shortTap.numberOfTapsRequired = 1
                    shortTap.numberOfTouchesRequired = 1
                } else {
                    // print("Not granted access")
                }
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if(isBarcodeEnabled) {
            let orientastion = UIApplication.shared.statusBarOrientation
            if(orientastion ==  UIInterfaceOrientation.portrait) {
                buttonBarcodeTypeLandscape.isHidden = true
                buttonBarcodeTypePotrait.isHidden = false
            } else {
                buttonBarcodeTypeLandscape.isHidden = false
                buttonBarcodeTypePotrait.isHidden = true
            }
            buttonBarcodeTypePotrait.layer.cornerRadius = buttonBarcodeTpeHeight.constant / 2
        } else {
            buttonBarcodeTypeLandscape.isHidden = true
            buttonBarcodeTypePotrait.isHidden = true
        }
       
            self.ChangedOrientation()
            isResultShow = false
            if self.accuraCameraWrapper == nil {
                imageView.isHidden = false
                barCodeScannerView.isHidden = true
                accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self, andImageView: imageView, andLabelMsg: lblBottamMsg, andurl: 1, isBarcodeEnable: isBarcodeEnabled, countryID: Int32(self.countryid!), setBarcodeType: selectedTypes)
            }
        if isFirstTimeStartCamara!{
            accuraCameraWrapper?.startCamera()
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        if !isFirstTimeStartCamara! && isCheckFirstTime!{

          isFirstTimeStartCamara = true
          accuraCameraWrapper?.startCamera()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        accuraCameraWrapper?.stopCamera()
        accuraCameraWrapper = nil
        imageView.image = nil
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning() // Stop Camera Scanning
        }
        mainV.removeAlert()
        super.viewWillDisappear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
    }
    
    @objc func handleTapToFocus(_ tapGesture: UITapGestureRecognizer?) {
        
        let acd = AVCaptureDevice.default(for: .video)
        if tapGesture!.state == .ended {
            let thisFocusPoint = tapGesture!.location(in: viewScan)
            let focus_x = Double(thisFocusPoint.x / viewScan.frame.size.width)
            let focus_y = Double(thisFocusPoint.y / viewScan.frame.size.height)
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

    
    @objc private func ChangedOrientation() {
        var width: CGFloat = 0.0
        var height: CGFloat = 0.0
    
        let orientastion = UIApplication.shared.statusBarOrientation
        if(orientastion ==  UIInterfaceOrientation.portrait) {
            width = UIScreen.main.bounds.size.width * 0.95
            height  = (UIScreen.main.bounds.size.height - (self.bottomPadding + self.topPadding + self.statusBarRect.height)) * 0.35
            viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
            viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        } else {

            self.viewNavigationBar.backgroundColor = .clear
            height = UIScreen.main.bounds.size.height * 0.62
            width = UIScreen.main.bounds.size.width * 0.51
        }
        
        constrintVIewBorderWidth.constant = width
        constrintViweBorderHeight.constant = height
        
        UIView.animate(withDuration: 0.1, delay: 0, options: .curveEaseIn, animations: {
            self.view.layoutIfNeeded()
        }) { _ in
            
        }
    }
    
    //MARK:- UIButton Action
    @objc func backBtnPressed() {
       
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning() // Stop Camera Scanning
        }
        mainV.removeAlert()
        navigationController?.popViewController(animated: true)
    }
    
    @objc func conBtnPressed() {
        if (captureSession?.isRunning == true) {
            captureSession.stopRunning() // Stop Camera Scanning
        }
        mainV.removeAlert()
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        
        self.accuraCameraWrapper?.stopCamera()
        UserDefaults.standard.removeObject(forKey: "type")
        mainV.removeAlert()
        navigationController?.popViewController(animated: true)
    }
    @IBAction func buttonFlipCameraAction(_ sender: UIButton) {
        accuraCameraWrapper?.switchCamera()
        
    }
    @IBAction func buttonSelectBarcodeActio(_ sender: UIButton) {
        self.accuraCameraWrapper?.stopCameraPreview()
        let loginVC = UIStoryboard(name: "SelectCodeVC", bundle: nil).instantiateViewController(withIdentifier: "SelectCodeVC") as! SelectCodeVC
        loginVC.selectedTypesDelegate = self
        loginVC.modalPresentationStyle = .overCurrentContext
        loginVC.modalTransitionStyle = .crossDissolve
        self.present(loginVC, animated: true, completion: nil)
        
    }
    
    //MARK:- UIGesture Methods
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func toggleTorch(on: Bool) {
        guard let device = AVCaptureDevice.default(for: .video) else { return }
        
        if device.hasTorch {
            do {
                try device.lockForConfiguration()
                
                if on == true {
                    device.torchMode = .on
                } else {
                    device.torchMode = .off
                }
                
                device.unlockForConfiguration()
            } catch {
                // print("Torch could not be used")
            }
        } else {
            // print("Torch is not available")
        }
    }
    
    //MARK:- Custom Action
    func setSelectedTypes(types: String) {
        print("set selected")
        switch types
        {
        case "ALL FORMATS":
            self.selectedTypes = .all
        case "EAN-8":
            self.selectedTypes = .ean8
        case "EAN-13":
            self.selectedTypes = .ean13
        case "PDF417":
            self.selectedTypes = .pdf417
        case "AZTEC":
            self.selectedTypes = .aztec
        case "CODE 128":
            self.selectedTypes = .code128
        case "CODE 39":
            self.selectedTypes = .code39
        case "CODE 93":
            self.selectedTypes = .code93
        case "DATA MATRIX":
            self.selectedTypes = .dataMatrix
        case "ITF":
            self.selectedTypes = .itf
        case "QR CODE":
            self.selectedTypes = .qrcode
        case "UPC-E":
            self.selectedTypes = .upce
        case "UPC-A":
            self.selectedTypes = .upca
        case "CODABAR":
            self.selectedTypes = .codabar
        default:
            break
        }
        accuraCameraWrapper?.change(selectedTypes)
        accuraCameraWrapper?.startCameraPreview()
    }
    
    //AVCaptureMetadata using get Scanning Data
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if scanEnabled
        {
            scanTimer = Timer.scheduledTimer(timeInterval: 2.0, target: self, selector: #selector(enableScan), userInfo: nil, repeats: false)
            scanEnabled = false
            
            if let metadataObject = metadataObjects.first
            {
                // print(metadataObject)
                guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
                guard let stringValue = readableObject.stringValue else { return }
                capture()
                AudioServicesPlaySystemSound (1315);
                let isPDF = self.decodework(type: stringValue)
                if (isPDF == true) {
                    if (captureSession?.isRunning == true) {
                        captureSession.stopRunning() // Stop Camera Scanning
                    }
                    mainV.removeAlert()
                    let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
                    let placeVC = codeStory.instantiateViewController(withIdentifier: "Resultpdf417ViewController") as? Resultpdf417ViewController
                    placeVC?.keyArr = keyArr as! [String]
                    placeVC?.valueArr = valueArr as! [String]
                    placeVC?.passStr = stringValue
                    placeVC?.photoImage = photoImage1
                    placeVC?.imgViewFront = imgViewFront
                    placeVC?.imgViewBack = imgViewBack
                    if let aVC = placeVC {
                        navigationController?.pushViewController(aVC, animated: true)
                    }
                }
                else {
                found(code: stringValue)
                }
            }
        }
    }
    
    //Check Decode Type Exist
    func decodework (type: String) -> Bool {
        keyArr.removeAllObjects()
        valueArr.removeAllObjects()
        let Customer_Family_Name = "DCS"
        let Family_Name = "DAB"
        
        let Customer_Given_Name =  "DCT"
        let Name_Suffix = "DCU"
        let Street_Address_1 = "DAG"
        let City = "DAI"
        let Jurisdction_Code = "DAJ"
        let ResidenceJurisdictionCode = "DAO"
        let MedicalIndicatorCodes = "DBG"
        let NonResidentIndicator = "DBI"
        let  SocialSecurityNumber = "DBK"
        let  DateOfBirth = "DBL"
        
        let Postal_Code = "DAK"
        let Customer_Id_Number = "DAQ"
        let Expiration_Date = "DBA"
        let Sex = "DBC"
        let Customer_Full_Name = "DAA"
        let Customer_First_Name = "DAC"
        let Customer_Middle_Name = "DAD"
        let Street_Address_2 = "DAH"
        let Street_Address_1_optional = "DAL"
        let Street_Address_2_optional = "DAM"
        let Date_Of_Birth = "DBB"
        let  NameSuff = "DAE"
        let  NamePref = "DAF"
        let LicenseClassification = "DAR"
        let  LicenseRestriction = "DAS"
        let LicenseEndorsement = "DAT"
        let  IssueDate = "DBD"
        let OrganDonor = "DBH"
        let HeightFT = "DAU"
        let  FullName = "DAA"
        let  GivenName = "DAC"
        let HeightCM = "DAV"
        let WeightLBS = "DAW"
        let WeightKG = "DAX"
        let EyeColor = "DAY"
        let HairColor = "DAZ"
        let IssueTimeStemp = "DBE"
        let NumberDuplicate = "DBF"
        let UniqueCustomerId = "DBJ"
        let SocialSecurityNo = "DBM"
        let Under18 = "DDH"
        let Under19 = "DDI"
        let Under21 = "DDJ"
        let PermitClassification = "PAA"
        let VeteranIndicator = "DDL"
        let  PermitIssue = "PAD"
        let PermitExpire = "PAB"
        let PermitRestriction = "PAE"
        let PermitEndorsement = "PAF"
        let CourtRestriction = "ZVA"
        let InventoryControlNo = "DCK"
        let  RaceEthnicity = "DCL"
        let StandardVehicleClass = "DCM"
        let DocumentDiscriminator = "DCF"
        let VirginiaSpecificClass = "DCA"
        let VirginiaSpecificRestrictions = "DCB"
        let PhysicalDescriptionWeight =  "DCD"
        let CountryTerritoryOfIssuance = "DCG"
        let FederalCommercialVehicleCodes = "DCH"
        let  PlaceOfBirth =  "DCI"
        let AuditInformation = "DCJ"
        let StandardEndorsementCode = "DCN"
        let StandardRestrictionCode = "DCO"
        let JurisdictionSpecificVehicleClassificationDescription = "DCP"
        let  JurisdictionSpecific = "DCQ"
        let JurisdictionSpecificRestrictionCodeDescription = "DCR"
        let  ComplianceType = "DDA"
        let CardRevisionDate = "DDB"
        let  HazMatEndorsementExpiryDate = "DDC"
        let  LimitedDurationDocumentIndicator = "DDD"
        let FamilyNameTruncation = "DDE"
        let   FirstNamesTruncation = "DDF"
        let MiddleNamesTruncation = "DDG"
        let OrganDonorIndicator =  "DDK"
        let  PermitIdentifier = "PAC"
        
        
        mutableArray.add(Customer_Full_Name)
        mutableArray.add(Customer_Family_Name)
        mutableArray.add(Family_Name)
        
        mutableArray.add(Customer_Given_Name)
        mutableArray.add(Name_Suffix)
        mutableArray.add(Street_Address_1)
        mutableArray.add(City)
        mutableArray.add(Jurisdction_Code)
        mutableArray.add(ResidenceJurisdictionCode)
        mutableArray.add(MedicalIndicatorCodes)
        mutableArray.add(NonResidentIndicator)
        mutableArray.add(SocialSecurityNumber)
        mutableArray.add(DateOfBirth)
        mutableArray.add(VirginiaSpecificClass)
        mutableArray.add(VirginiaSpecificRestrictions)
        mutableArray.add(PhysicalDescriptionWeight)
        mutableArray.add(CountryTerritoryOfIssuance)
        mutableArray.add(FederalCommercialVehicleCodes)
        mutableArray.add(PlaceOfBirth)
        mutableArray.add(AuditInformation)
        mutableArray.add(StandardEndorsementCode)
        mutableArray.add(JurisdictionSpecificVehicleClassificationDescription)
        mutableArray.add(JurisdictionSpecific)
        mutableArray.add(PermitIdentifier)
        mutableArray.add(OrganDonorIndicator)
        mutableArray.add(MiddleNamesTruncation)
        mutableArray.add(FirstNamesTruncation)
        mutableArray.add(FamilyNameTruncation)
        mutableArray.add(HazMatEndorsementExpiryDate)
        mutableArray.add(LimitedDurationDocumentIndicator)
        mutableArray.add(CardRevisionDate)
        mutableArray.add(ComplianceType)
        mutableArray.add(JurisdictionSpecificRestrictionCodeDescription)
        mutableArray.add(StandardRestrictionCode)
     
        mutableArray.add(Postal_Code)
        mutableArray.add(Customer_Id_Number)
        mutableArray.add(Expiration_Date)
        mutableArray.add(Sex)
        mutableArray.add(Customer_First_Name)
        mutableArray.add(Customer_Middle_Name)
        mutableArray.add(Street_Address_2)
        mutableArray.add(Street_Address_1_optional)
        mutableArray.add(Street_Address_2_optional)
        mutableArray.add(Date_Of_Birth)
        mutableArray.add(NameSuff)
        mutableArray.add(NamePref)
        mutableArray.add(LicenseClassification)
        mutableArray.add(LicenseRestriction)
        mutableArray.add(LicenseEndorsement)
        mutableArray.add(IssueDate)
        mutableArray.add(OrganDonor)
        mutableArray.add(HeightFT)
        mutableArray.add(FullName)
        mutableArray.add(GivenName)
        mutableArray.add(HeightCM)
        mutableArray.add(WeightLBS)
        mutableArray.add(WeightKG)
        mutableArray.add(EyeColor)
        mutableArray.add(HairColor)
        mutableArray.add(IssueTimeStemp)
        mutableArray.add(NumberDuplicate)
        mutableArray.add(UniqueCustomerId)
        mutableArray.add(SocialSecurityNo)
        mutableArray.add(Under18)
        mutableArray.add(Under19)
        mutableArray.add(Under21)
        mutableArray.add(PermitClassification)
        mutableArray.add(VeteranIndicator)
        mutableArray.add(PermitIssue)
        mutableArray.add(PermitExpire)
        mutableArray.add(PermitRestriction)
        mutableArray.add(PermitEndorsement)
        mutableArray.add(CourtRestriction)
        mutableArray.add(InventoryControlNo)
        mutableArray.add(RaceEthnicity)
        mutableArray.add(StandardVehicleClass)
        mutableArray.add(DocumentDiscriminator)
        
        var emptyDictionary = [String: String]()
        var passDict = [String: String]()
        
        let fullstrArr = type.components(separatedBy: "\n")
        for object in fullstrArr {
            var str = object as String
            if str.contains("ANSI")  {
                let parts = str.components(separatedBy: "DL")
                if parts.count > 1 {
                    str = parts[parts.count-1]
                }
                
                
            }
            let count = str.count
            
            if count > 3 {
                (str as NSString).substring(with: NSRange(location: 0, length: 3))
                let key  = str.index(str.startIndex, offsetBy:3)
                let key1 = String(str[..<key])
                
                let indexsd = str.index(str.startIndex, offsetBy: 3)
                let tempstr = str[indexsd...]  // "Hello>>>"
                if (tempstr != "NONE") {
                    emptyDictionary.updateValue(String(tempstr), forKey: key1)
                    
                }
                
            }
        }
        if((emptyDictionary["DAA"]) != nil) {
            passDict.updateValue(emptyDictionary["DAA"]!, forKey: "FULL NAME: ")
            if(keyArr .contains("FULL NAME: ")) {
            }
            else {
               valueArr.add(emptyDictionary["DAA"]!)
                keyArr.add("FULL NAME: ")
            }
        }
       
        if((emptyDictionary["DAB"]) != nil) {
            passDict.updateValue(emptyDictionary["DAB"]!, forKey: "LAST NAME:")
            if(keyArr .contains("LAST NAME:")) {
            }
            else {
                valueArr.add(emptyDictionary["DAB"]!)
                keyArr.add("LAST NAME:")
            }
            
            
        }
       
        if((emptyDictionary["DAC"]) != nil) {
            passDict.updateValue(emptyDictionary["DAC"]!, forKey: "FIRST NAME:")
            if(keyArr .contains("FIRST NAME: ") ) {
                
            }
            else {
                valueArr.add(emptyDictionary["DAC"]!)
                keyArr.add("FIRST NAME: ")
            }
            
            
        }
       
      
        if((emptyDictionary["DAD"]) != nil) {
            passDict.updateValue(emptyDictionary["DAD"]!, forKey: "MIDDLE NAME:")
            if(keyArr .contains("MIDDLE NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAD"]!)
                keyArr.add("MIDDLE NAME:")
            }
            
            
        }
       
        if((emptyDictionary["DAE"]) != nil) {
            passDict.updateValue(emptyDictionary["DAE"]!, forKey: "NAME SUFFIX: ")
            if(keyArr .contains("NAME SUFFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAE"]!)
                keyArr.add("NAME SUFFIX: ")
            }
        }
        
        if((emptyDictionary["DAF"]) != nil) {
            passDict.updateValue(emptyDictionary["DAF"]!, forKey: "NAME PREFIX: ")
            if(keyArr .contains("NAME PREFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAF"]!)
                keyArr.add("NAME PREFIX: ")
            }
        }

        if((emptyDictionary["DAG"]) != nil) {
            passDict.updateValue(emptyDictionary["DAG"]!, forKey: "MAILING STREET ADDRESS1: ")
            if(keyArr .contains("MAILING STREET ADDRESS1: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAG"]!)
                keyArr.add("MAILING STREET ADDRESS1: ")
            }
            
        }
      
        if((emptyDictionary["DAH"]) != nil) {
            passDict.updateValue(emptyDictionary["DAH"]!, forKey: "MAILING STREET ADDRESS2: ")
            if(keyArr .contains("MAILING STREET ADDRESS2: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAH"]!)
                keyArr.add("MAILING STREET ADDRESS2: ")
            }
        }
        
        if((emptyDictionary["DAI"]) != nil) {
            passDict.updateValue(emptyDictionary["DAI"]!, forKey: "MAILING CITY:")
            if(keyArr .contains("MAILING CITY:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAI"]!)
                keyArr.add("MAILING CITY:")
            }
            
        }
        
       
        if((emptyDictionary["DAJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAJ"]!, forKey: "MAILING JURISDICTION CODE: ")
            if(keyArr .contains("MAILING JURISDICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAJ"]!)
                keyArr.add("MAILING JURISDICTION CODE: ")
            }
            
        }
        
        if((emptyDictionary["DAK"]) != nil) {
            passDict.updateValue(emptyDictionary["DAK"]!, forKey: "MAILING POSTAL CODE:")
            if(keyArr .contains("MAILING POSTAL CODE:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAK"]!)
                keyArr.add("MAILING POSTAL CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["DAL"]) != nil) {
            passDict.updateValue(emptyDictionary["DAL"]!, forKey: "RESIDENCE STREET ADDRESS1: ")
            if(keyArr .contains("RESIDENCE STREET ADDRESS1: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAL"]!)
                keyArr.add("RESIDENCE STREET ADDRESS1: ")
            }
        }
        
        if((emptyDictionary["DAM"]) != nil) {
            passDict.updateValue(emptyDictionary["DAM"]!, forKey: "RESIDENCE STREET ADDRESS2: ")
            if(keyArr .contains("RESIDENCE STREET ADDRESS2: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAM"]!)
                keyArr.add("RESIDENCE STREET ADDRESS2: ")
            }
        }
       
        if((emptyDictionary["DAN"]) != nil) {
            passDict.updateValue(emptyDictionary["DAN"]!, forKey: "RESIDENCE CITY: ")
            if(keyArr .contains("RESIDENCE CITY: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAN"]!)
                keyArr.add("RESIDENCE CITY: ")
            }
        }
        
        if((emptyDictionary["DAO"]) != nil) {
            passDict.updateValue(emptyDictionary["DAO"]!, forKey: "RESIDENCE JURISDICTION CODE: ")
            if(keyArr .contains("RESIDENCE JURISDICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAO"]!)
                keyArr.add("RESIDENCE JURISDICTION CODE: ")
            }
            
        }
       
        if((emptyDictionary["DAP"]) != nil) {
            passDict.updateValue(emptyDictionary["DAP"]!, forKey: "RESIDENCE POSTAL CODE: ")
            if(keyArr .contains("RESIDENCE POSTAL CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAP"]!)
                keyArr.add("RESIDENCE POSTAL CODE: ")
            }
            
        }
        
        if((emptyDictionary["DAQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAQ"]!, forKey: "LICENCE OR ID NUMBER: ")
            if(keyArr .contains("LICENCE OR ID NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAQ"]!)
                keyArr.add("LICENCE OR ID NUMBER: ")
            }
        }
       
        if((emptyDictionary["DAR"]) != nil) {
            passDict.updateValue(emptyDictionary["DAR"]!, forKey: "LICENCE CLASSIFICATION CODE: ")
            if(keyArr .contains("LICENCE CLASSIFICATION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAR"]!)
                keyArr.add("LICENCE CLASSIFICATION CODE: ")
            }
        }
        
        if((emptyDictionary["DAS"]) != nil) {
            passDict.updateValue(emptyDictionary["DAS"]!, forKey: "LICENCE RESTRICTION CODE: ")
            if(keyArr .contains("LICENCE RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAS"]!)
                keyArr.add("LICENCE RESTRICTION CODE: ")
            }
        }
        
        if((emptyDictionary["DAT"]) != nil) {
            passDict.updateValue(emptyDictionary["DAT"]!, forKey: "LICENCE ENDORSEMENT CODE: ")
            if(keyArr .contains("LICENCE ENDORSEMENT CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAT"]!)
                keyArr.add("LICENCE ENDORSEMENT CODE: ")
            }
        }
    
        if((emptyDictionary["DAU"]) != nil) {
            passDict.updateValue(emptyDictionary["DAU"]!, forKey: "HEIGHT IN FT_IN: ")
            if(keyArr .contains("HEIGHT IN FT_IN: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAU"]!)
                keyArr.add("HEIGHT IN FT_IN:")
            }
        }
       
        if((emptyDictionary["DAV"]) != nil) {
            passDict.updateValue(emptyDictionary["DAV"]!, forKey: "HEIGHT IN CM: ")
            if(keyArr .contains("HEIGHT IN CM: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAV"]!)
                keyArr.add("HEIGHT IN CM: ")
            }
        }
        
        if((emptyDictionary["DAW"]) != nil) {
            passDict.updateValue(emptyDictionary["DAW"]!, forKey: "WEIGHT IN LBS: ")
            if(keyArr .contains("WEIGHT IN LBS: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAW"]!)
                keyArr.add("WEIGHT IN LBS: ")
            }
            
            
        }
       
        if((emptyDictionary["DAX"]) != nil) {
            passDict.updateValue(emptyDictionary["DAX"]!, forKey: "WEIGHT IN KG:")
            if(keyArr .contains("WEIGHT IN KG:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAX"]!)
                keyArr.add("WEIGHT IN KG:")
            }
        }
        
        if((emptyDictionary["DAY"]) != nil) {
            passDict.updateValue(emptyDictionary["DAY"]!, forKey: "EYE COLOR: ")
            if(keyArr .contains("EYE COLOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAY"]!)
                keyArr.add("EYE COLOR:")
            }
        
        }
        
        if((emptyDictionary["DAZ"]) != nil) {
            passDict.updateValue(emptyDictionary["DAZ"]!, forKey: "HAIR COLOR: ")
            if(keyArr .contains("HAIR COLOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DAZ"]!)
                keyArr.add("HAIR COLOR:")
            }
            
            
            
        }
       
        if((emptyDictionary["DBA"]) != nil) {
            passDict.updateValue(emptyDictionary["DBA"]!, forKey: "LICENSE EXPIRATION DATE: ")
            if(keyArr .contains("LICENSE EXPIRATION DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DBA"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("LICENSE EXPIRATION DATE: ")
            }
        }
        if((emptyDictionary["DBB"]) != nil) {
            passDict.updateValue(emptyDictionary["DBB"]!, forKey:  "DATE OF BIRTH: ")
            if(keyArr .contains("DATE OF BIRTH: ")) {
            }
            else {
                var  str = emptyDictionary["DBB"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("DATE OF BIRTH:")
            }
            
            
            
        }
       
        if((emptyDictionary["DBC"]) != nil) {
            passDict.updateValue(emptyDictionary["DBC"]!, forKey: "SEX: ")
            if(keyArr .contains("SEX: ")) {
            }
            else {
                if(emptyDictionary["DBC"] == "1") {
                    
                    valueArr.add("MALE")
                }
                else  {
                    valueArr.add("FEMALE")
                }
                
                keyArr.add("SEX: ")
            }
            
            
            
        }
       
        if((emptyDictionary["DBD"]) != nil) {
            passDict.updateValue(emptyDictionary["DBD"]!, forKey: "LICENSE OR ID DOCUMENT ISSUE DATE: ")
            if(keyArr .contains("LICENSE OR ID DOCUMENT ISSUE DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DBD"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("LICENSE OR ID DOCUMENT ISSUE DATE: ")
            }
        }
      
        if((emptyDictionary["DBE"]) != nil) {
            passDict.updateValue(emptyDictionary["DBE"]!, forKey:  "ISSUE TIMESTAMP: ")
            if(keyArr .contains("ISSUE TIMESTAMP: ")) {
            }
            else {
                valueArr.add(emptyDictionary["DBE"]!)
                keyArr.add("ISSUE TIMESTAMP:")
            }
        }
        
        if((emptyDictionary["DBF"]) != nil) {
            passDict.updateValue(emptyDictionary["DBF"]!, forKey: "NUMBER OF DUPLICATES: ")
            if(keyArr .contains("NUMBER OF DUPLICATES: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBF"]!)
                keyArr.add("NUMBER OF DUPLICATES: ")
            }
            
        }
       
        if((emptyDictionary["DBG"]) != nil) {
            passDict.updateValue(emptyDictionary["DBG"]!, forKey: "RMEDICAL INDICATOR CODES: ")
            if(keyArr .contains("MEDICAL INDICATOR CODES: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBG"]!)
                keyArr.add("MEDICAL INDICATOR CODES: ")
            }
            
        }
        
        if((emptyDictionary["DBH"]) != nil) {
            passDict.updateValue(emptyDictionary["DBH"]!, forKey: "ORGAN DONOR: ")
            if(keyArr .contains("ORGAN DONOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBH"]!)
                keyArr.add("ORGAN DONOR: ")
            }
        }
       
        if((emptyDictionary["DBI"]) != nil) {
            passDict.updateValue(emptyDictionary["DBI"]!, forKey: "NON-RESIDENT INDICATOR: ")
            if(keyArr .contains("NON-RESIDENT INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBI"]!)
                keyArr.add("NON-RESIDENT INDICATOR: ")
            }
            
        }
        
        if((emptyDictionary["DBJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DBJ"]!, forKey: "UNIQUE CUSTOMER IDENTIFIER: ")
            if(keyArr .contains("UNIQUE CUSTOMER IDENTIFIER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBJ"]!)
                keyArr.add("UNIQUE CUSTOMER IDENTIFIER: ")
            }
        }
        
        if((emptyDictionary["DBK"]) != nil) {
            passDict.updateValue(emptyDictionary["DBK"]!, forKey: "SOCIAL SECURITY NUMBER: ")
            if(keyArr .contains("SOCIAL SECURITY NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBK"]!)
                keyArr.add("SOCIAL SECURITY NUMBER: ")
            }
            
        }
        if((emptyDictionary["DBL"]) != nil) {
            passDict.updateValue(emptyDictionary["DBL"]!, forKey: "DATE OF BIRTH: ")
            if(keyArr .contains("DATE OF BIRTH: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBL"]!)
                keyArr.add("DATE OF BIRTH: ")
            }
       }
        
        if((emptyDictionary["DBM"]) != nil) {
            passDict.updateValue(emptyDictionary["DBM"]!, forKey: "SOCIAL SECURITY NUMBER: ")
            if(keyArr .contains("SOCIAL SECURITY NUMBER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBM"]!)
                keyArr.add("SOCIAL SECURITY NUMBER: ")
            }
        }
       
        if((emptyDictionary["DBN"]) != nil) {
            passDict.updateValue(emptyDictionary["DBN"]!, forKey: "FULL NAME: ")
            if(keyArr .contains("FULL NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBN"]!)
                keyArr.add("FULL NAME: ")
            }
        }
       
        if((emptyDictionary["DBO"]) != nil) {
            passDict.updateValue(emptyDictionary["DBO"]!, forKey: "LAST NAME: ")
            if(keyArr .contains("LAST NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBO"]!)
                keyArr.add("LAST NAME: ")
            }
        }
        
        if((emptyDictionary["DBP"]) != nil) {
            passDict.updateValue(emptyDictionary["DBP"]!, forKey: "FIRST NAME: ")
            if(keyArr .contains("FIRST NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBP"]!)
                keyArr.add("FIRST NAME: ")
            }
        }
        
        if((emptyDictionary["DBQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DBQ"]!, forKey: "MIDDLE NAME: ")
            if(keyArr .contains("MIDDLE NAME: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBQ"]!)
                keyArr.add("MIDDLE NAME: ")
            }
            
        }
        
        if((emptyDictionary["DBR"]) != nil) {
            passDict.updateValue(emptyDictionary["DBR"]!, forKey: "SUFFIX: ")
            if(keyArr .contains("SUFFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBR"]!)
                keyArr.add("SUFFIX: ")
            }
            
        }
        
        if((emptyDictionary["DBS"]) != nil) {
            passDict.updateValue(emptyDictionary["DBS"]!, forKey: "PREFIX: ")
            if(keyArr .contains("PREFIX: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DBS"]!)
                keyArr.add("PREFIX: ")
            }
            
        }
       
        if((emptyDictionary["DCA"]) != nil) {
            passDict.updateValue(emptyDictionary["DCA"]!, forKey: "VIRGINIA SPECIFIC CLASS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC CLASS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCA"]!)
                keyArr.add("VIRGINIA SPECIFIC CLASS: ")
            }
        }
        
        if((emptyDictionary["DCB"]) != nil) {
            passDict.updateValue(emptyDictionary["DCB"]!, forKey: "VIRGINIA SPECIFIC RESTRICTIONS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC RESTRICTIONS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCB"]!)
                keyArr.add("VIRGINIA SPECIFIC RESTRICTIONS: ")
            }
        }
        
        if((emptyDictionary["DCD"]) != nil) {
            passDict.updateValue(emptyDictionary["DCD"]!, forKey: "VIRGINIA SPECIFIC ENDORSEMENTS: ")
            if(keyArr .contains("VIRGINIA SPECIFIC ENDORSEMENTS: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCD"]!)
                keyArr.add("VIRGINIA SPECIFIC ENDORSEMENTS: ")
            }
        }
       
        if((emptyDictionary["DCE"]) != nil) {
            passDict.updateValue(emptyDictionary["DCE"]!, forKey: "PHYSICAL DESCRIPTION WEIGHT RANGE: ")
            if(keyArr .contains("PHYSICAL DESCRIPTION WEIGHT RANGE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCE"]!)
                keyArr.add("PHYSICAL DESCRIPTION WEIGHT RANGE: ")
            }
        }
       
        if((emptyDictionary["DCF"]) != nil) {
            passDict.updateValue(emptyDictionary["DCF"]!, forKey: "DOCUMENT DISCRIMINATOR: ")
            if(keyArr .contains("DOCUMENT DISCRIMINATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCF"]!)
                keyArr.add("DOCUMENT DISCRIMINATOR: ")
            }
            
            
        }
       
        if((emptyDictionary["DCG"]) != nil) {
            passDict.updateValue(emptyDictionary["DCG"]!, forKey: "COUNTRY TERRITORY OF ISSUANCE: ")
            if(keyArr .contains("COUNTRY TERRITORY OF ISSUANCE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCG"]!)
                keyArr.add("COUNTRY TERRITORY OF ISSUANCE: ")
            }
        }
       
        if((emptyDictionary["DCH"]) != nil) {
            passDict.updateValue(emptyDictionary["DCH"]!, forKey: "FEDERAL COMMERCIAL VEHICLE CODES: ")
            if(keyArr .contains("FEDERAL COMMERCIAL VEHICLE CODES: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCH"]!)
                keyArr.add("FEDERAL COMMERCIAL VEHICLE CODES: ")
            }
        }
       
        if((emptyDictionary["DCI"]) != nil) {
            passDict.updateValue(emptyDictionary["DCI"]!, forKey: "PLACE OF BIRTH: ")
            if(keyArr .contains("PLACE OF BIRTH: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCI"]!)
                keyArr.add("PLACE OF BIRTH: ")
            }
        }
       
        if((emptyDictionary["DCJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DCJ"]!, forKey: "AUDIT INFORMATION: ")
            if(keyArr .contains("AUDIT INFORMATION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCJ"]!)
                keyArr.add("AUDIT INFORMATION: ")
            }
        }
        
        if((emptyDictionary["DCK"]) != nil) {
            passDict.updateValue(emptyDictionary["DCK"]!, forKey: "INVENTORY CONTROL NUMBER: ")
            if(keyArr .contains("INVENTORY CONTROL NUMBER: ")) {
            }
            else {
                valueArr.add(emptyDictionary["DCK"]!)
                keyArr.add("INVENTORY CONTROL NUMBER: ")
            }
            
            
        }
        
        if((emptyDictionary["DCL"]) != nil) {
            passDict.updateValue(emptyDictionary["DCL"]!, forKey: "RACE ETHNICITY: ")
            if(keyArr .contains("RACE ETHNICITY: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCL"]!)
                keyArr.add("RACE ETHNICITY: ")
            }
            
            
        }
        
        if((emptyDictionary["DCM"]) != nil) {
            passDict.updateValue(emptyDictionary["DCM"]!, forKey: "STANDARD VEHICLE CLASSIFICATION: ")
            if(keyArr .contains("STANDARD VEHICLE CLASSIFICATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCM"]!)
                keyArr.add("STANDARD VEHICLE CLASSIFICATION: ")
            }
            
            
        }
        
        if((emptyDictionary["DCN"]) != nil) {
            passDict.updateValue(emptyDictionary["DCN"]!, forKey: "STANDARD ENDORSEMENT CODE: ")
            if(keyArr .contains("STANDARD ENDORSEMENT CODE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCN"]!)
                keyArr.add("STANDARD ENDORSEMENT CODE: ")
            }
        }
       
        if((emptyDictionary["DCO"]) != nil) {
            passDict.updateValue(emptyDictionary["DCO"]!, forKey: "STANDARD RESTRICTION CODE: ")
            if(keyArr .contains("STANDARD RESTRICTION CODE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCO"]!)
                keyArr.add("STANDARD RESTRICTION CODE: ")
            }
        }
        
        if((emptyDictionary["DCP"]) != nil) {
            passDict.updateValue(emptyDictionary["DCP"]!, forKey: "JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION:  ")
            if(keyArr .contains("JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCP"]!)
                keyArr.add("JURISDICTION SPECIFIC VEHICLE CLASSIFICATION DESCRIPTION: ")
            }
        }
        
        if((emptyDictionary["DCQ"]) != nil) {
            passDict.updateValue(emptyDictionary["DCQ"]!, forKey: "JURISDICTION-SPECIFIC: ")
            if(keyArr .contains("JURISDICTION-SPECIFIC: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCQ"]!)
                keyArr.add("JURISDICTION-SPECIFIC: ")
            }
        }
        
        if((emptyDictionary["DCR"]) != nil) {
            passDict.updateValue(emptyDictionary["DCR"]!, forKey: "JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")
            if(keyArr .contains("JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DCR"]!)
                keyArr.add("JURISDICTION SPECIFIC RESTRICTION CODE DESCRIPTION: ")
            }
        }
       
        if((emptyDictionary["DCS"]) != nil) {
            passDict.updateValue(emptyDictionary["DCS"]!, forKey: "FAMILY NAME:")
            if(keyArr .contains("FAMILY NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCS"]!)
                keyArr.add("FAMILY NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DCT"]) != nil) {
            passDict.updateValue(emptyDictionary["DCT"]!, forKey: "GIVEN NAME:")
            if(keyArr .contains("GIVEN NAME:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCT"]!)
                keyArr.add("GIVEN NAME:")
            }
            
            
        }
        
        if((emptyDictionary["DCU"]) != nil) {
            passDict.updateValue(emptyDictionary["DCU"]!, forKey: "SUFFIX:")
            if(keyArr .contains("SUFFIX:")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DCU"]!)
                keyArr.add("SUFFIX:")
            }
            
            
        }
        
        if((emptyDictionary["DDA"]) != nil) {
            passDict.updateValue(emptyDictionary["DDA"]!, forKey: "COMPLIANCE TYPE: ")
            if(keyArr .contains("COMPLIANCE TYPE: ")) {
            }
            else {
                
                
                
                valueArr.add(emptyDictionary["DDA"]!)
                keyArr.add("COMPLIANCE TYPE: ")
            }
        }
        
        if((emptyDictionary["DDB"]) != nil) {
            passDict.updateValue(emptyDictionary["DDB"]!, forKey: "CARD REVISION DATE: ")
            if(keyArr .contains("CARD REVISION DATE: ")) {
            }
            else {
                
                
                var  str = emptyDictionary["DDB"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                
                keyArr.add("CARD REVISION DATE: ")
            }
        }
        
        if((emptyDictionary["DDC"]) != nil) {
            passDict.updateValue(emptyDictionary["DDC"]!, forKey: "HAZMAT ENDORSEMENT EXPIRY DATE: ")
            if(keyArr .contains("HAZMAT ENDORSEMENT EXPIRY DATE: ")) {
            }
            else {
                
                var  str = emptyDictionary["DDC"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                
                keyArr.add("HAZMAT ENDORSEMENT EXPIRY DATE: ")
            }
        }
       
        if((emptyDictionary["DDD"]) != nil) {
            passDict.updateValue(emptyDictionary["DDD"]!, forKey: "LIMITED DURATION DOCUMENT INDICATOR: ")
            if(keyArr .contains("LIMITED DURATION DOCUMENT INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDD"]!)
                keyArr.add("LIMITED DURATION DOCUMENT INDICATOR: ")
            }
        }
        
        if((emptyDictionary["DDE"]) != nil) {
            passDict.updateValue(emptyDictionary["DDE"]!, forKey: "FAMILY NAMES TRUNCATION: ")
            if(keyArr .contains("FAMILY NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDE"]!)
                keyArr.add("FAMILY NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDF"]) != nil) {
            passDict.updateValue(emptyDictionary["DDF"]!, forKey: "FIRST NAMES TRUNCATION: ")
            if(keyArr .contains("FIRST NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDF"]!)
                keyArr.add("FIRST NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDG"]) != nil) {
            passDict.updateValue(emptyDictionary["DDG"]!, forKey: "MIDDLE NAMES TRUNCATION: ")
            if(keyArr .contains("MIDDLE NAMES TRUNCATION: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDG"]!)
                keyArr.add("MIDDLE NAMES TRUNCATION: ")
            }
        }
        
        if((emptyDictionary["DDH"]) != nil) {
            passDict.updateValue(emptyDictionary["DDH"]!, forKey: "UNDER 18 UNTIL: ")
            if(keyArr .contains("UNDER 18 UNTIL: ")) {
            }
            else {
                var  dstr = emptyDictionary["DDH"]
                let index = dstr?.index((dstr?.startIndex)!, offsetBy: 2, limitedBy: (dstr?.endIndex)!)
                
                dstr?.insert("/", at: index!)
                let index1 = dstr?.index((dstr?.startIndex)!, offsetBy: 5, limitedBy: (dstr?.endIndex)!)
                dstr?.insert("/", at: index1!)
                valueArr.add(dstr as Any)
                keyArr.add("UNDER 18 UNTIL:")
                
            }
        }
        
        if((emptyDictionary["DDI"]) != nil) {
            passDict.updateValue(emptyDictionary["DDI"]!, forKey: "UNDER 19 UNTIL: ")
            if(keyArr .contains("UNDER 19 UNTIL: ")) {
            }
            else {
                var  str = emptyDictionary["DDI"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("UNDER 19 UNTIL:")
            }
        }
        
        if((emptyDictionary["DDJ"]) != nil) {
            passDict.updateValue(emptyDictionary["DDJ"]!, forKey: "UNDER 21 UNTIL: ")
            if(keyArr .contains("UNDER 21 UNTIL: ")) {
            }
            else {
                var  str = emptyDictionary["DDJ"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
                keyArr.add("UNDER 21 UNTIL: ")
            }
        }
       
        if((emptyDictionary["DDK"]) != nil) {
            passDict.updateValue(emptyDictionary["DDK"]!, forKey: "ORGAN DONOR INDICATOR: ")
            if(keyArr .contains("ORGAN DONOR INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDK"]!)
                keyArr.add("ORGAN DONOR INDICATOR: ")
            }
        }
        
        if((emptyDictionary["DDL"]) != nil) {
            passDict.updateValue(emptyDictionary["DDL"]!, forKey: "VETERAN INDICATOR: ")
            if(keyArr .contains("VETERAN INDICATOR: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["DDL"]!)
                keyArr.add("VETERAN INDICATOR: ")
            }
            
            
        }
        
        if((emptyDictionary["PAA"]) != nil) {
            passDict.updateValue(emptyDictionary["PAA"]!, forKey: "PERMIT CLASSIFICATION CODE: ")
            if(keyArr .contains("PERMIT CLASSIFICATION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAA"]!)
                keyArr.add("PERMIT CLASSIFICATION CODE: ")
            }
            
            
        }
       
        if((emptyDictionary["PAB"]) != nil) {
            passDict.updateValue(emptyDictionary["PAB"]!, forKey: "PERMIT EXPIRATION DATE: ")
            if(keyArr .contains("PERMIT EXPIRATION DATE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAB"]!)
                keyArr.add("PERMIT EXPIRATION DATE: ")
            }
            
            
        }
        
        if((emptyDictionary["PAC"]) != nil) {
            passDict.updateValue(emptyDictionary["PAC"]!, forKey: "PERMIT IDENTIFIER: ")
            if(keyArr .contains("PERMIT IDENTIFIER: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAC"]!)
                keyArr.add("PERMIT IDENTIFIER: ")
            }
        }
        
        if((emptyDictionary["PAD"]) != nil) {
            passDict.updateValue(emptyDictionary["PAD"]!, forKey: "PERMIT ISSUE DATE: ")
            if(keyArr .contains("PERMIT ISSUE DATE: ")) {
            }
            else {
                var  str = emptyDictionary["PAD"]
                let index = str?.index((str?.startIndex)!, offsetBy: 2, limitedBy: (str?.endIndex)!)
                
                str?.insert("/", at: index!)
                let index1 = str?.index((str?.startIndex)!, offsetBy: 5, limitedBy: (str?.endIndex)!)
                str?.insert("/", at: index1!)
                
                valueArr.add(str as Any)
               
                keyArr.add("PERMIT ISSUE DATE: ")
            }
        }
        
        if((emptyDictionary["PAE"]) != nil) {
            passDict.updateValue(emptyDictionary["PAE"]!, forKey: "PERMIT RESTRICTION CODE: ")
            if(keyArr .contains("PERMIT RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAE"]!)
                keyArr.add("PERMIT RESTRICTION CODE: ")
            }
            
            
        }
        
        if((emptyDictionary["PAF"]) != nil) {
            passDict.updateValue(emptyDictionary["PAF"]!, forKey: "PERMIT ENDORSEMENT CODE: ")
            if(keyArr .contains("PERMIT ENDORSEMENT CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["PAF"]!)
                keyArr.add("PERMIT ENDORSEMENT CODE: ")
            }
            
            
        }
       
        if((emptyDictionary["ZVA"]) != nil) {
            passDict.updateValue(emptyDictionary["ZVA"]!, forKey: "COURT RESTRICTION CODE: ")
            if(keyArr .contains("COURT RESTRICTION CODE: ")) {
            }
            else {
                
                valueArr.add(emptyDictionary["ZVA"]!)
                keyArr.add("COURT RESTRICTION CODE: ")
            }
        }
        
        if(emptyDictionary["DAC"] != nil || emptyDictionary["DAD"] != nil || emptyDictionary["DCS"] != nil || emptyDictionary["DAG"] != nil ||  emptyDictionary["DAI"] != nil || emptyDictionary["DAJ"] != nil || emptyDictionary["DAK"] != nil || emptyDictionary["DBA"] != nil) {
            return true
        }
        else {
            return false
        }
        
    }
    
    func failed() {
        
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }
    
    func found(code: String)
    {
        
        self.mainV.removeAlert()
        self.mainV.showCodeInfoV(text: code)
        self.mainV.codeInfoV!.addGestureRecognizer(tapToDismiss)
    }
    
    
    @objc func toggleFlash()
    {
        
        if !torchOn {
            
            toggleTorch(on: true)
            torchOn = true
            
        } else {
            
            toggleTorch(on: false)
            torchOn = false
        }
    }
    
    func flipAnimation() {
        DispatchQueue.main.async {
            self.imageViewFilp.isHidden = false
            UIView.animate(withDuration: 1.5, animations: {
                UIView.setAnimationTransition(.flipFromLeft, for: self.imageViewFilp, cache: true)
                AudioServicesPlaySystemSound(1315)
            }) { _ in
                self.imageViewFilp.isHidden = true
            }
        }
    }
    
    @objc func enableScan()
    {
        
        scanEnabled = true
        scanTimer?.invalidate()
    }
    
    @objc func dismissAlert()
    {
        mainV.removeAlert()
    }
    
   
    func processedImage(_ image: UIImage!) {
//        imageView.image = image
    }
    
    func recognizeFailed(_ message: String!) {
    }
    func recognizeSucceedBarcode(_ message: String!, back BackSideImage: UIImage!, frontImage FrontImage: UIImage!, face FaceImage: UIImage!) {
        
        if FrontImage != nil {
            imgViewFront = FrontImage
        }
        if BackSideImage != nil {
            imgViewBack = BackSideImage
        }
        if FaceImage != nil {
            photoImage1 = FaceImage
        }
        if(isBarcodeEnabled){
        let isPDF = self.decodework(type: message)
        if(isPDF && isResultShow == false)
        {
            isResultShow = true
            mainV.removeAlert()
            self.accuraCameraWrapper?.stopCamera()
            AudioServicesPlaySystemSound(1315)
            let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
            let placeVC = codeStory.instantiateViewController(withIdentifier: "Resultpdf417ViewController") as? Resultpdf417ViewController
            placeVC?.keyArr = keyArr as! [String]
            placeVC?.valueArr = valueArr as! [String]
            placeVC?.passStr = message
            placeVC?.imgViewFront = FrontImage
            placeVC?.AllBarcode = false
            placeVC?.isCheckIDMRZ = true
            if let aVC = placeVC {
                navigationController?.pushViewController(aVC, animated: true)
            }
        }
        else{
            
            isResultShow = true
            mainV.removeAlert()
            self.accuraCameraWrapper?.stopCamera()
            AudioServicesPlaySystemSound(1315)
            let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
            let placeVC = codeStory.instantiateViewController(withIdentifier: "Resultpdf417ViewController") as? Resultpdf417ViewController
            placeVC?.BarcodeData = message
            placeVC?.imgViewFront = FrontImage
            placeVC?.AllBarcode = true
            if let aVC = placeVC {
                navigationController?.pushViewController(aVC, animated: true)
            }
        }
    }
        else{
            if(message != "") {
                barcodeData = message
            }
            if(BackSideImage == nil) {
                self.accuraCameraWrapper?.cardSide(.BACK_CARD_SCAN)
                self.flipAnimation()
                
            } else if (FrontImage == nil) {
                self.accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
                self.flipAnimation()
            }else {
                let isPDF = self.decodework(type: barcodeData)
                if(isPDF && isResultShow == false)
                {
                    isResultShow = true
                    mainV.removeAlert()
    //                self.accuraCameraWrapper?.stopCamera()
    //                AudioServicesPlaySystemSound(1315)
                    AudioServicesPlaySystemSound(1315)
                    let codeStory = UIStoryboard(name: "CodeScanVC", bundle: nil)
                    let placeVC = codeStory.instantiateViewController(withIdentifier: "Resultpdf417ViewController") as? Resultpdf417ViewController
                    placeVC?.keyArr = keyArr as! [String]
                    placeVC?.valueArr = valueArr as! [String]
                    passStr = barcodeData
                    placeVC?.passStr = passStr
                    
                    placeVC?.photoImage = photoImage1
                    placeVC?.imgViewFront = imgViewFront
                    imgViewBack = BackSideImage
                    placeVC?.imgViewBack = imgViewBack
                    placeVC?.isCheckIDMRZ = true
                    if let aVC = placeVC {
                        navigationController?.pushViewController(aVC, animated: true)
                    }
                }
            }
            
        }
    }
    
    func isBothSideAvailable(_ isBothAvailable: Bool) {
        if isBothAvailable {
            self.accuraCameraWrapper?.cardSide(.FRONT_CARD_SCAN)
        }
    }
    
    func recognizeSucceed(_ scanedInfo: NSMutableDictionary!, recType: RecType, bRecDone: Bool, bFaceReplace: Bool, bMrzFirst: Bool, photoImage: UIImage!, docFrontImage: UIImage!, docbackImage: UIImage!) {
    }
    
    func reco_titleMessage(_ messageCode: Int32) {
        switch messageCode {
        case SCAN_TITLE_MRZ_PDF417_FRONT:
            labelMsg.text = "Scan Front Side of Document"
            break
        case SCAN_TITLE_MRZ_PDF417_BACK:
            labelMsg.text = "Scan Back Side of Document"
            break
        case SCAN_TITLE_BARCODE:
            labelMsg.text = "Scan Barcode"
            break
        default:
            break
            
        }
    }
    
    func matchedItem(_ image: UIImage!, isCardSide1 cs: Bool, isBack b: Bool, isFront f: Bool, imagePhoto imgp: UIImage!, imageResult: UIImage!) {
          // print("Success")
     }
    
    func matchedItem(_ setDataFront: NSMutableDictionary!, andmrzDatasacn mrzDataSacn: NSMutableDictionary!, setDataBack: NSMutableDictionary!, setFaceData: NSMutableDictionary!, setSecurityData: NSMutableDictionary!, setFaceBackData: NSMutableDictionary!) {
        // print("Success")
    }
    
    func matchedItem(_ setDataFrontKey: NSMutableArray!, andsetDataFrontvalue setDataFrontvalue: NSMutableArray!, andmrzDatasacn mrzDataSacn: NSMutableDictionary!, setDataBackKey: NSMutableArray!, setDataBackValue: NSMutableArray!, setFaceData: NSMutableDictionary!, setSecurityData: NSMutableDictionary!, setFaceBackData: NSMutableDictionary!, setPhotoImage: UIImage!) {
         // print("Success")
    }
    func resultData(_ resultmodel: ResultModel!) {
        
    }
    func dlPlateNumber(_ plateNumber: String!, andImageNumberPlate imageNumberPlate: UIImage!) {
        print(plateNumber)
    }
    
    func screenSound() {
        
    }
    
    func capture() {
        let stillImageConnection = stillImageOutput.connection(with: AVMediaType.video)
        stillImageConnection!.videoOrientation = .portrait
        stillImageConnection!.videoScaleAndCropFactor = 1.0
        stillImageOutput.captureStillImageAsynchronously(from: stillImageConnection!, completionHandler: { (imageDataSampleBuffer, error) in
                            if (error != nil) {
                                // print("There are some error in capturing image")
                            } else {
                                let jpegData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageDataSampleBuffer!)
                                var resultImage = UIImage(data: jpegData!)!
                                var flippedImage: UIImage? = nil
                                if let CGImage = resultImage.cgImage {
                                    flippedImage = UIImage(cgImage: CGImage, scale: resultImage.scale, orientation: .right)
                                }
                                resultImage = flippedImage!
                                let ratio = CGFloat(resultImage.size.width) / resultImage.size.height
                                resultImage = self.compressimage(with: resultImage, convertTo: CGSize(width: 600 * ratio, height: 600))!
                                self.imgViewBack = self.resizeImage(image: resultImage, targetSize: self.viewScan.frame)
                            }
                        })
    }
    
    
    func compressimage(with image: UIImage?, convertTo size: CGSize) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        image?.draw(in: CGRect(x: 0, y: 0, width: size.width, height: size.height))
        let destImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return destImage
    }
    
    func resizeImage(image: UIImage, targetSize: CGRect) -> UIImage {
        // print(targetSize)
        let contextImage: UIImage = UIImage(cgImage: image.cgImage!)
        let wX = targetSize.size.width * 0.1;
        let wY = targetSize.size.height * 0.1;
        var newX = targetSize.origin.x - wX;
        var newY = targetSize.origin.y - wY;
        var newWidth = (targetSize.size.width + (wX * 2));
        var newHeight = (targetSize.size.height + (wY * 2));
        
        if (newX < 0) {
            newWidth = newWidth + (newX * 2);
            newX = 0;
        }
        if (newY < 0) {
            newHeight = newHeight + (newY * 2);
            newY = 0;
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
        } else {
            msg = message;
        }
        lblBottamMsg.text = msg
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
	return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
    

