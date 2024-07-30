
import UIKit
//import ProgressHUD
import AccuraOCR

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

struct Objects {
    var name : String!
    var objects : String!
    
    init(sName: String, sObjects: String) {
        self.name = sName
        self.objects = sObjects
    }
    
}

class ShowResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, CustomAFNetWorkingDelegate, FacematchData {
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
    var isLiveness = false
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
    var correctPassportChecksum = ""
    var nationality = ""
    var birth = ""
    var birthChecksum = ""
    var correctBirthChecksum = ""
    var sex = ""
    var expirationDate = ""
    var otherID = ""
    var expirationDateChecksum = ""
    var correctExpirationChecksum = ""
    var personalNumber = ""
    var personalNumberChecksum = ""
    var personalNumber2 = ""
    var correctPersonalChecksum = ""
    var secondRowChecksum = ""
    var correctSecondrowChecksum = ""
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
    var bankCardImage: UIImage?
    
    let picker: UIImagePickerController = UIImagePickerController()
    var stLivenessResult: String = ""
    var faceRegion: NSFaceRegion?
    
    var scannedData: NSMutableDictionary = [:]
    
    var dictFaceData : NSMutableDictionary = [:]
    var dictSecurityData : NSMutableDictionary = [:]
    var dictFaceBackData : NSMutableDictionary = [:]
    var dictOCRTypeData: NSMutableDictionary = [:]
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
    var arrOCRTypeData: [String] = []
    var plateNumber: String?
    var DLPlateImage: UIImage?
    var ischekLivess: Bool = false
    var livenessValue: String = ""
    var intID: Int?
    var orientation: UIInterfaceOrientationMask?
    var facematch = Facematch()
    
