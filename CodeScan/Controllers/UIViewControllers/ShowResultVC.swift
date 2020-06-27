
import UIKit
import ZoomAuthenticationHybrid
import SVProgressHUD
import Alamofire
import AccuraOCR
import FaceMatchSDK

//Define Global Key
let KEY_TITLE           =  "KEY_TITLE"
let KEY_VALUE           =  "KEY_VALUE"
let KEY_FACE_IMAGE      =  "KEY_FACE_IMAGE"
let KEY_FACE_IMAGE2     =  "KEY_FACE_IMAGE2"
let KEY_DOC1_IMAGE      =  "KEY_DOC1_IMAGE"
let KEY_DOC2_IMAGE      =  "KEY_DOC2_IMAGE"
let KEY_TITLE_FACE_MATCH           =  "KEY_TITLE_FACE_MATCH"
let KEY_VALUE_FACE_MATCH           =  "KEY_VALUE_FACE_MATCH"
let KEY_TITLE_FACE_MATCH1          =  "KEY_TITLE_FACE_MATCH1"
let KEY_VALUE_FACE_MATCH1          =  "KEY_VALUE_FACE_MATCH1"
var MY_ZOOM_DEVELOPER_APP_TOKEN1: String  = "dUfNhktz2Tcl32pGgbPTZ57QujOQBluh"

struct Objects {
    var name : String!
    var objects : String!
    
    init(sName: String, sObjects: String) {
        self.name = sName
        self.objects = sObjects
    }
    
}

class ShowResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate,ZoomVerificationDelegate,CustomAFNetWorkingDelegate {
    //MARK:- Outlet
    @IBOutlet weak var img_height: NSLayoutConstraint!
    @IBOutlet weak var lblLinestitle: UILabel!
    @IBOutlet weak var tblResult: UITableView!
    @IBOutlet weak var imgPhoto: UIImageView!
    
    
    @IBOutlet weak var viewTable: UIView!
    
    @IBOutlet weak var viewStatusBar: UIView!
    
    @IBOutlet weak var viewNavigationBar: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    //MARK:- Variable
    let obj_AppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var uniqStr = ""
    var mrz_val = ""
    
    var imgDoc: UIImage?
    var retval: Int = 0
    var lines = ""
    var success = false
    var isFLpershow = false
    var passportType = ""
    var country = ""
    var surName = ""
    var givenNames = ""
    var passportNumber = ""
    var passportNumberChecksum = ""
    var nationality = ""
    var birth = ""
    var birthChecksum = ""
    var sex = ""
    var expirationDate = ""
    var otherID = ""
    var expirationDateChecksum = ""
    var personalNumber = ""
    var personalNumberChecksum = ""
    var secondRowChecksum = ""
    var placeOfBirth = ""
    var placeOfIssue = ""
    var issuedate = ""
    var departmentNumber = ""

    var fontImgRotation = ""
    var backImgRotation = ""
    
    var photoImage: UIImage?
    var documentImage: UIImage?
    
    var isFirstTime:Bool = false
    var arrDocumentData: [[String:AnyObject]] = [[String:AnyObject]]()
    var dictDataShow: [String:AnyObject] = [String:AnyObject]()
    var appDocumentImage: [UIImage] = [UIImage]()
    var pageType: NAV_PAGETYPE = .Default
    
    var matchImage: UIImage?
    var liveImage: UIImage?
    
    let picker: UIImagePickerController = UIImagePickerController()
    var stLivenessResult: String = ""
    var faceRegion: NSFaceRegion?
    
    var scannedData: NSMutableDictionary = [:]
    
    var dictFaceData : NSMutableDictionary = [:]
    var dictSecurityData : NSMutableDictionary = [:]
    var dictFaceBackData : NSMutableDictionary = [:]
    var stFace : String?
    var imgViewCountryCard : UIImage?
    var imgSignature : UIImage?
    var imgViewFront : UIImage?
    var imgViewBack : UIImage?
    var arrSecurity = [String]()
    var arrSecurityTrueFalse = [String]()
    var dictScanningData:NSDictionary = NSDictionary()
    var imagePhoto : UIImage?
    var faceImage: UIImage?
    var imgCamaraFace: UIImage?
    var frontDataIndex: Int?
    var backDataIndex: Int?
    var securtiyDataIndex: Int?
    var arrFaceLivenessScor  = [Objects]()
    var arrFrontMail: [[String:AnyObject]] = [[String:AnyObject]]()
    var arrBackMail: [[String:AnyObject]] = [[String:AnyObject]]()
    var stCountryCardName: String?
    var imageCountryCard: UIImage?
    var isChecktrue: Bool?
    var faceScoreData: String?
    var isCheckLiveNess: Bool?
    var isBackSide: Bool?
    var arrDataForntKey: [String] = []
    var arrDataForntValue: [String] = []
    var arrDataBackKey: [String] = []
    var arrDataBackValue: [String] = []
    var arrDataForntValue1: [String] = []
    var arrDataBackValue1: [String] = []
    //MARK:- UIViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        isCheckLiveNess = false
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        
        isFirstTime = true
        
