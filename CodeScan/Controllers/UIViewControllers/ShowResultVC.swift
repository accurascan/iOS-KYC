
import UIKit
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

var uniqueID = ""

struct Objects {
    var name : String!
    var objects : String!
    
    init(sName: String, sObjects: String) {
        self.name = sName
        self.objects = sObjects
    }
    
}

@available(iOS 15, *)
class ShowResultVC: UIViewController, UITableViewDelegate, UITableViewDataSource,UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate,VideoCameraWrapperDelegate{

    //MARK:- Outlet
    @IBOutlet weak var img_height: NSLayoutConstraint!
    @IBOutlet weak var lblLinestitle: UILabel!
    @IBOutlet weak var tblResult: UITableView!
    @IBOutlet weak var imgPhoto: UIImageView!
        
    @IBOutlet weak var dobLab: UILabel!
    @IBOutlet weak var passNo: UILabel!
    @IBOutlet weak var doeLabel: UILabel!
    @IBOutlet weak var textField: UITextField!
    @IBOutlet weak var doePicker: UIDatePicker!
    @IBOutlet weak var dobPicker: UIDatePicker!
    @IBOutlet weak var addDateView: UIView!
    var docFrontImage:UIImage?
    @IBOutlet weak var viewTable: UIView!
    
    @IBOutlet weak var viewStatusBar: UIView!
    
    @IBOutlet weak var viewNavigationBar: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var heightOfNFC: NSLayoutConstraint!
    
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
    var arrnfcPassportKey :[Any]? = nil
    var arrnfcPassportData:[Any]? = nil
    var photoImage: UIImage?
    var documentImage: UIImage?
    var nfcpassportImage: UIImage?
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
    var nfcPassportNumber = ""
    var accuraCameraWrapper: AccuraCameraWrapper? = nil

    var nfcDob = ""
    var nfcDoe = ""
    var scannedData: NSMutableDictionary = [:]
    let datePicker = UIDatePicker()
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
    
    //MARK:- UIViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        clearLogFile()
        uniqueID = randomString(length: 5)
        addDateView.layer.cornerRadius = 10
        addDateView.layer.borderColor = UIColor.black.cgColor
        addDateView.layer.borderWidth = 1
        textField.returnKeyType = .done
        textField.autocapitalizationType = .allCharacters
        textField.autocorrectionType = .no
//        textField.becomeFirstResponder()
        textField.delegate = self
        isCheckLiveNess = false
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        
        isFirstTime = true
        
        

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
//                    self.faceRegion = nil;
                    if (self.photoImage != nil){
//                        self.faceRegion = EngineWrapper.detectSourceFaces(photoImage) //Identify face in Document scanning image
                    }
                }
                if let image_documentFontImage: Data = dictScanningData["docfrontImage"] as? Data  {
                    appDocumentImage.append(UIImage(data: image_documentFontImage)!)
                    docFrontImage = UIImage(data: image_documentFontImage)!
                }
                
                if let image_documentImage: Data = dictScanningData["documentImage"] as? Data  {
                    appDocumentImage.append(UIImage(data: image_documentImage)!)
                }
                imgDoc = documentImage
//        }
        
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
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date: Date? = dateFormatter.date(from: birth ?? "")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dobPicker.date = date!//date(toFormatedDate: birth)
        
        
        