    //MARK:- UIViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        isCheckLiveNess = false
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        
        isFirstTime = true
        
        
//        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
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
            for(key, value) in dictOCRTypeData {
                arrOCRTypeData.append(value as! String)
                
            }
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
            }
        } else if pageType == .BankCard{
            dictScanningData = NSDictionary(dictionary: scannedData)
            var dict: [String:AnyObject] = [String:AnyObject]()
            if let cardType = dictScanningData["card_type"] {
                dict = [KEY_VALUE: cardType,KEY_TITLE:"Card Type"] as [String : AnyObject]
                arrDocumentData.append(dict)
            }
            if let cardNumber = dictScanningData["card_number"] {
                dict = [KEY_VALUE: cardNumber,KEY_TITLE:"Number"] as [String : AnyObject]
                arrDocumentData.append(dict)
            }
            if let ExpiryMonth = dictScanningData["expiration_month"] {
                dict = [KEY_VALUE: ExpiryMonth,KEY_TITLE:"Expiry Month"] as [String : AnyObject]
                arrDocumentData.append(dict)
            }
            if let expiryYear = dictScanningData["expiration_year"] {
                dict = [KEY_VALUE: expiryYear,KEY_TITLE:"Expiry Year"] as [String : AnyObject]
                arrDocumentData.append(dict)
            }
          
            
        } else{
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
        facematch.setGlarePercentage(-1, -1) //set glaremin -1 to remove this filter
        
        
        //Set TableView Height
        self.tblResult.estimatedRowHeight = 60.0
        self.tblResult.rowHeight = UITableView.automaticDimension
        if pageType == .BankCard {
           
        } else if pageType != .ScanOCR {
            if isFirstTime{
                isFirstTime = false
                self.setData() // this function Called set data in tableView
            }
        } else{
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
    
    }
    override func viewDidDisappear(_ animated: Bool) {

       
    }
    override func viewWillDisappear(_ animated: Bool) {
       
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
        if let stcorrectPassportChecksum: String = dictScanningData["correctPassportChecksum"] as? String{
            self.correctPassportChecksum = stcorrectPassportChecksum
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
        if let stcorrectBirthChecksum: String = dictScanningData["correctBirthChecksum"] as? String{
            self.correctBirthChecksum = stcorrectBirthChecksum
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
        if let stcorrectExpirationChecksum: String = dictScanningData["correctExpirationChecksum"] as? String{
            self.correctExpirationChecksum = stcorrectExpirationChecksum
        }
        if let strpersonalNumber: String = dictScanningData["personalNumber"] as? String{
            self.personalNumber = strpersonalNumber
        }
        if let strpersonalNumber2: String = dictScanningData["personalNumber2"] as? String{
            self.personalNumber2 = strpersonalNumber2
        }
        if let strpersonalNumberChecksum: String = dictScanningData["personalNumberChecksum"] as? String {
            self.personalNumberChecksum = strpersonalNumberChecksum
        }
        if let stcorrectPersonalChecksum: String = dictScanningData["correctPersonalChecksum"] as? String{
            self.correctPersonalChecksum = stcorrectPersonalChecksum
        }
        if let strsecondRowChecksum: String = dictScanningData["secondRowChecksum"] as? String {
            self.secondRowChecksum = strsecondRowChecksum
        }
        if let stcorrectSecondrowChecksum: String = dictScanningData["correctSecondrowChecksum"] as? String{
            self.correctSecondrowChecksum = stcorrectSecondrowChecksum
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
        for index in 0..<23{
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
                if surName != ""{
                    dict = [KEY_VALUE: surName,KEY_TITLE:"Last Name"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    
                }
                break
            case 3:
                if givenNames != ""{
                    dict = [KEY_VALUE: givenNames,KEY_TITLE:"First Name"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 4:
                if passportNumber != ""{
                    let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                    dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"Document No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
            case 5:
                if passportNumberChecksum != ""{
                    dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"Document Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 6:
                if correctPassportChecksum != ""{
                    dict = [KEY_VALUE: correctPassportChecksum,KEY_TITLE:"Correct Document Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
                
            case 7:
                if country != ""{
                    dict = [KEY_VALUE: country,KEY_TITLE:"Country"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 8:
                if nationality != ""{
                    dict = [KEY_VALUE: nationality,KEY_TITLE:"Nationality"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
                
            case 9:
                var stSex: String = ""
                if sex == "F" {
                    stSex = "FEMALE";
                }else if sex == "M" {
                    stSex = "MALE";
                } else if sex == "X" {
                    stSex = "OTHER";
                } else {
                    stSex = sex
                }
                dict = [KEY_VALUE: stSex,KEY_TITLE:"Sex"] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
                
            case 10:
                if birth != "" {
                    let birthDate = date(toFormatedDate: birth)
                    if birthDate != "" && birthDate != nil{
                        
                        dict = [KEY_VALUE: birthDate,KEY_TITLE:"Date of Birth"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
                break
            case 11:
                if birthChecksum != ""{
                    dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"Birth Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 12:
                if correctBirthChecksum != ""{
                    dict = [KEY_VALUE: correctBirthChecksum,KEY_TITLE:"Correct Birth Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
                
            case 13:
                if expirationDate != "" {
                    let expiryDate = date(toFormatedDate: expirationDate)
                    
                    if expiryDate != "" && expiryDate != nil{
                        
                        dict = [KEY_VALUE: expiryDate,KEY_TITLE:"Date of Expiry"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
                break
            case 14:
                if expirationDateChecksum != ""{
                    dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"Expiration Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 15:
                if correctExpirationChecksum != ""{
                    dict = [KEY_VALUE: correctExpirationChecksum,KEY_TITLE:"Correct Expiration Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 16:
                if personalNumber != ""{
                    dict = [KEY_VALUE: personalNumber,KEY_TITLE:"Other ID"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 17:
                if personalNumber2 != ""{
                    dict = [KEY_VALUE: personalNumber2,KEY_TITLE:"Other ID 2"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break

            case 18:
                if personalNumberChecksum != ""{
                    dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"Other ID Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 19:
                if secondRowChecksum != ""{
                    dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"Second Row Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 20:
                if correctSecondrowChecksum != ""{
                    dict = [KEY_VALUE: correctSecondrowChecksum,KEY_TITLE:"Correct Second Row Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
                
            case 21:
                if issuedate != "" {
                    let issueDate = date(toFormatedDate: issuedate)
                    if issueDate != "" && issueDate != nil{
                        dict = [KEY_VALUE: issueDate,KEY_TITLE:"Issue Date"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
               
                break
            case 22:
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
        for index in 0..<26 + appDocumentImage.count{
            var dict: [String:AnyObject] = [String:AnyObject]()
            switch index {
            case 0:
                if(photoImage != nil) {
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                
                break
            case 1:
                if(photoImage != nil) {
                    dict = [KEY_VALUE_FACE_MATCH: "0 %",KEY_TITLE_FACE_MATCH:"0 %"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
                
            case 2:
                if(lines != "") {
                    dict = [KEY_VALUE: lines] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
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
                if(dType != "") {
                    dict = [KEY_VALUE: dType,KEY_TITLE:"Document"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 4:
                if(surName != "") {
                    dict = [KEY_VALUE: surName,KEY_TITLE:"Last Name"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 5:
                if(givenNames != "") {
                    dict = [KEY_VALUE: givenNames,KEY_TITLE:"First Name"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 6:
                let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                if(stringWithoutSpaces != "") {
                    
                    dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"Document No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                
            case 7:
                if(passportNumberChecksum != "") {
                    dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"Document Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 8:
                if(correctPassportChecksum != "") {
                    dict = [KEY_VALUE: correctPassportChecksum,KEY_TITLE:"Correct Document Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    
                }
                break
            case 9:
                if(country != "") {
                    dict = [KEY_VALUE: country,KEY_TITLE:"Country"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 10:
                if(nationality != "") {
                    dict = [KEY_VALUE: nationality,KEY_TITLE:"Nationality"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 11:
                var stSex: String = ""
                if sex == "F" {
                    stSex = "FEMALE";
                }else if sex == "M" {
                    stSex = "MALE";
                }else if sex == "X" {
                    stSex = "OTHER";
                }  else {
                    stSex = sex
                }
                if(sex != "") {
                    dict = [KEY_VALUE: stSex,KEY_TITLE:"Sex"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 12:
                if birth != "" {
                    let birthDate = date(toFormatedDate: birth)
                    if birthDate != "" && birthDate != nil{
                        
                        dict = [KEY_VALUE: birthDate,KEY_TITLE:"Date of Birth"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
                break
            case 13:
                if(birthChecksum != "") {
                    dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"Birth Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 14:
                if(correctBirthChecksum != "") {
                    dict = [KEY_VALUE: correctBirthChecksum,KEY_TITLE:"Correct Birth Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 15:
                if expirationDate != "" {
                    let expiryDate = date(toFormatedDate: expirationDate)
                    
                    if expiryDate != "" && expiryDate != nil{
                        
                        dict = [KEY_VALUE: expiryDate,KEY_TITLE:"Date of Expiry"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
                break
            case 16:
                if(expirationDateChecksum != "") {
                    dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"Expiration Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 17:
                if(correctExpirationChecksum != "") {
                    dict = [KEY_VALUE: correctExpirationChecksum,KEY_TITLE:"Correct Expiration Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 18:
                if(personalNumber != "") {
                    dict = [KEY_VALUE: personalNumber,KEY_TITLE:"Other ID"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 19:
                if personalNumber2 != ""{
                    dict = [KEY_VALUE: personalNumber2,KEY_TITLE:"Other ID 2"] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
              
            case 20:
                if(personalNumberChecksum != "") {
                    dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"Other ID Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
              
            case 21:
                if(secondRowChecksum != "") {
                    dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"Second Row Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 22:
                if(correctSecondrowChecksum != "") {
                    dict = [KEY_VALUE: correctSecondrowChecksum,KEY_TITLE:"Correct Second Row Check No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 23:
                if issuedate != "" {
                    let issueDate = date(toFormatedDate: issuedate)
                    if issueDate != "" && issueDate != nil{
                        dict = [KEY_VALUE: issueDate,KEY_TITLE:"Issue Date"] as [String : AnyObject]
                        arrDocumentData.append(dict)
                    }
                }
                break
            case 24:
                if departmentNumber != ""{
                    dict = [KEY_VALUE: departmentNumber,KEY_TITLE:"Department No."] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 25:
                dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 26:
                dict = [KEY_DOC2_IMAGE: appDocumentImage.count == 2 ? appDocumentImage[1] : nil] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            default:
                break
            }
        }
    }
    
    func configureGradientBackground(arrcolors:[AnyObject],inLayer:CALayer){
        let gradient: CAGradientLayer = CAGradientLayer()
        gradient.frame = UIScreen.main.bounds
        gradient.colors = arrcolors
        gradient.startPoint =  CGPoint(x: 0, y: 0)
        gradient.endPoint = CGPoint(x: 1, y: 0)
        inLayer.addSublayer(gradient)
    }
    
    func convertImageToBase64(image: UIImage) -> String {
        let imageData = image.jpeg(.medium)
      return imageData!.base64EncodedString(options: Data.Base64EncodingOptions.lineLength64Characters)
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
        EngineWrapper.faceEngineClose()
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
        }else if pageType == .DLPlate {
            return 2
        }else if pageType == .BankCard {
            return 2
        } else{
            return 1
        }
        
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if pageType == .ScanOCR{
            switch section {
            case 0:
                if faceImage != nil {
                    return 1
                } else {
                    return 0
                }
//                return 1
            case 1:
                if faceImage != nil {
                    if arrFaceLivenessScor.isEmpty{
                        return 1
                    }else{
                        return arrFaceLivenessScor.count
                    }
                }else {
                    return 0
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
        }else if(pageType == .DLPlate){
            return 1
        } else if pageType == .BankCard {
            if section == 0 {
                return arrDocumentData.count
            } else {
                return 1
            }
        } else{
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

                        cell.lblValueLiveness.text = "\(livenessValue)"
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
                    cell.imageViewSignHeight.constant = 0
                    if !arrOCRTypeData.isEmpty {
                        if (arrOCRTypeData[indexPath.row] == "2") {
                        if let decodedData = Data(base64Encoded: objDataValue, options: .ignoreUnknownCharacters)
                        {
                            let image = UIImage(data: decodedData)
                            cell.imageViewSignHeight.constant = 51
                            cell.imageViewSign.image = image
                            cell.lblValue.text = ""

                        }
                        
                    }
                }
                }
                return cell
            }
            else if indexPath.section == 4{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.selectionStyle = .none
                cell.imageViewSignHeight.constant = 0
                if !arrDataBackKey.isEmpty{
                    let objDatakey = arrDataBackKey[indexPath.row]
                    let objDataValue = arrDataBackValue[indexPath.row]
                    cell.lblName.text = objDatakey
                    cell.lblValue.text = objDataValue
                    
                    
                    if objDatakey.contains("Sign") || objDatakey.contains("SIGN"){
                        if let decodedData = Data(base64Encoded: objDataValue, options: .ignoreUnknownCharacters) {
                            let image = UIImage(data: decodedData)
                            cell.imageViewSignHeight.constant = 51
                            cell.imageViewSign.image = image
                            cell.lblValue.text = ""
                        }
                    }
                    
                }

                return cell
            }else if indexPath.section == 5{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                if !arrDocumentData.isEmpty{
                    
                    let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
                    cell.imageViewSignHeight.constant = 0
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
        }else if pageType == .DLPlate {

            if indexPath.section == 0{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.SignImageBG.tag = indexPath.section
                if(cell.SignImageBG.tag == indexPath.section) {
                    cell.imageViewSign.isHidden = true
                }
                cell.lblName.text = "Number Plate :"
                cell.lblValue.text = plateNumber
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                
                cell.selectionStyle = .none
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                cell.lblDocName.text = "FRONT SIDE"
                if DLPlateImage != nil{
                    cell.imgDocument.image = DLPlateImage!
                }
                return cell
            }
            
            
        }  else if pageType == .BankCard {
            if indexPath.section == 0{
                let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.SignImageBG.tag = indexPath.section
                if(cell.SignImageBG.tag == indexPath.section) {
                    cell.imageViewSign.isHidden = true
                }
                cell.lblName.text = dictResultData[KEY_TITLE] as! String
                cell.lblValue.text = dictResultData[KEY_VALUE] as! String
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                
                cell.selectionStyle = .none
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                cell.lblDocName.text = "FRONT SIDE"
                if bankCardImage != nil{
                    cell.imgDocument.image = bankCardImage!
                }
                return cell
            }
            
        } else{
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            let index = indexPath.row
            // print(dictResultData)
            if dictResultData[KEY_FACE_IMAGE] != nil{
                //Set User Image
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserImgTableCell") as! UserImgTableCell
                cell.selectionStyle = .none
                if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE]  as? UIImage{
                    cell.User_img2.isHidden = true
                    cell.view2.isHidden = true

                    cell.user_img.image = imageFace
                }
                if imgCamaraFace != nil{
                    cell.User_img2.isHidden = false
                    cell.view2.isHidden = false
                    cell.User_img2.image = imgCamaraFace
                   
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

                        cell.lblValueLiveness.text = "\(livenessValue)"
                        if(faceScoreData != nil) {
                            cell.lblValueFaceMatch.text = "\(String(describing: faceScoreData!)) %"
                        }
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
              
                    
                }else{
                    cell.lblValue.isHidden = false
                    cell.lblName.isHidden = false
                }
                if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
     
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
                cell.imgDocument.contentMode = .scaleAspectFit
                if dictResultData[KEY_DOC1_IMAGE] != nil {
                    if pageType == .ScanAadhar || pageType == .ScanPan{
                        cell.lblDocName.text = ""
                        cell.constraintLblHeight.constant = 0
                    }else{
//                        cell.lblDocName.text = "Front Side"
                        cell.constraintLblHeight.constant = 25
                    }
                    if let imageDoc1: UIImage =  dictResultData[KEY_DOC1_IMAGE]  as? UIImage{
                        cell.imgDocument.image = imageDoc1
                        cell.lblDocName.text = "Front Side"
//                        cell.constraintLblHeight.constant = 25
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
//                        cell.lblDocName.text = "Back Side"
                        
//                        cell.constraintLblHeight.constant = 25
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
                if(imagePhoto != nil) {
                    if(isFLpershow)
                    {
                        return 116
                    }
                    return 76
                } else {
                    return 0
                }
                
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
        }else if pageType == .DLPlate{
            if indexPath.section == 0 {
                return 120
            } else {
                return 310.0
            }
            
        } else if pageType == .BankCard {
            if indexPath.section == 0 {
                return UITableView.automaticDimension
            } else {
                return 310
            }
        } else{
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
            else if dictResultData[KEY_DOC1_IMAGE] != nil {
                return 310.0
            }else if let _ = dictResultData[KEY_DOC2_IMAGE] as? UIImage{
                return 310.0
            } else {
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
            if pageType == .BankCard {
                return 60
            }
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 2{
            return 2
        }else if section == 3{
            if !arrDataForntKey.isEmpty {
                return 60
            } else {
                return CGFloat.leastNonzeroMagnitude
            }
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
        if section == 0 {
            if pageType == .BankCard {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 60))
                headerView.backgroundColor = UIColor.init(red: 237.0/255.0, green: 239.0/255.0, blue: 244.0/255.0, alpha: 1.0)
                let label = UILabel()
                label.frame = CGRect.init(x: 15, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = .clear
                label.text = "BANK CARD DATA"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .left
                label.textColor = UIColor(red: 47.0 / 255.0, green: 50.0 / 255.0, blue: 58.0 / 255.0, alpha: 1) // my custom colour
                headerView.addSubview(label)
                return headerView
            } else {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        } else if section == 3{
            if !arrDataForntKey.isEmpty {
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
            } else {
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                    return headerView
            }
            
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

    
    //MARK:- UIImagePickerController Delegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        // Local variable inserted by Swift 4.2 migrator.
        let info = convertFromUIImagePickerControllerInfoKeyDictionary(info)
        
        picker.dismiss(animated: true, completion: nil)
        isFLpershow = true
//        ProgressHUD.show("Loading...")
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
                        self.isCheckLiveNess = false
                        let image = self.resizeImage(image: chosenImage, targetSize: data!)
                        if self.pageType != .ScanOCR{
                            self.removeOldValue1("0 %")
                            var isFindImg: Bool = false
                            for (index,var dict) in self.arrDocumentData.enumerated(){
                                for st in dict.keys{
                                    if st == KEY_FACE_IMAGE{
                                        self.imgCamaraFace = image
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
//                ProgressHUD.dismiss()
            })
        }
    }
    
    @objc func postMethodWithParamsAndImage(parameters: [String: String],
                                             forMethod: String,
                                             images: UIImage,
                                             faceImg: UIImage?,
                                             success: @escaping (AnyObject) -> Void,
                                             fail: @escaping (AnyObject) -> Void) {
        // Create the URL from the provided string
        guard let url = URL(string: forMethod) else {
            fail("Invalid URL" as AnyObject)
            return
        }
        let boundary = "Boundary-\(UUID().uuidString)"

        // Create the URLRequest
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        // Boundary for multipart/form-data
        
        // Create the HTTP body
        let body = NSMutableData()

        // Append parameters
        for (key, value) in parameters {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n")
            body.appendString("\(value)\r\n")
        }
        
        // Append images
//        for (index, image) in images.enumerated() {
            if let imageData = images.pngData() {
                body.appendString("--\(boundary)\r\n")
                body.appendString("Content-Disposition: form-data; name=\"liveness_image\"; filename=\"liveness_image.jpg\"\r\n")
                body.appendString("Content-Type: image/jpg\r\n\r\n")
                body.append(imageData)
                body.appendString("\r\n")
            }
//        }

        // Append face image if present
        if let faceImg = faceImg, let faceImgData = faceImg.pngData() {
            body.appendString("--\(boundary)\r\n")
            body.appendString("Content-Disposition: form-data; name=\"face_image\"; filename=\"face_image.jpg\"\r\n")
            body.appendString("Content-Type: image/jpg\r\n\r\n")
            body.append(faceImgData)
            body.appendString("\r\n")
        }

        // Append the final boundary
        body.appendString("--\(boundary)--\r\n")
        
        // Set the body to the request
        request.httpBody = body as Data

        // Create the URLSession task
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                fail(error.localizedDescription as AnyObject)
                return
            }

            guard let data = data else {
                fail("No data" as AnyObject)
                return
            }

            do {
                let json = try JSONSerialization.jsonObject(with: data, options: [])
                success(json as AnyObject)
            } catch {
                fail(error.localizedDescription as AnyObject)
            }
        }
        task.resume()
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
//        ProgressHUD.dismiss()
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
                    let ansData = Objects.init(sName: "LIVENESS SCORE : ", sObjects: "\(stLivenessResult)")
                    self.arrFaceLivenessScor.insert(ansData, at: 0)
                }
                
                self.tblResult.reloadData()
            }
        }
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didReceive response: URLResponse!) {
        
    }
    
    func customURLConnection(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, didFailWithError error: Error!) {
//        ProgressHUD.dismiss()
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
        dateFormat.dateFormat = "yy-MM-dd"
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
    let orientastion = UIApplication.shared.statusBarOrientation
    if orientastion ==  UIInterfaceOrientation.landscapeLeft {
        orientation = .landscapeLeft
    } else if orientastion == UIInterfaceOrientation.landscapeRight {
        orientation = .landscapeRight
    } else {
        orientation = .portrait
    }
        isLiveness = false
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
    facematch.setFacematch(self)

    }
    
   @objc func buttonClickedLiveness(sender:UIButton)
    {
    let orientastion = UIApplication.shared.statusBarOrientation
    if orientastion ==  UIInterfaceOrientation.landscapeLeft {
        orientation = .landscapeLeft
    } else if orientastion == UIInterfaceOrientation.landscapeRight {
        orientation = .landscapeRight
    } else {
        orientation = .portrait
    }
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
//    liveness.setLiveness(self)
        isLiveness = true
        facematch.setFacematch(self)
    
        
    }
    
    func facematchViewDisappear() {
        if(orientation == .landscapeLeft) {
            AppDelegate.AppUtility.lockOrientation(.landscapeLeft, andRotateTo: .landscapeLeft)
        } else if orientation == .landscapeRight {
            AppDelegate.AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        }
    }
    func facematchData(_ FaceImage: UIImage!) {
        isFLpershow = true
        self.imgCamaraFace = FaceImage
        self.livenessValue = "0.00 %"
        if isLiveness {
            postMethodWithParamsAndImage(parameters: [:], forMethod: "Your API", images: FaceImage, faceImg: nil, success: { (response) in
                
                let responses = response as? [String:Any]
                
                if let score = responses?["score"] {
                    self.livenessValue = "\(score) %"
                    self.imgCamaraFace = FaceImage
                    
                    DispatchQueue.main.async {
                        self.tblResult.reloadData()
                    }
                }
                
            }) { (error) in
                print(error)
            }
        }
        if (faceRegion != nil)
        {
            /*
             FaceMatch SDK method call to detect Face in back image
             @Params: BackImage, Front Face Image faceRegion
             @Return: Face Image Frame
             */
            
            let face2 = EngineWrapper.detectTargetFaces(FaceImage, feature1: faceRegion?.feature)
            let face11 = faceRegion?.image
            /*
             FaceMatch SDK method call to get FaceMatch Score
             @Params: FrontImage Face, BackImage Face
             @Return: Match Score
             
             */
            
            let fm_Score = EngineWrapper.identify(faceRegion?.feature, featurebuff2: face2?.feature)
            if(fm_Score != 0.0){
            let data = face2?.bound
            let image = self.resizeImage(image: FaceImage, targetSize: data!)
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
        }
            tblResult.reloadData()
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

// Helper function to append strings to NSMutableData
extension NSMutableData {
    func appendString(_ string: String) {
        if let data = string.data(using: .utf8) {
            append(data)
        }
    }
}