         self.initializeZoom()
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
        if pageType == .ScanOCR{
            dictScanningData = NSDictionary(dictionary: scannedData)
            if arrDataForntKey.count != 0 && self.arrDataBackKey.count != 0{
                setFaceImage()
                for (index,dataKey) in arrDataForntKey.enumerated(){
                    if dataKey == "MRZ"{
                        arrDataForntKey.remove(at: index)
                        arrDataForntValue.remove(at: index)
                    }
                }
                for (index,dataKey) in arrDataBackKey.enumerated(){
                    if dataKey == "MRZ"{
                        arrDataBackKey.remove(at: index)
                        arrDataBackValue.remove(at: index)
                    }
                }
                for(key,value) in dictFaceData{
                    if key as? String != "Face"{
                        arrDataForntKey.append(key as! String)
                        arrDataForntValue.append(value as! String)
                    }
                }
                for(key,value) in dictFaceBackData{
                  if key as? String != "Face"{
                    arrDataBackKey.append(key as! String)
                    arrDataBackValue.append(value as! String)
                    }
                }
                for(key,value) in dictSecurityData{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrSecurity.append(ansData.objects)
                }
                scanMRZData()
            }else{
                let arrFinalResult1 = [dictFaceData]
                setFaceImage()
                for (index,dataKey) in arrDataForntKey.enumerated(){
                    if dataKey == "MRZ"{
                        arrDataForntKey.remove(at: index)
                        arrDataForntValue.remove(at: index)
                    }
                }
                for(key,value) in dictFaceData{
                    if key as? String != "Face"{
                    arrDataForntKey.append(key as! String)
                    arrDataForntValue.append(value as! String)
                    }
                }
                for(key,value) in dictSecurityData{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrSecurity.append(ansData.objects)
                }
                scanMRZData()
            }
        }else{
//                // print(dictScanningData)
                dictScanningData = NSDictionary(dictionary: scannedData)

                if let stFontRotaion:String = dictScanningData["fontImageRotation"] as? String{
                    fontImgRotation = stFontRotaion
                }
                if let stBackRotaion:String = dictScanningData["backImageRotation"] as? String{
                    backImgRotation = stBackRotaion
                }
                scanMRZData()
                if let image_photoImage: Data = dictScanningData["photoImage"] as? Data {
                    self.photoImage = UIImage(data: image_photoImage)
                    self.faceRegion = nil;
                    if (self.photoImage != nil){
                        self.faceRegion = EngineWrapper.detectSourceFaces(photoImage) //Identify face in Document scanning image
                    }
                }
                if let image_documentFontImage: Data = dictScanningData["docfrontImage"] as? Data  {
                    appDocumentImage.append(UIImage(data: image_documentFontImage)!)
                }
                
                if let image_documentImage: Data = dictScanningData["documentImage"] as? Data  {
                    appDocumentImage.append(UIImage(data: image_documentImage)!)
                }
                imgDoc = documentImage
        }
        
        //**************************************************************//
        
        //Register Table cell
        self.tblResult.register(UINib.init(nibName: "UserImgTableCell", bundle: nil), forCellReuseIdentifier: "UserImgTableCell")
        
        self.tblResult.register(UINib.init(nibName: "ResultTableCell", bundle: nil), forCellReuseIdentifier: "ResultTableCell")
        
        self.tblResult.register(UINib.init(nibName: "DocumentTableCell", bundle: nil), forCellReuseIdentifier: "DocumentTableCell")
        