//        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let date1: Date? = dateFormatter.date(from: expirationDate ?? "")
        dateFormatter.dateFormat = "dd-MM-yyyy"
        doePicker.date = date1!//date(toFormatedDate: birth)
        super.viewDidAppear(animated)
    
    }
    override func viewDidDisappear(_ animated: Bool) {

       
    }
    override func viewWillDisappear(_ animated: Bool) {
       
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        let text = textField.text
        print("\(text)")
        nfcPassportNumber = "\(text)"
         return true
    }
    
    @IBAction func startNFC(_ sender: Any) {
        heightOfNFC.constant = 0
        accuraCameraWrapper = AccuraCameraWrapper.init(delegate: self)
        accuraCameraWrapper?.startNFC(forPassport: nfcDob, doe: nfcDoe, passportNumber: nfcPassportNumber)
        dobLab.isHidden = true
        passNo.isHidden = true
        doeLabel.isHidden = true
        textField.isHidden = true
        doePicker.isHidden = true
        dobPicker.isHidden = true
        addDateView.isHidden = true
    }
    
    
    @IBAction func dobEdit(_ sender: Any) {
        dobPicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let selectedDate = dateFormatter.string(from: dobPicker.date)
        nfcDob = selectedDate
    }
    @IBAction func doeEdit(_ sender: Any) {
        doePicker.datePickerMode = UIDatePicker.Mode.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyMMdd"
        let selectedDate = dateFormatter.string(from: doePicker.date)
        nfcDoe = selectedDate
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
                    textField.text = stringWithoutSpaces
                    nfcPassportNumber = stringWithoutSpaces
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
                } else if sex == "x" {
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
                        nfcDob = birth
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
                        nfcDoe = expirationDate
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
    
    func setNFCData(){
        //Set tableView Data
        for index in 0..<56 + appDocumentImage.count{
            var dict: [String:AnyObject] = [String:AnyObject]()
            switch index {
            case 0:
                break
            case 1:
                break
            case 2:
                break
            case 3:
                break
            case 4:
                break
            case 5:
                break
            case 6:
                break
            case 7:
                break
            case 8:
                break
            case 9:
                break
            case 10:
                break
            case 11:
                break
            case 12:
                break
            case 13:
                break
            case 14:
                break
            case 15:
                break
            case 16:
                break
            case 17:
                break
            case 18:
                break
            case 19:
                break
            case 20:
                break
              
            case 21:
                break
            case 22:
                break
            case 23:
                break
            case 24:
                break
            case 25:
                break
            case 26:
                break
            case 23:
                if arrnfcPassportKey![0] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[0],KEY_TITLE:arrnfcPassportKey![0]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
            case 24:
                if arrnfcPassportKey![1] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[1],KEY_TITLE:arrnfcPassportKey![1]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break

            case 25:
                if arrnfcPassportKey![2] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[2],KEY_TITLE:arrnfcPassportKey![2]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break

            case 26:
                if arrnfcPassportKey![3] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[3],KEY_TITLE:arrnfcPassportKey![3]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break
            case 27:
                if arrnfcPassportKey![4] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[4],KEY_TITLE:arrnfcPassportKey![4]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break
            case 28:
                if arrnfcPassportKey![5] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[5],KEY_TITLE:arrnfcPassportKey![5]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break
            case 29:
                if arrnfcPassportKey![6] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[6],KEY_TITLE:arrnfcPassportKey![6]] as [String : AnyObject]
                    arrDocumentData.append(dict)

                }
                break
            case 30:
                if arrnfcPassportKey![7] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[7],KEY_TITLE:arrnfcPassportKey![7]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 31:
                if arrnfcPassportKey![8] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[8],KEY_TITLE:arrnfcPassportKey![8]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 32:
                if arrnfcPassportKey![9] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[9],KEY_TITLE:arrnfcPassportKey![9]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 33:
                if arrnfcPassportKey![10] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[10],KEY_TITLE:arrnfcPassportKey![10]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 34:
                if arrnfcPassportKey![11] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[11],KEY_TITLE:arrnfcPassportKey![11]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 35:
                if arrnfcPassportKey![12] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[12],KEY_TITLE:arrnfcPassportKey![12]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 36:
                if arrnfcPassportKey![13] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[13],KEY_TITLE:arrnfcPassportKey![13]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 37:
                if arrnfcPassportKey![14] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[14],KEY_TITLE:arrnfcPassportKey![14]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 38:
                if arrnfcPassportKey![15] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[15],KEY_TITLE:arrnfcPassportKey![15]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 39:
                if arrnfcPassportKey![16] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[16],KEY_TITLE:arrnfcPassportKey![16]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 40:
                if arrnfcPassportKey![17] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[17],KEY_TITLE:arrnfcPassportKey![17]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 41:
                if arrnfcPassportKey![18] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[18],KEY_TITLE:arrnfcPassportKey![18]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 42:
                if arrnfcPassportKey![19] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[19],KEY_TITLE:arrnfcPassportKey![19]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 43:
                if arrnfcPassportKey![20] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[20],KEY_TITLE:arrnfcPassportKey![20]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 44:
                if arrnfcPassportKey![21] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[21],KEY_TITLE:arrnfcPassportKey![21]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 45:
                if arrnfcPassportKey![22] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[22],KEY_TITLE:arrnfcPassportKey![22]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 46:
                if arrnfcPassportKey![23] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[23],KEY_TITLE:arrnfcPassportKey![23]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 47:
                if arrnfcPassportKey![24] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[24],KEY_TITLE:arrnfcPassportKey![24]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 48:
                if arrnfcPassportKey![25] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[25],KEY_TITLE:arrnfcPassportKey?[25]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 49:
                if arrnfcPassportKey![26] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[26],KEY_TITLE:arrnfcPassportKey![26]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 50:
                if arrnfcPassportKey![27] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[27],KEY_TITLE:arrnfcPassportKey![27]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 51:
                if arrnfcPassportKey![28] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[28],KEY_TITLE:arrnfcPassportKey![28]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            case 52:
                if arrnfcPassportKey![29] as! String != ""{
                    dict = [KEY_VALUE: arrnfcPassportData?[29],KEY_TITLE:arrnfcPassportKey![29]] as [String : AnyObject]
                    arrDocumentData.append(dict)
                }
                break
            default:
                break
            }
        }
    }
    
    
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
                    textField.text = stringWithoutSpaces
                    nfcPassportNumber = stringWithoutSpaces
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
                        nfcDob = birth
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
                        nfcDoe = expirationDate
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
//        EngineWrapper.faceEngineClose()
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
//        }else if pageType == .DLPlate {
//            return 2
//        }else if pageType == .BankCard {
//            return 2
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
        }
//        else if(pageType == .DLPlate){
//            return 1
//        } else if pageType == .BankCard {
//            if section == 0 {
//                return arrDocumentData.count
//            } else {
//                return 1
//            }
//        }
        else{
            return  self.arrDocumentData.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            let index = indexPath.row + 30
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
//                cell.btnFaceMatch.addTarget(self, action: #selector(buttonClickedFaceMatch(sender:)), for: .touchUpInside)
//                cell.btnLiveness.addTarget(self, action: #selector(buttonClickedLiveness(sender:)), for: .touchUpInside)
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
                    return 0
                }
                return 0
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
    
    @IBAction func closeAddDateView(_ sender: UIButton) {
           heightOfNFC.constant = 0
//           scanPassport()
           dobLab.isHidden = true
           passNo.isHidden = true
           doeLabel.isHidden = true
           textField.isHidden = true
           doePicker.isHidden = true
           dobPicker.isHidden = true
           addDateView.isHidden = true
       }
    
    //Find Value for array
    func getValue(stKey: String) -> String {
        let arrResult = arrDocumentData.filter( { (details: [String:AnyObject]) -> Bool in
            return ("\(details[KEY_TITLE] ?? "" as AnyObject)" == stKey )
        })
//        print(arrResult)
        let dictResult = arrResult.isEmpty ? [String:AnyObject]() : arrResult[0]
        var stResult: String = ""
        if dictResult[KEY_VALUE] != nil { stResult = "\(dictResult[KEY_VALUE] ?? "" as AnyObject)"  }
        else{ stResult = "" }
        return stResult
    }
    
    
    func nfcData(_ NFCKey: [Any]!, nfcValue NFCValue: [Any]!, face: UIImage!) {

        arrnfcPassportKey = NFCKey
        arrnfcPassportData = NFCValue
        
        // Dictionary to store key-value pairs
        var dictData: [String: Any] = [:]

        // Iterate over the arrays and populate the dictionary
        for (index, key) in NFCKey.enumerated() {
            // Check if index is within bounds of NFCValue array
            if index < NFCValue.count {
                let value = NFCValue[index]
                dictData[key as? String ?? "" ] = value
            } else {
                // Handle case where NFCValue array might be shorter than NFCKey array
                // Optionally, you can decide what to do if lengths don't match
                print("Warning: Value not found for key \(key)")
            }
        }
        
        DispatchQueue.main.async {
            
            if face != nil {
                self.nfcpassportImage = face

            }
            self.setNFCData()
            self.tblResult.reloadData()
//            self.showDetails = true

        }


    }
    
    func clearLogFile() {
        let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
        let documentsDirectory = paths[0]
        let path = (documentsDirectory as NSString).appendingPathComponent("AccuraNFCLog.txt")
        
        // Overwrite the file with an empty string
        let emptyString = ""
        do {
            try emptyString.write(toFile: path, atomically: true, encoding: .utf8)
            print("Log file cleared successfully")
        } catch {
            print("Error clearing log file: \(error.localizedDescription)")
        }
    }
    
    func randomString(length: Int) -> String {
            let letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789"
            return String((0..<length).map{ _ in letters.randomElement()! })
    }
    
    func nfcError(_ error: String!) {
        // Create the alert controller

        let alertController = UIAlertController(title: "Alert!", message: error, preferredStyle: .alert)
        
//        datePicker.datePickerMode = .date
//        datePicker.addTarget(self, action: #selector(dateChanged), for: .valueChanged)
        // Create the actions
        let okAction = UIAlertAction(title: "Ok", style: UIAlertAction.Style.default) {
            UIAlertAction in
//            self.scanPassport()
        }

        // Add the actions
        alertController.addAction(okAction)
        DispatchQueue.main.async {
            self.present(alertController, animated: true, completion: nil)
        }
    }
}