        self.tblResult.register(UINib.init(nibName: "FaceMatchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "FaceMatchResultTableViewCell")
        
        self.tblResult.register(UINib.init(nibName: "DocumantVarifyCell", bundle: nil), forCellReuseIdentifier: "DocumantVarifyCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set TableView Height
        self.tblResult.estimatedRowHeight = 60.0
        self.tblResult.rowHeight = UITableView.automaticDimension
        if pageType != .ScanOCR{
            if isFirstTime{
                isFirstTime = false
                self.setData() // this function Called set data in tableView
            }
        }else{
            if isFirstTime{
                isFirstTime = false
                if dictScanningData.count != 0{
                    setOnlyMRZData()
                }
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    
        // ZoomScanning SDK Reset
        Zoom.sdk.preload()
    }
    
    //MARK:- Custom Methods
    func scanMRZData(){
        if let strline: String =  dictScanningData["lines"] as? String {
            self.lines = strline
        }
        if let strpassportType: String =  dictScanningData["passportType"] as? String  {
            self.passportType = strpassportType
        }
        if let stRetval: String = dictScanningData["retval"] as? String   {
            self.retval = Int(stRetval) ?? 0
        }
        if let strcountry: String =  dictScanningData["country"] as? String {
            self.country = strcountry
        }
        if let strsurName: String = dictScanningData["surName"] as? String {
            self.surName = strsurName
        }
        if let strgivenNames: String =  dictScanningData["givenNames"] as? String  {
            self.givenNames = strgivenNames
        }
        if let strpassportNumber: String = dictScanningData["passportNumber"] as? String   {
            self.passportNumber = strpassportNumber
        }
        if let strpassportType: String =  dictScanningData["passportType"] as? String {
            self.passportType = strpassportType
        }
        
        if let strpassportNumberChecksum: String = dictScanningData["passportNumberChecksum"] as? String {
            self.passportNumberChecksum = strpassportNumberChecksum
        }
        if let strnationality: String =  dictScanningData["nationality"] as? String  {
            self.nationality = strnationality
        }
        if let strbirth: String = dictScanningData["birth"] as? String  {
            self.birth = strbirth
        }
        if let strbirthChecksum: String = dictScanningData["BirthChecksum"] as? String{
            self.birthChecksum = strbirthChecksum
        }
        if let strsex: String =  dictScanningData["sex"] as? String {
            self.sex = strsex
        }
        if let strexpirationDate: String = dictScanningData["expirationDate"] as? String {
            self.expirationDate = strexpirationDate
        }
        
        if let strexpirationDateChecksum: String = dictScanningData["expirationDateChecksum"] as? String  {
            self.expirationDateChecksum = strexpirationDateChecksum
        }
        if let strpersonalNumber: String = dictScanningData["personalNumber"] as? String{
            self.personalNumber = strpersonalNumber
        }
        if let strpersonalNumberChecksum: String = dictScanningData["personalNumberChecksum"] as? String {
            self.personalNumberChecksum = strpersonalNumberChecksum
        }
        if let strsecondRowChecksum: String = dictScanningData["secondRowChecksum"] as? String {
            self.secondRowChecksum = strsecondRowChecksum
        }
        if let strplaceOfBirth: String = dictScanningData["placeOfBirth"] as? String{
            self.placeOfBirth = strplaceOfBirth
        }
        if let strplaceOfIssue: String = dictScanningData["placeOfIssue"] as? String {
            self.placeOfIssue = strplaceOfIssue
        }
        
        if let strissuedate: String = dictScanningData["issuedate"] as? String {
            self.issuedate = strissuedate
        }
        
        if let strdepartmentNumber: String = dictScanningData["departmentNumber"] as? String {
            self.departmentNumber = strdepartmentNumber
        }
    }
    
    func setOnlyMRZData(){
        for index in 0..<18{
            var dict: [String:AnyObject] = [String:AnyObject]()
            switch index {
            case 0:
                dict = [KEY_VALUE: lines] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 1:
                var firstLetter: String = ""
                var strFstLetter: String = ""
                let strPassportType = passportType.lowercased()
                if !lines.isEmpty{
                    firstLetter = (lines as? NSString)?.substring(to: 1) ?? ""
                    strFstLetter = firstLetter.lowercased()
                }
                var dType: String = ""
                if strPassportType == "v" || strFstLetter == "v" {
                    dType = "VISA"
                }
                else if passportType == "p" || strFstLetter == "p" {
                    dType = "PASSPORT"
                }
                else if passportType == "d" || strFstLetter == "p" {
                    dType = "DRIVING LICENCE"
                }
                else {
                    if (strFstLetter == "d") {
                        dType = "DRIVING LICENCE"
                    } else {
                        dType = "ID"
                    }
                }
                dict = [KEY_VALUE: dType,KEY_TITLE:"Document"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 2:
                dict = [KEY_VALUE: surName,KEY_TITLE:"Last Name"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 3:
                dict = [KEY_VALUE: givenNames,KEY_TITLE:"First Name"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 4:
                let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"Document No."] as [String : AnyObject]
                arrDocumentData.append(dict)
            case 5:
                dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"Document Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
            case 6:
                    dict = [KEY_VALUE: country,KEY_TITLE:"Country"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
            case 7:
                dict = [KEY_VALUE: nationality,KEY_TITLE:"Nationality"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
              case 8:
                var stSex: String = ""
                if sex == "F" {
                    stSex = "FEMALE";
                }
                if sex == "M" {
                    stSex = "MALE";
                }
                dict = [KEY_VALUE: stSex,KEY_TITLE:"Sex"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
            case 9:
                dict = [KEY_VALUE: date(toFormatedDate: birth),KEY_TITLE:"Date of Birth"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 10:
                dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"Birth Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            
            case 11:
                dict = [KEY_VALUE: date(toFormatedDate: expirationDate),KEY_TITLE:"Date of Expiry"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 12:
                dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"Expiration Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 13:
                dict = [KEY_VALUE: personalNumber,KEY_TITLE:"Other ID"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 14:
                dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"Other ID Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 15:
                dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"Second Row Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
            case 16:
                if issuedate != ""{
                dict = [KEY_VALUE: issuedate,KEY_TITLE:"Issue Date"] as [String : AnyObject]
                arrDocumentData.append(dict)
                }
                break
            case 17:
               if departmentNumber != ""{
                dict = [KEY_VALUE: departmentNumber,KEY_TITLE:"Department No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                }
                break
            default:
                break
            }
            
        }
        
    }
    
    /**
     * This method use set scanning data
     *
     */
    func setData(){
        //Set tableView Data
        for index in 0..<20 + appDocumentImage.count{
            var dict: [String:AnyObject] = [String:AnyObject]()
            switch index {
            case 0:
                dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 1:
                dict = [KEY_VALUE_FACE_MATCH: "0 %",KEY_TITLE_FACE_MATCH:"0 %"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
            case 2:
                dict = [KEY_VALUE: lines] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 3:
                var firstLetter: String = ""
                var strFstLetter: String = ""
                let strPassportType = passportType.lowercased()
                
                if !lines.isEmpty{
                    firstLetter = (lines as? NSString)?.substring(to: 1) ?? ""
                    strFstLetter = firstLetter.lowercased()
                }
                
                var dType: String = ""
                if strPassportType == "v" || strFstLetter == "v" {
                    dType = "VISA"
                }
                else if passportType == "p" || strFstLetter == "p" {
                    dType = "PASSPORT"
                }
                else if passportType == "d" || strFstLetter == "p" {
                    dType = "DRIVING LICENCE"
                }
                else {
                    if (strFstLetter == "d") {
                        dType = "DRIVING LICENCE"
                    } else {
                        dType = "ID"
                    }
                }
                dict = [KEY_VALUE: dType,KEY_TITLE:"Document"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 4:
                dict = [KEY_VALUE: surName,KEY_TITLE:"Last Name"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 5:
                dict = [KEY_VALUE: givenNames,KEY_TITLE:"First Name"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 6:
                let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"Document No."] as [String : AnyObject]
                arrDocumentData.append(dict)
            case 7:
                dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"Document Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 8:
                dict = [KEY_VALUE: country,KEY_TITLE:"Country"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 9:
                dict = [KEY_VALUE: nationality,KEY_TITLE:"Nationality"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 10:
                var stSex: String = ""
                if sex == "F" {
                    stSex = "FEMALE";
                }
                if sex == "M" {
                    stSex = "MALE";
                }
                dict = [KEY_VALUE: stSex,KEY_TITLE:"Sex"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 11:
                dict = [KEY_VALUE: date(toFormatedDate: birth),KEY_TITLE:"Date of Birth"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 12:
                dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"Birth Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 13:
                dict = [KEY_VALUE: date(toFormatedDate: expirationDate),KEY_TITLE:"Date of Expiry"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 14:
                dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"Expiration Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 15:
                dict = [KEY_VALUE: personalNumber,KEY_TITLE:"Other ID"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 16:
                dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"Other ID Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 17:
                dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"Second Row Check No."] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 18:
                if issuedate != ""{
                    dict = [KEY_VALUE: issuedate,KEY_TITLE:"Issue Date"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 19:
                if departmentNumber != ""{
                    dict = [KEY_VALUE: departmentNumber,KEY_TITLE:"Department No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 20:
                dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 21:
                dict = [KEY_DOC2_IMAGE: appDocumentImage.count == 2 ? appDocumentImage[1] : nil] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            default:
                break
            }
        }
    }
    
    /**
     * This method use lunchZoom setup
     * Make sure initialization was successful before launcing ZoOm
     *
     */
    
    func launchZoomToVerifyLivenessAndRetrieveFacemap() {
        // Make sure initialization was successful before launcing ZoOm
        var reason: String = ""
        let status:ZoomSDKStatus = Zoom.sdk.getStatus()
        switch(status) {
        case .neverInitialized:                   
            reason = "Initialize was never attempted";
            break;
        case .initialized:
            reason = "The app token provided was verified";
            break;
        case .networkIssues:
            reason = "The app token could not be verified";
            break;
        case .invalidToken:
            reason = "The app token provided was invalid";
            break;
        case .versionDeprecated:
            reason = "The current version of the SDK is deprecated";
            break;
        case .offlineSessionsExceeded:
            reason = "The app token needs to be verified again";
            break;
        case .unknownError:
            reason = "An unknown error occurred";
            break;
        default:
            break;
        }
        
        if(status != .initialized) {
            let alert = UIAlertController(title: "Get Ready To ZoOm.", message: "ZoOm is not ready to be launched. \nReason: \(reason)", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
            return;
        }
        
        let vc = Zoom.sdk.createVerificationVC(delegate: self)//Zoom SDK set Delegate
        
        let colors: [AnyObject] = [UIColor(red: 0.04, green: 0.71, blue: 0.64, alpha: 1).cgColor,UIColor(red: 0.07, green: 0.57, blue: 0.76, alpha: 1).cgColor]
        self.configureGradientBackground(arrcolors: colors, inLayer: vc.view.layer)
        
        // For proper modal presentation of ZoOm interface, modal presentation style must be set as .overFullScreen or .overCurrentContext.
        // UIModalPresentationStyles.formsheet is not currently supported, as it impedes intended ZoOm functionality and user experience.
        // Example of presenting ZoOm using cross dissolve effect
        
        vc.modalTransitionStyle = .crossDissolve
        
        // When presenting the ZoOm interface over your own application, you can keep your application showing in the background by using this presentation style
        
        vc.modalPresentationStyle =  .overCurrentContext
        
        // Refer to ZoomFrameCustomization for further presentation/interface customization.
        self.present(vc, animated: true, completion: nil)
    }
    
    func initializeZoom(){
        //Initialize the ZoOm SDK using your app token
        Zoom.sdk.initialize(appToken: MY_ZOOM_DEVELOPER_APP_TOKEN1) { (validationResult) in
            if validationResult {
                // print("AppToken validated successfully")
            } else {
                if Zoom.sdk.getStatus() != .initialized {
                    self.showInitFailedDialog()
                }
            }
        }
        
        // Configures the look and feel of Zoom
        let currentCustomization = ZoomCustomization()
        currentCustomization.showPreEnrollmentScreen = false; //show Pre-Enrollment screens
        
        // Sample UI Customization: vertically center the ZoOm frame within the device's display
        centerZoomFrameCustomization(currentCustomization);
        
        // Apply the customization changes
        Zoom.sdk.setCustomization(currentCustomization)
        Zoom.sdk.auditTrailType = .height640 //Sets the type of audit trail images to be collected
    }
    
    func showInitFailedDialog(){
        let alert = UIAlertController(title: "Initialization Failed", message: "Please check that you have set your ZoOm app token to the MY_ZOOM_DEVELOPER_APP_TOKEN variable in this file.  To retrieve your app token, visit https://dev.zoomlogin.com/zoomsdk/#/account.", preferredStyle: UIAlertController.Style.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
    /**
     * This method use set custom Frame lunchZoom
     *
     */
    func centerZoomFrameCustomization(_ currentCustomization:ZoomCustomization){
        let screenHeight = UIScreen.main.fixedCoordinateSpace.bounds.size.height
        var frameHeight = CGFloat(screenHeight) * CGFloat(currentCustomization.frameCustomization.sizeRatio)
        
        // Detect iPhone X and iPad displays
        if(UIScreen.main.fixedCoordinateSpace.bounds.size.height >= 812) {
            frameHeight = UIScreen.main.fixedCoordinateSpace.bounds.size.width * (16.0/9.0) * CGFloat(currentCustomization.frameCustomization.sizeRatio);
        }
        
        let topMarginToCenterFrame = (screenHeight - frameHeight)/2.0
        currentCustomization.frameCustomization.topMargin = Double(topMarginToCenterFrame);
    }
    
    func configureGradientBackground(arrcolors:[AnyObject],inLayer:CALayer){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = arrcolors
        gradient.startPoint =  CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        inLayer.addSublayer(gradient)
    }
    
    //Remove Same Value
    func removeOldValue(_ removeKey: String){
        var removeIndex: String = ""
        if pageType != .ScanOCR{
            for (index,dict) in arrDocumentData.enumerated(){
                if dict[KEY_TITLE_FACE_MATCH] != nil{
                    if dict[KEY_TITLE_FACE_MATCH] as! String == removeKey{
                        removeIndex = "\(index)"
                    }
                }
            }
            if !removeIndex.isEmpty{ arrDocumentData.remove(at: Int(removeIndex)!)}
        }else{
            for (index,faceKey) in arrFaceLivenessScor.enumerated(){
                if faceKey.name == removeKey{
                    removeIndex = "\(index)"
                }
            }
            if !removeIndex.isEmpty{ arrFaceLivenessScor.remove(at: Int(removeIndex)!)}
        }
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

    
    
    
    //MARK:- Image Rotation
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
    
    //MARK: UIButton Method Action
    @IBAction func onCancelAction(_ sender: Any) {
        if pageType == .ScanOCR{
            removeAllData()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- Other Method
    func removeAllData(){
        dictFaceData.removeAllObjects()
        dictSecurityData.removeAllObjects()
        dictFaceBackData.removeAllObjects()
        arrSecurity.removeAll()
        arrDataForntKey.removeAll()
        arrDataBackKey.removeAll()
        arrDataForntValue.removeAll()
        arrDataBackValue.removeAll()
        arrDataForntValue1.removeAll()
        arrDataBackValue1.removeAll()
        faceScoreData = ""
        stFace = nil
        imagePhoto = nil
        imgViewBack = nil
        imgViewFront = nil
        imgCamaraFace = nil
        faceImage = nil
    }
    
    //MARK: - UITableView Delegate and Datasource Method
    func numberOfSections(in tableView: UITableView) -> Int {
        if pageType == .ScanOCR{
            return 7
        }else{
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageType == .ScanOCR{
            switch section {
            case 0:
                return 1
            case 1:
                if arrFaceLivenessScor.isEmpty{
                    return 1
                }else{
                    return arrFaceLivenessScor.count
                }
                
            case 2:
                return 1
            case 3:
                return arrDataForntKey.count
            case 4:
                return arrDataBackKey.count
            case 5:
                return arrDocumentData.count
            case 6:
                if imgViewBack == nil{
                    return 1
                }else{
                    return 2
                }
            default:
                return 0
            }
        }else{
            return  self.arrDocumentData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if pageType == .ScanOCR{
            if indexPath.section == 0{
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserImgTableCell") as! UserImgTableCell
                cell.selectionStyle = .none
                cell.view2.isHidden = true
                cell.User_img2.isHidden = true
                cell.user_img.image = faceImage
                
                if imgCamaraFace != nil{
                    cell.view2.isHidden = false
                    cell.User_img2.isHidden = false
                    cell.User_img2.image = imgCamaraFace
                }
                
                return cell
            }else if indexPath.section == 1{
                
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
                
                
                if !arrFaceLivenessScor.isEmpty{
                    let  dictResultData = arrFaceLivenessScor[indexPath.row]
                    
                    if isCheckLiveNess!{
                        isCheckLiveNess = false
                        cell.lblValueLiveness.text = "\(dictResultData.objects!) %"
                        cell.lblValueFaceMatch.text = "\(String(describing: faceScoreData!)) %"
                    }else{
                        
                        if dictResultData.name == "FACEMATCH SCORE : "{
                            cell.lblValueLiveness.text = "0 %"
                            cell.lblValueFaceMatch.text = "\(dictResultData.objects!) %"
                        }
                    }
                }else{
                    cell.lblValueFaceMatch.text = "0 %"
                    cell.lblValueLiveness.text = "0 %"
                }
                return cell
            }else if indexPath.section == 2{
                let cell: DocumantVarifyCell = tableView.dequeueReusableCell(withIdentifier: "DocumantVarifyCell") as! DocumantVarifyCell
                if !arrSecurity.isEmpty{
                    let data = arrSecurity[indexPath.row]
                    if data == "true"{
                        cell.labelYES.text = "YES"
                        cell.labelYES.isHidden = false
                        cell.labelYES.textColor = UIColor(red: 137.0 / 255.0, green: 212.0 / 255.0, blue: 47.0 / 255.0, alpha: 1)
                    }else{
                        cell.labelYES.text = "NO"
                        cell.labelYES.isHidden = true
                        cell.labelYES.textColor = UIColor(red: 219.0 / 255.0, green: 68.0 / 255.0, blue: 55.0 / 255.0, alpha: 1)
                    }
                    
                }
                return cell
            }else if indexPath.section == 3{
                
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                
                cell.selectionStyle = .none
                
                if !arrDataForntKey.isEmpty{
                    let objDataKey = arrDataForntKey[indexPath.row]
                    let objDataValue = arrDataForntValue[indexPath.row]
                    cell.lblName.text = objDataKey
                    cell.lblValue.text = objDataValue
                    if objDataKey.contains("Sign") || objDataKey.contains("SIGN"){
                        if let decodedData = Data(base64Encoded: objDataValue, options: .ignoreUnknownCharacters) {
                            let image = UIImage(data: decodedData)
                            let attachment = NSTextAttachment()
                            attachment.image = image
                            let attachmentString = NSAttributedString(attachment: attachment)
                            cell.lblValue.attributedText = attachmentString
                        }
                        
                    }
                }
                return cell
            }
            else if indexPath.section == 4{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.selectionStyle = .none
                if !arrDataBackKey.isEmpty{
                    let objDatakey = arrDataBackKey[indexPath.row]
                    let objDataValue = arrDataBackValue[indexPath.row]
                    cell.lblName.text = objDatakey
                    cell.lblValue.text = objDataValue
                    if objDatakey.contains("Sign") || objDatakey.contains("SIGN"){
                        if let decodedData = Data(base64Encoded: objDataValue, options: .ignoreUnknownCharacters) {
                            let image = UIImage(data: decodedData)
                            let attachment = NSTextAttachment()
                            attachment.image = image
                            let attachmentString = NSAttributedString(attachment: attachment)
                            cell.lblValue.attributedText = attachmentString
                        }
                    }
                }
                return cell
            }else if indexPath.section == 5{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                if !arrDocumentData.isEmpty{
                    
                    let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
                    
                    if indexPath.row == 0{
                        cell.lblName.text = "MRZ"
                        cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    }else{
                        cell.lblName.text = dictResultData[KEY_TITLE] as? String ?? ""
                        cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    }
                    
                }
                return cell
            }
                
            else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                
                cell.selectionStyle = .none
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                if indexPath.row == 0{
                    cell.lblDocName.text = "FRONT SIDE"
                    if imgViewFront != nil{
                        cell.imgDocument.image = imgViewFront!
                    }
                }else{
                    cell.lblDocName.text = "BACK SIDE"
                    if imgViewBack != nil{
                        cell.imgDocument.image = imgViewBack!
                    }
                }
                
                return cell
            }
        }
        else{
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            // print(dictResultData)
            if dictResultData[KEY_FACE_IMAGE] != nil{
                //Set User Image
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
                if dictResultData[KEY_FACE_IMAGE2] != nil{
                    cell.User_img2.isHidden = false
                    cell.view2.isHidden = false
                    if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE2]  as? UIImage{
                        cell.User_img2.image = imageFace
                    }
                }
                return cell
            }else if dictResultData[KEY_TITLE_FACE_MATCH] != nil || dictResultData[KEY_VALUE_FACE_MATCH] != nil{
                
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
                        isCheckLiveNess = false
                        cell.lblValueLiveness.text = "\(dictResultData[KEY_VALUE_FACE_MATCH] as? String ?? "") %"
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
            }else if dictResultData[KEY_TITLE] != nil || dictResultData[KEY_VALUE] != nil{
                //Set Document data
                let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.selectionStyle = .none
                if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
                    cell.lblValue.isHidden = false
                    cell.lblName.isHidden = false
                    //                cell.lblSinglevalue.isHidden = true
                    
                }else{
                    cell.lblValue.isHidden = false
                    cell.lblName.isHidden = false
                }
                if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
                    //                cell.lblSinglevalue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    cell.lblSide.text = "MRZ"
                    cell.constarintViewHaderHeight.constant = 60
                    cell.lblName.text = "MRZ"
                    cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                }else{
                    cell.constarintViewHaderHeight.constant = 0
                    cell.lblName.text = dictResultData[KEY_TITLE] as? String ?? ""
                    cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                }
                
                return cell
            }else{
                //Set Document Images
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                cell.selectionStyle = .none
                cell.imgDocument.contentMode = .scaleToFill
                if dictResultData[KEY_DOC1_IMAGE] != nil {
                    if pageType == .ScanAadhar || pageType == .ScanPan{
                        cell.lblDocName.text = ""
                        cell.constraintLblHeight.constant = 0
                    }else{
                        cell.lblDocName.text = "Front Side"
                        cell.constraintLblHeight.constant = 25
                    }
                    if let imageDoc1: UIImage =  dictResultData[KEY_DOC1_IMAGE]  as? UIImage{
                        cell.imgDocument.image = imageDoc1
                    }
                }
                
                if dictResultData[KEY_DOC2_IMAGE] != nil {
                    if pageType == .ScanAadhar || pageType == .ScanPan{
                        cell.lblDocName.text = ""
                        cell.constraintLblHeight.constant = 0
                    }else{
                        cell.lblDocName.text = "Back Side"
                        
                        cell.constraintLblHeight.constant = 25
                    }
                    if let imageDoc2: UIImage =  dictResultData[KEY_DOC2_IMAGE]  as? UIImage{
                        cell.imgDocument.image = imageDoc2
                    }
                }
                return cell
            }
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if pageType == .ScanOCR{
            if indexPath.section == 0{
                return UITableView.automaticDimension
            }else if indexPath.section == 1{
                if(isFLpershow)
                {
                    return 116
                }
                return 76
            }else if indexPath.section == 2{
                if !arrSecurity.isEmpty{
                    let data = arrSecurity[indexPath.row]
                    if data == "true"{
                        return 75
                    }
                    return 0
                }
                return 0
            }else if indexPath.section == 3{
                return UITableView.automaticDimension
            }else if indexPath.section == 4{
                return UITableView.automaticDimension
            }else if indexPath.section == 5{
                return UITableView.automaticDimension
            }
            else{
                return 310.0
            }
        }else{
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            if dictResultData[KEY_FACE_IMAGE] != nil{
                return UITableView.automaticDimension
            }else if dictResultData[KEY_VALUE_FACE_MATCH] != nil && dictResultData[KEY_TITLE_FACE_MATCH] != nil{
                if(isFLpershow)
                {
                    return 116
                }
                return 76
            } else if dictResultData[KEY_TITLE] != nil && dictResultData[KEY_VALUE] != nil{
                return UITableView.automaticDimension
            }
            else if dictResultData[KEY_TITLE] != nil || dictResultData[KEY_VALUE] != nil{
                return UITableView.automaticDimension
            }
            else if dictResultData[KEY_DOC1_IMAGE] != nil || dictResultData[KEY_DOC2_IMAGE] != nil{
                return 310.0
            }else{
                return 0.0
            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 2{
            return 2
        }else if section == 3{
            return 20
        }else if section == 4{
            if !arrDataBackKey.isEmpty{
                return 20
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 5{
            if !arrDocumentData.isEmpty{
                return 20
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }
        else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let headerView: UIView = UIView.init(frame: CGRect(x: 0, y: 0, width: viewTable.frame.width, height: 0))
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if section == 0{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 2{
            return 2
        }else if section == 3{
            return 60
        }else if section == 4{
            if !arrDataBackKey.isEmpty{
                return 60
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 5{
            if !arrDocumentData.isEmpty{
                return 60
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }
        else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 3{
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
            headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
            let label = UILabel()
            label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
            label.backgroundColor = .clear
            label.text = "OCR FRONT"
            label.font = UIFont.init(name: "Aller-Bold", size: 16)
            label.textAlignment = .left
            label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1) // my custom colour
            headerView.addSubview(label)
            return headerView
        }else if section == 4{
            if !arrDataBackKey.isEmpty{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
                headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                let label = UILabel()
                label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = .clear
                label.text = "OCR BACK"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .left
                label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1)// my custom colour
                headerView.addSubview(label)
                return headerView
            }else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        }else if section == 5{
            if !arrDocumentData.isEmpty{
                
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
                headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                let label = UILabel()
                label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = .clear
                label.text = "MRZ"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .left
                label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1) // my custom colour
                headerView.addSubview(label)
                return headerView
            }else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        } else {
            let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 0))
            return headerView
        }
    }
    
    func tableViewReslut(cell: ResultTableCell, objData: String, objTrueFalse: String){
        if let decodedData = Data(base64Encoded: objData, options: .ignoreUnknownCharacters) {
            let image = UIImage(data: decodedData)
            let attachment = NSTextAttachment()
            attachment.image = image
            let attachmentString = NSAttributedString(attachment: attachment)
            cell.lblName.attributedText = attachmentString
        }
        let attachment1 = NSTextAttachment()
        if objTrueFalse == "true"{
            attachment1.image = UIImage(named: "tick")
        }else{
            attachment1.image = UIImage(named: "close")
        }
        let attachmentString1 = NSAttributedString(attachment: attachment1)
        cell.lblValue.attributedText = attachmentString1
    }
    func setText(cell: ResultTableCell, name: String, color: UIColor){
        cell.lblName.font = UIFont(name: name, size: 14.0)
        cell.lblValue.font = UIFont(name: name, size: 14.0)
        
        cell.lblName.textColor = color
        cell.lblValue.textColor = color
    }

    //MARK:- ZoomVerification Methods
    func onZoomVerificationResult(result: ZoomVerificationResult) {
        if result.status == .failedBecauseEncryptionKeyInvalid{
            let alert = UIAlertController(title: "Public Key Not Set.", message: "Retrieving facemaps requires that you generate a public/private key pair per the instructions at https://dev.zoomlogin.com/zoomsdk/#/zoom-server-guide", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }else if result.status == .userProcessedSuccessfully {
            SVProgressHUD.show(withStatus: "Loading...")
            self.handleVerificationSuccessResult(result: result)
        }
        else{
            // Handle other error
        }
    }
    
    /**
     * This method use to get liveness image and face match score
     * Parameters to Pass: ZoomVerificationResult data
     *
     */
    func handleVerificationSuccessResult(result:ZoomVerificationResult){
        
        let faceMetrics: ZoomFaceBiometricMetrics = result.faceMetrics!  // faceMetrics data is user scanning face
        var faceImage2: UIImage? = nil
        
        if faceMetrics.auditTrail !=  nil &&  faceMetrics.auditTrail!.count > 0{
            if pageType != .ScanOCR{
                var isFindImg: Bool = false
                for (index,var dict) in arrDocumentData.enumerated(){
                    for st in dict.keys{
                        if st == KEY_FACE_IMAGE{
                            // faceMetrics.auditTrail![0] will return user face image from zoom liveness check for face match
                            dict[KEY_FACE_IMAGE2] = faceMetrics.auditTrail![0]
                            arrDocumentData[index] = dict
                            isFindImg = true
                            break
                        }
                        if isFindImg{ break }
                    }
                }
            }else{
                imgCamaraFace = faceMetrics.auditTrail![0]
            }
            // faceMetrics.auditTrail![0] will return user face image from zoom liveness check for face match
            faceImage2 = faceMetrics.auditTrail?[0];
            matchImage = faceImage2 ?? UIImage();
            liveImage = faceImage2 ?? UIImage();
            //Find Facematch score
            if (faceRegion != nil)
            {
                /*
                 FaceMatch SDK method call to detect Face in back image
                 @Params: BackImage, Front Face Image faceRegion
                 @Return: Face Image Frame
                 */
                
                let face2 = EngineWrapper.detectTargetFaces(faceImage2, feature1: faceRegion?.feature)
                /*
                 FaceMatch SDK method call to get FaceMatch Score
                 @Params: FrontImage Face, BackImage Face
                 @Return: Match Score
                 
                 */
                let fm_Score = EngineWrapper.identify(faceRegion?.feature, featurebuff2: face2?.feature)
                let twoDecimalPlaces = String(format: "%.2f", fm_Score*100) //Face Match score convert to float value
                self.removeOldValue("FACEMATCH SCORE : ")
                self.removeOldValue1("0 %")
                if pageType != .ScanOCR{
                        faceScoreData = twoDecimalPlaces
                }else{
                    faceScoreData = twoDecimalPlaces
                }
            }
        }
        self.handleResultFromFaceTecManagedRESTAPICall(_result: result)
    }
    
    /**
     * This method use to get liveness score
     * Parameters to Pass: ZoomVerificationResult user scanning data
     *
     */
    func handleResultFromFaceTecManagedRESTAPICall(_result:ZoomVerificationResult){
        if(_result.faceMetrics != nil)
        {
            let zoomFacemap = _result.faceMetrics?.zoomFacemap //zoomFacemap is Biometric Facemap
            let zoom = zoomFacemap?.base64EncodedString(options: [])
            
            //Call Liveness Api
            let dictPara: NSMutableDictionary = NSMutableDictionary()
            dictPara["sessionId"] = _result.sessionId
            dictPara["facemap"] = zoom
            
            //Call liveness Api
            let apiObject = CustomAFNetWorking(post: WS_liveness, withTag: LivenessTag, withParameter: dictPara)
            apiObject?.delegate = self
        }
    }
    
    //MARK:- UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        picker.dismiss(animated: true, completion: nil)
        isFLpershow = true
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
            guard var chosenImage:UIImage = info[convertFromUIImagePickerControllerInfoKey(UIImagePickerController.InfoKey.originalImage)] as? UIImage else{return}
            
            //Capture Image Left flipped
            DispatchQueue.main.async {
                if picker.sourceType == UIImagePickerController.SourceType.camera && picker.cameraDevice == .front {
                    var flippedImage: UIImage? = nil
                    if let CGImage = chosenImage.cgImage {
                        flippedImage = UIImage(cgImage: CGImage, scale: chosenImage.scale, orientation: .leftMirrored)
                    }
                    chosenImage = flippedImage!
                }
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
            DispatchQueue.main.asyncAfter(deadline: .now(), execute: {
                if (self.faceRegion != nil){
                    /*
                     Accura Face SDK method to detect user face from selfie or camera stream
                     Params: User photo, user face found in document scanning
                     Return: User face from user photo
                     */
                    let face2 : NSFaceRegion? = EngineWrapper.detectTargetFaces(chosenImage, feature1: self.faceRegion?.feature as Data?)   //identify face in back image which found in front image
                    /*
                     Accura Face SDK method to get face match score
                     Params: face image from document with user image from selfie or camera stream
                     Returns: face match score
                     */
                    let fm_Score = EngineWrapper.identify(self.faceRegion?.feature, featurebuff2: face2?.feature)
                    if(fm_Score != 0.0){
                        let data = face2?.bound
                        let image = self.resizeImage(image: chosenImage, targetSize: data!)
                        if self.pageType != .ScanOCR{
                            self.removeOldValue1("0 %")
                            var isFindImg: Bool = false
                            for (index,var dict) in self.arrDocumentData.enumerated(){
                                for st in dict.keys{
                                    if st == KEY_FACE_IMAGE{
                                        dict[KEY_FACE_IMAGE2] = image
                                        self.arrDocumentData[index] = dict
                                        isFindImg = true
                                        break
                                    }
                                    if isFindImg{ break }
                                }
                            }
                        }else{
                            self.imgCamaraFace = image
                        }
                        self.removeOldValue("LIVENESS SCORE : ")
                        self.removeOldValue("FACEMATCH SCORE : ")
                        let twoDecimalPlaces = String(format: "%.2f", fm_Score * 100) //Match score Convert Float Value
                        if self.pageType != .ScanOCR{
                            let dict = [KEY_VALUE_FACE_MATCH: "\(twoDecimalPlaces)",KEY_TITLE_FACE_MATCH:"FACEMATCH SCORE : "] as [String : AnyObject]
                            self.arrDocumentData.insert(dict, at: 1)
                        }else{
                            let ansData = Objects.init(sName: "FACEMATCH SCORE : ", sObjects: "\(twoDecimalPlaces)")
                            self.arrFaceLivenessScor.insert(ansData, at: 0)
                        }
                    }else {
                    }
                }
                self.tblResult.reloadData()
                SVProgressHUD.dismiss()
            })
        }
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
                // print(livenessScore)
                isFLpershow = true
                self.removeOldValue("LIVENESS SCORE : ")
                self.removeOldValue1("0 %")
                isCheckLiveNess = true
                let twoDecimalPlaces = String(format: "%.2f", livenessScore)
                // print(twoDecimalPlaces)
                if pageType != .ScanOCR{
                    let dict = [KEY_VALUE_FACE_MATCH: "\((twoDecimalPlaces))",KEY_TITLE_FACE_MATCH:"LIVENESS SCORE : "] as [String : AnyObject]
                    arrDocumentData.insert(dict, at: 1)
                }else{
                    let ansData = Objects.init(sName: "LIVENESS SCORE : ", sObjects: "\(twoDecimalPlaces)")
                    self.arrFaceLivenessScor.insert(ansData, at: 0)
                }
                
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
        if(imagePhoto != nil)
        {
            faceImage = imagePhoto
        }
        else{
            faceImage = UIImage(named: "default_user")
        }
        
        DispatchQueue.main.async {
            self.faceRegion = nil;
            if (self.faceImage != nil){
                self.faceRegion = EngineWrapper.detectSourceFaces(self.faceImage) //Identify face in Document scanning image
            }
        }
    }

   @objc func buttonClickedFaceMatch(sender:UIButton)
    {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.cameraDevice = .front
        picker.mediaTypes = ["public.image"]
        self.present(picker, animated: true, completion: nil)
    }
    
   @objc func buttonClickedLiveness(sender:UIButton)
    {
        isCheckLiveNess = true
        faceScoreData = nil
        uniqStr = ProcessInfo.processInfo.globallyUniqueString
        if pageType == .Default{
            self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
        }else{
            if photoImage != nil || faceImage != nil{
                self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
            }
        }
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
