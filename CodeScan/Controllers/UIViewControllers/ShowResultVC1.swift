//
//  ShowResultVC.swift
//  AccuraSDK


import UIKit
import ZoomAuthenticationHybrid
import SVProgressHUD
import Alamofire
import SDWebImage

//Define Global Key
let KEY_TITLE           =  "KEY_TITLE"
let KEY_VALUE           =  "KEY_VALUE"
let KEY_FACE_IMAGE      =  "KEY_FACE_IMAGE"
let KEY_FACE_IMAGE2     =  "KEY_FACE_IMAGE2"
let KEY_DOC1_IMAGE      =  "KEY_DOC1_IMAGE"
let KEY_DOC2_IMAGE      =  "KEY_DOC2_IMAGE"
let KEY_TITLE_FACE_MATCH           =  "KEY_TITLE_FACE_MATCH"
let KEY_VALUE_FACE_MATCH           =  "KEY_VALUE_FACE_MATCH"
var MY_ZOOM_DEVELOPER_APP_TOKEN1: String  = "dUfNhktz2Tcl32pGgbPTZ57QujOQBluh"

struct Objects {
    var name : String!
    var objects : String!
    
    init(sName: String, sObjects: String) {
        self.name = sName
        self.objects = sObjects
    }
    
}

struct ObjectsMRZ {
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
    
    @IBOutlet weak var btnLiveness: UIButton!
    @IBOutlet weak var btnFaceMathch: UIButton!
    @IBOutlet weak var btnCancel: UIButton!
    
    @IBOutlet weak var viewTable: UIView!
    
    @IBOutlet weak var viewStatusBar: UIView!
    
    @IBOutlet weak var viewNavigationBar: UIView!
    
    @IBOutlet weak var labelTitle: UILabel!
    
    @IBOutlet weak var imageViewCountry: UIImageView!
    @IBOutlet weak var labelCountryName: UILabel!
    @IBOutlet weak var imageViewContryFlag: UIImageView!
    
    //MARK:- Variable
    let obj_AppDelegate: AppDelegate = UIApplication.shared.delegate as! AppDelegate
    
    var uniqStr = ""
    var mrz_val = ""
    
    var imgDoc: UIImage?
    var retval: Int = 0
    var lines = ""
    var success = false
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
    
    var dictFinalResultFront : NSMutableDictionary = [:]
    var dictFinalResultBack : NSMutableDictionary = [:]
    var dictFaceData : NSMutableDictionary = [:]
    var dictSecurityData : NSMutableDictionary = [:]
    var dictFaceBackData : NSMutableDictionary = [:]
    var arrFinalResultFront  = [Objects]()
    var arrFinalResultBack  = [Objects]()
    var stFace : String?
    var imgViewCountryCard : UIImage?
    var imgSignature : UIImage?
    var objDataAllCountry : AllCountry?
    var modelCountryCard2 : CountryList?
    var imgViewFront : UIImage?
    var imgViewBack : UIImage?
    var arrSecurity = [String]()
    var arrSecurityTrueFalse = [String]()
    var dictScanningData:NSDictionary = NSDictionary()
    var arrMZRData = [ObjectsMRZ]()
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

    
    
    //MARK:- UIViewContoller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        labelTitle.text = "\(modelCountryCard2?.countryName ?? "")"

        imageViewCountry.sd_setImage(with: URL(string: "\(Image_ROOT)\(modelCountryCard2?.image ?? "")"))
        imageViewContryFlag.contentMode = .scaleAspectFill
        labelCountryName.text = stCountryCardName
        imageViewContryFlag.image = imageCountryCard
        
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        
        tblResult.estimatedRowHeight = 45.0
        tblResult.rowHeight = UITableView.automaticDimension
        
        //Pagetype using Hidden show button
        if obj_AppDelegate.selectedScanType == .OcrScan{
            btnLiveness.isHidden = true
            btnFaceMathch.isHidden = true
            btnCancel.isHidden = false
        }else{
            btnLiveness.isHidden = false
            btnFaceMathch.isHidden = false
            btnCancel.isHidden = false
            
            /*
             Initialize Zoom SDK and set Controller
             */
            self.initializeZoom()
        }
        
        
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
            //            faceImage = getImageFaceFromDocumentDirectory(imageFace: "\(objDataAllCountry?.type ?? "")")
            
            if dictFinalResultFront.count != 0 && self.dictFinalResultBack.count != 0{
                let arrFinalResult11 = [dictFaceData]
                
                for face in arrFinalResult11{
                    if let faceId = face["Face"] {
                        stFace = faceId as? String
                    }

                }
                
                setFaceImage()
                
//                dictFinalResultFront.removeObject(forKey: "Face")
                
                for (key,value) in dictFinalResultFront{
                    if value as? String == "<null>"{
                        dictFinalResultFront.removeObject(forKey: key)
                    }
                }
                
                for (key,value) in dictFinalResultFront{
                    
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrFinalResultFront.append(ansData)
                    
                    
//                    if ansData.objects == "false" || ansData.objects == "true" {
//                        arrSecurity.append(ansData.name)
//                        arrSecurityTrueFalse.append(ansData.objects)
//
//                        dictFinalResultFront.removeObject(forKey: ansData.name!)
//
//                    }else{
//                        arrFinalResultFront.append(ansData)
//                    }
                }
//                dictFinalResultFront.removeObject(forKey: "Sign")
               
                
                for(key,value) in dictFaceData{
                    if key as? String != "Face"{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrFinalResultFront.append(ansData)
                    }
                }
                
                dictFinalResultBack.removeObject(forKey: "MRZ")
                
                for (key,value) in dictFinalResultBack{
                    if value as? String == "<null>"{
                        dictFinalResultBack.removeObject(forKey: key)
                    }
                }
                
                for (key,value) in dictFinalResultBack{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrFinalResultBack.append(ansData)
//                    if ansData.objects == "false" || ansData.objects == "true" {
//                        arrSecurity.append(ansData.name)
//                        arrSecurityTrueFalse.append(ansData.objects)
//                        dictFinalResultBack.removeObject(forKey: ansData.name!)
//                    }else{
//                        arrFinalResultBack.append(ansData)
//                    }
                }
                
                for(key,value) in dictFaceBackData{
                  if key as? String != "Face"{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrFinalResultBack.append(ansData)
                    }
                }
                
                
                for(key,value) in dictSecurityData{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrSecurity.append(ansData.name)
                    arrSecurityTrueFalse.append(ansData.objects)

                }
                
                
//                dictFinalResultBack.removeObject(forKey: "Sign")
                
                scanMRZData()
                
            }else{
                arrFinalResultFront.removeAll()
                let arrFinalResult1 = [dictFaceData]
                
                for face in arrFinalResult1{
                    if let faceId = face["Face"] {
                        stFace = faceId as? String
                    }

                }
                
                setFaceImage()
                
//                dictFinalResultFront.removeObject(forKey: "Face")
                
                dictFinalResultFront.removeObject(forKey: "MRZ")
                
                for (key,value) in dictFinalResultFront{
                    if value as? String == "<null>"{
                        dictFinalResultFront.removeObject(forKey: key)
                    }
                }
                
                for (key,value) in dictFinalResultFront{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    
                    arrFinalResultFront.append(ansData)
                    
//                    if ansData.objects == "false" || ansData.objects == "true" {
//                        arrSecurity.append(ansData.name)
//                        arrSecurityTrueFalse.append(ansData.objects)
//
//                        dictFinalResultFront.removeObject(forKey: ansData.name!)
//
//                    }else{
//                        arrFinalResultFront.append(ansData)
//                    }
                }
                
                for(key,value) in dictFaceData{
                  if key as? String != "Face"{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrFinalResultFront.append(ansData)
                    }
                }
                
                
                for(key,value) in dictSecurityData{
                    let ansData = Objects.init(sName: key as? String ?? "", sObjects: value as? String ?? "")
                    arrSecurity.append(ansData.name)
                    arrSecurityTrueFalse.append(ansData.objects)

                }
                
//                dictFinalResultFront.removeObject(forKey: "Sign")
                
                scanMRZData()
            }
            
        }else{
            //           var dictScanningData:NSDictionary = NSDictionary()
            isFirstTime = true
            
            if pageType == .ScanPan || pageType == .ScanAadhar{
                dictScanningData = obj_AppDelegate.dictStoreScanningData // Get Local Store Dictionary
            }else{
                //            dictScanningData  = UserDefaults.standard.value(forKey: "ScanningData") as! NSDictionary  // Get UserDefaults Store Dictionary
                dictScanningData = NSDictionary(dictionary: scannedData)

                if let stFontRotaion:String = dictScanningData["fontImageRotation"] as? String{
                    fontImgRotation = stFontRotaion
                }
                
                if let stBackRotaion:String = dictScanningData["backImageRotation"] as? String{
                    backImgRotation = stBackRotaion
                }
            }
            
            //========================== Filter Scanning data  ==========================//
            if pageType == .ScanPan{
                let strImgURL = dictScanningData["scan_image"] as? String ?? ""
                if let url = URL.init(string: strImgURL) {
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            self.photoImage = UIImage(data: data!)
                            self.faceRegion = nil;
                            if (self.photoImage != nil){
                                self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage) //Identify face in Document scanning image
                            }
                            let dict = [KEY_FACE_IMAGE: self.photoImage] as [String : AnyObject]
                            if !self.arrDocumentData.isEmpty{
                                self.arrDocumentData[0] = dict
                            }
                            self.tblResult.reloadData()
                        }
                    }
                }
                if let stCard: String =  dictScanningData["card"] as? String {
                    self.passportType = stCard
                }
                
                if let stDOB: String =  dictScanningData["date of birth"] as? String {
                    self.birth = stDOB
                }
                
                if let stName: String =  dictScanningData["name"] as? String {
                    self.givenNames = stName
                }
                
                if let stSName: String = dictScanningData["second_name"] as? String {
                    self.surName = stSName
                }
                
                if let stPanCardNo: String =  dictScanningData["pan_card_no"] as? String {
                    self.passportNumber = stPanCardNo
                }
                
                if let image_documentImage: UIImage = dictScanningData["KEY_DOC1_IMAGE"] as? UIImage {
                    appDocumentImage.append(image_documentImage)
                }
                
                self.country = "IND"
                
            }
            else if pageType == .ScanAadhar{
                let strImgURL = dictScanningData["scan_image"] as? String ?? ""
                if let url = URL.init(string: strImgURL) {
                    DispatchQueue.global().async {
                        let data = try? Data(contentsOf: url) //make sure your image in this url does exist, otherwise unwrap in a if let check / try-catch
                        DispatchQueue.main.async {
                            self.photoImage = UIImage(data: data!)
                            self.faceRegion = nil;
                            if (self.photoImage != nil){
                                self.faceRegion = EngineWrapper.detectSourceFaces(self.photoImage) //Identify face in Document scanning image
                            }
                            let dict = [KEY_FACE_IMAGE: self.photoImage] as [String : AnyObject]
                            if !self.arrDocumentData.isEmpty{
                                self.arrDocumentData[0] = dict
                            }
                            self.tblResult.reloadData()
                        }
                    }
                }
                if let stCard: String =  dictScanningData["card"] as? String {
                    self.passportType = stCard
                }
                
                if let stDOB: String =  dictScanningData["date of birth"] as? String {
                    self.birth = stDOB
                }
                
                if let stName: String =  dictScanningData["name"] as? String {
                    self.givenNames = stName
                }
                
                if let stSName: String = dictScanningData["sex"] as? String {
                    self.sex = stSName
                }
                
                if let stPanCardNo: String =  dictScanningData["aadhar_card_no"] as? String {
                    self.passportNumber = stPanCardNo
                }
                
                if let image_documentImage: UIImage = dictScanningData["KEY_DOC1_IMAGE"] as? UIImage {
                    appDocumentImage.append(image_documentImage)
                }
                
                self.country = "IND"
            }
            else{
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
            
        }
        
        //**************************************************************//
        
        //Register Table cell
        self.tblResult.register(UINib.init(nibName: "UserImgTableCell", bundle: nil), forCellReuseIdentifier: "UserImgTableCell")
        
        self.tblResult.register(UINib.init(nibName: "ResultTableCell", bundle: nil), forCellReuseIdentifier: "ResultTableCell")
        
        self.tblResult.register(UINib.init(nibName: "DocumentTableCell", bundle: nil), forCellReuseIdentifier: "DocumentTableCell")
        
        self.tblResult.register(UINib.init(nibName: "FaceMatchResultTableViewCell", bundle: nil), forCellReuseIdentifier: "FaceMatchResultTableViewCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        //Set TableView Height
        self.tblResult.estimatedRowHeight = 60.0
        self.tblResult.rowHeight = UITableView.automaticDimension
        
        if pageType != .ScanOCR{
            
            print("\(retval)")
            
            mrz_val = "CORRECT"
            if retval == 1 {
                mrz_val = "CORRECT"
            } else {
                
            }
            img_height.constant = 0
            imgPhoto.image = photoImage
            self.lblLinestitle.text = lines
            if isFirstTime{
                isFirstTime = false
                self.setData() // this function Called set data in tableView
            }
        }else{
            if dictScanningData.count != 0{
                setOnlyMRZData()
            }
            
            
        }
        
        sendMail()
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
    }
    
    func setOnlyMRZData(){
        for index in 0..<18{
            var dict: [String:AnyObject] = [String:AnyObject]()
            switch index {
                //        case 0:
                //            dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                //            arrDocumentData.append(dict)
            //            break
            case 1:
                dict = [KEY_VALUE: lines] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 2:
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
                
                dict = [KEY_VALUE: dType,KEY_TITLE:"DOCUMENT TYPE : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 3:
                dict = [KEY_VALUE: country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 4:
                dict = [KEY_VALUE: surName,KEY_TITLE:"LAST NAME : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 5:
                dict = [KEY_VALUE: givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 6:
                let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"DOCUMENT NO : "] as [String : AnyObject]
                arrDocumentData.append(dict)
            case 7:
                dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"DOCUMENT CHECK NUMBER : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 8:
                dict = [KEY_VALUE: nationality,KEY_TITLE:"NATIONALITY : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 9:
                dict = [KEY_VALUE: date(toFormatedDate: birth),KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 10:
                dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"BIRTH CHECK NUMBER : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 11:
                var stSex: String = ""
                if sex == "F" {
                    stSex = "FEMALE";
                }
                if sex == "M" {
                    stSex = "MALE";
                }
                dict = [KEY_VALUE: stSex,KEY_TITLE:"SEX : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 12:
                dict = [KEY_VALUE: date(toFormatedDate: expirationDate),KEY_TITLE:"DATE OF EXPIRY : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 13:
                dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"EXPIRATION CHECK NUMBER : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 14:
                dict = [KEY_VALUE: personalNumber,KEY_TITLE:"OTHER ID : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 15:
                dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"OTHER ID CHECK : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 16:
                dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"SECOND ROW CHECK NUMBER : "] as [String : AnyObject]
                arrDocumentData.append(dict)
                break
            case 17:
                var stResult: String = ""
                if retval == 1 {
                    stResult = "CORRECT MRZ";
                }
                else if retval == 2 {
                    stResult = "INCORRECT MRZ";
                }
                else {
                    stResult = "FAIL";
                }
                dict = [KEY_VALUE: stResult,KEY_TITLE:"RESULT : "] as [String : AnyObject]
                arrDocumentData.append(dict)
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
        if pageType == .ScanPan{
            for index in 0..<7 + appDocumentImage.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: self.passportType,KEY_TITLE:"DOCUMENT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
                    dict = [KEY_VALUE: self.surName,KEY_TITLE:"LAST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: self.givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: self.passportNumber,KEY_TITLE:"PAN CARD NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: self.birth,KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    dict = [KEY_VALUE: self.country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }else if pageType == .ScanAadhar{
            for index in 0..<7 + appDocumentImage.count + arrDocumentData.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: self.passportType,KEY_TITLE:"DOCUMENT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
                    dict = [KEY_VALUE: self.givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: self.passportNumber,KEY_TITLE:"AADHAR CARD NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: self.birth,KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: self.sex,KEY_TITLE:"SEX : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    dict = [KEY_VALUE: self.country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }
        else{
            for index in 0..<18 + appDocumentImage.count{
                var dict: [String:AnyObject] = [String:AnyObject]()
                switch index {
                case 0:
                    dict = [KEY_FACE_IMAGE: photoImage] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 1:
                    dict = [KEY_VALUE: lines] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 2:
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
                    
                    dict = [KEY_VALUE: dType,KEY_TITLE:"DOCUMENT TYPE : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 3:
                    dict = [KEY_VALUE: country,KEY_TITLE:"COUNTRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 4:
                    dict = [KEY_VALUE: surName,KEY_TITLE:"LAST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 5:
                    dict = [KEY_VALUE: givenNames,KEY_TITLE:"FIRST NAME : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 6:
                    let stringWithoutSpaces = passportNumber.replacingOccurrences(of: "<", with: "")
                    dict = [KEY_VALUE: stringWithoutSpaces,KEY_TITLE:"DOCUMENT NO : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                case 7:
                    dict = [KEY_VALUE: passportNumberChecksum,KEY_TITLE:"DOCUMENT CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 8:
                    dict = [KEY_VALUE: nationality,KEY_TITLE:"NATIONALITY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 9:
                    dict = [KEY_VALUE: date(toFormatedDate: birth),KEY_TITLE:"DATE OF BIRTH : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 10:
                    dict = [KEY_VALUE: birthChecksum,KEY_TITLE:"BIRTH CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 11:
                    var stSex: String = ""
                    if sex == "F" {
                        stSex = "FEMALE";
                    }
                    if sex == "M" {
                        stSex = "MALE";
                    }
                    dict = [KEY_VALUE: stSex,KEY_TITLE:"SEX : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 12:
                    dict = [KEY_VALUE: date(toFormatedDate: expirationDate),KEY_TITLE:"DATE OF EXPIRY : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 13:
                    dict = [KEY_VALUE: expirationDateChecksum,KEY_TITLE:"EXPIRATION CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 14:
                    dict = [KEY_VALUE: personalNumber,KEY_TITLE:"OTHER ID : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 15:
                    dict = [KEY_VALUE: personalNumberChecksum,KEY_TITLE:"OTHER ID CHECK : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 16:
                    dict = [KEY_VALUE: secondRowChecksum,KEY_TITLE:"SECOND ROW CHECK NUMBER : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 17:
                    var stResult: String = ""
                    if retval == 1 {
                        stResult = "CORRECT MRZ";
                    }
                    else if retval == 2 {
                        stResult = "INCORRECT MRZ";
                    }
                    else {
                        stResult = "FAIL";
                    }
                    dict = [KEY_VALUE: stResult,KEY_TITLE:"RESULT : "] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 18:
                    dict = [KEY_DOC1_IMAGE: !appDocumentImage.isEmpty ? appDocumentImage[0] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                case 19:
                    dict = [KEY_DOC2_IMAGE: appDocumentImage.count == 2 ? appDocumentImage[1] : nil] as [String : AnyObject]
                    arrDocumentData.append(dict)
                    break
                default:
                    break
                }
            }
        }
    }
    
    
    //MARK:- Api Calling
    func sendMail(){
        if pageType == .ScanOCR{
                    DispatchQueue.global(qos: .background).async {
                    var subjectTitle: String = ""
                    var mailBody: String = ""
                    var country: String = ""
                    var givenNames: String = ""
                    var fmScr : String = ""
                    var liveScr : String = ""
                    var arrDocument: [UIImage] = [UIImage]()
                    let br = "<br/>"
                    
                        
                        //=============================== Mail Body =============================== //
                        self.arrFrontMail.removeAll()
                        for (frontMailKey,frontMialValue) in self.dictFinalResultFront{
                            var dict: [String:AnyObject] = [String:AnyObject]()
                            dict = [KEY_VALUE: frontMialValue,KEY_TITLE:frontMailKey] as [String : AnyObject]
                            self.arrFrontMail.append(dict)
                        }
                        
                        self.arrBackMail.removeAll()
                        for (backMailKey,backMialValue) in self.dictFinalResultBack{
                            var dict: [String:AnyObject] = [String:AnyObject]()
                            dict = [KEY_VALUE: backMialValue,KEY_TITLE:backMailKey] as [String : AnyObject]
                            self.arrBackMail.append(dict)
                        }
                        
                        if self.imgViewFront != nil{
                            arrDocument.append(self.imgViewFront!)
                        }
                        
                        if self.imgViewBack != nil{
                            arrDocument.append(self.imgViewBack!)
                        }
                        
                        for dictFinalData in self.arrDocumentData{
                            if dictFinalData[KEY_TITLE] != nil{
                                if dictFinalData[KEY_TITLE] as! String == "FIRST NAME : "{
                                    givenNames = dictFinalData[KEY_VALUE] as! String
                                }
                                
                                if dictFinalData[KEY_TITLE] as! String == "COUNTRY : "{
                                    country = dictFinalData[KEY_VALUE] as! String
                                }
                            }
                        }
                        
                        if self.obj_AppDelegate.selectedScanType == .AccuraScan{
                            fmScr = self.getValueFace(stKey: "FACEMATCH SCORE : ")
                            if !fmScr.isEmpty{
                                mailBody += "FaceMatch Score: \(fmScr) \(br)"
                            }
                            
                            liveScr = self.getValueFace(stKey: "LIVENESS SCORE : ")
                            
                            if !fmScr.isEmpty && liveScr.isEmpty{
                                mailBody += "\(br)"
                            }
                            
                            if !liveScr.isEmpty{
                                mailBody += "Liveness Score: \(liveScr) \(br)"
                                mailBody += "\(br)"
                            }
                            
                        }
                        
                        if !self.arrDocumentData.isEmpty{
                            subjectTitle  = "iOS OCR Test - MRZ + \(country) \(givenNames)" //Mail Title
                        }else{
                            subjectTitle  = "iOS OCR Test + \(self.modelCountryCard2?.countryName ?? "")" //Mail Title
                        }
                        
                        if !self.arrFrontMail.isEmpty{
                            mailBody += "OCR FRONT:- \(br)"
                            for frontMail in self.arrFrontMail{
                                mailBody += "\(frontMail[KEY_TITLE]!): \(frontMail[KEY_VALUE]!) \(br)"
                            }
                            mailBody += "\(br)"
                        }
                        if !self.arrBackMail.isEmpty{
                            mailBody += "OCR BACK:- \(br)"
                            for backMail in self.arrBackMail{
                                mailBody += "\(backMail[KEY_TITLE]!): \(backMail[KEY_VALUE]!) \(br)"
                            }
                            mailBody += "\(br)"
                        }
                        
                        if !self.arrDocumentData.isEmpty{
                            mailBody += "MRZ:- \(br)"
                            mailBody += "Document: \(self.getValue(stKey: "DOCUMENT TYPE : ")) \(br)"
                            mailBody += "Last Name: \(self.getValue(stKey: "LAST NAME : ")) \(br)"
                            mailBody += "First Name: \(self.getValue(stKey: "FIRST NAME : ")) \(br)"
                            mailBody += "Document No: \(self.getValue(stKey: "DOCUMENT NO : ")) \(br)"
                            mailBody += "Document Check Number: \(self.getValue(stKey: "DOCUMENT CHECK NUMBER : ")) \(br)"
                            mailBody += "Country: \(self.getValue(stKey: "COUNTRY : ")) \(br)"
                            mailBody += "Nationality: \(self.getValue(stKey: "NATIONALITY : ")) \(br)"
                            mailBody += "Sex: \(self.getValue(stKey: "SEX : ")) \(br)"
                            mailBody += "Date of Birth: \(self.getValue(stKey: "DATE OF BIRTH : ")) \(br)"
                            mailBody += "Birth Check Number: \(self.getValue(stKey: "BIRTH CHECK NUMBER : ")) \(br)"
                            mailBody += "Expiration Check Number: \(self.getValue(stKey: "EXPIRATION CHECK NUMBER : ")) \(br)"
                            mailBody += "Other ID: \(self.getValue(stKey: "OTHER ID : ")) \(br)"
                            mailBody += "Other ID Check: \(self.getValue(stKey: "OTHER ID CHECK : ")) \(br)"
                            mailBody += "Second Row Check Number: \(self.getValue(stKey: "SECOND ROW CHECK NUMBER : ")) \(br)"
                            mailBody += "Result: \(self.getValue(stKey: "RESULT : ")) \(br)"
                            mailBody += "\(br)"
                        }
                        
                        print(mailBody)
                        print(subjectTitle)
                        //=============================== Mail Body =============================== //
                        
                        var dictParam: [String: String] = [String: String]()
                        dictParam["mailSubject"] = subjectTitle
                        dictParam["platform"] = "iOS"
                        dictParam["facematch"] = fmScr == "" ? "False" : "True"
                        dictParam["liveness"] = liveScr == "" ? "False" : "True"
                        dictParam["mailBody"] = mailBody
                        
                        let sharedInstance = NetworkReachabilityManager()!
                        var isConnectedToInternet:Bool {
                            return sharedInstance.isReachable
                        }
                        if(isConnectedToInternet){
                            let post = PostResult()
                            post.postMethodWithParamsAndImage(parameters: dictParam, forMethod: "https://accurascan.com/sendEmailApi/sendEmail.php", image: arrDocument, faceImg: self.imgCamaraFace == nil ? nil : self.imgCamaraFace , success: { (response) in
                                print(response)
                            }) { (error) in
                                print(error)
                            }
                        }

                        
                    }
        }else{
        DispatchQueue.global(qos: .background).async {
        var subjectTitle: String = ""
        var mailBody: String = ""
        var givenNames: String = ""
        var surName: String = ""
        var fmScr : String = ""
        var liveScr : String = ""
        var cardType : String = ""
        var faceImage: UIImage?
        var arrDocument: [UIImage] = [UIImage]()
        let br = "<br/>";
        //=============================== Mail Body =============================== //
            for dictFinalData in self.arrDocumentData{
            if dictFinalData[KEY_TITLE] != nil{
                if dictFinalData[KEY_TITLE] as! String == "LAST NAME : "{
                    surName = dictFinalData[KEY_VALUE] as! String
                }
                if dictFinalData[KEY_TITLE] as! String == "FIRST NAME : "{
                    givenNames = dictFinalData[KEY_VALUE] as! String
                }
            }
            
            if dictFinalData[KEY_FACE_IMAGE2] != nil {
                faceImage = dictFinalData[KEY_FACE_IMAGE2] as? UIImage
            }
            
            if dictFinalData[KEY_DOC1_IMAGE] != nil{
                arrDocument.append(dictFinalData[KEY_DOC1_IMAGE] as! UIImage)
            }
            
            if dictFinalData[KEY_DOC2_IMAGE] != nil{
                arrDocument.append(dictFinalData[KEY_DOC2_IMAGE] as! UIImage)
            }
        }
        
      
            if self.obj_AppDelegate.selectedScanType == .AccuraScan{
                fmScr = self.getValueFace(stKey: "FACEMATCH SCORE : ")
                
                if !fmScr.isEmpty{
                    mailBody += "FaceMatch Score: \(fmScr) \(br)"
                }
                
                liveScr = self.getValueFace(stKey: "LIVENESS SCORE : ")
                
                if !fmScr.isEmpty && liveScr.isEmpty{
                    mailBody += "\(br)"
                }
                
                if !liveScr.isEmpty{
                    mailBody += "Liveness Score: \(liveScr) \(br)"
                    mailBody += "\(br)"
                }
                
            }
        
            if self.pageType == .ScanAadhar{ //Aadhar Card
            subjectTitle  = "iOS Test - Aadhar + \(givenNames) \(surName)" //Mail Title
                mailBody += "Document: \(self.getValue(stKey: "DOCUMENT : ")) \(br)"
                mailBody += "Last Name: \(self.getValue(stKey: "LAST NAME : ")) \(br)"
                mailBody += "First Name: \(self.getValue(stKey: "FIRST NAME : ")) \(br)"
                mailBody += "Addhar Card No: \(self.getValue(stKey: "AADHAR CARD NO : ")) \(br)"
                mailBody += "Country: \(self.getValue(stKey: "COUNTRY : ")) \(br)"
                mailBody += "Sex: \(self.getValue(stKey: "SEX : ")) \(br)"
                mailBody += "Date of Birth: \(self.getValue(stKey: "DATE OF BIRTH : ")) \(br)"
                mailBody += "Address: \(self.getValue(stKey: "ADDRESS : ")) \(br)"
        }
            else if self.pageType == .ScanPan{ //Pan Card
            subjectTitle  = "iOS Test - PAN + \(givenNames) \(surName)" //Mail Title
                mailBody += "Document: \(self.getValue(stKey: "DOCUMENT : ")) \(br)"
                mailBody += "Last Name: \(self.getValue(stKey: "LAST NAME : ")) \(br)"
                mailBody += "First Name: \(self.getValue(stKey: "FIRST NAME : ")) \(br)"
                mailBody += "Pan Card No: \(self.getValue(stKey: "PAN CARD NO : ")) \(br)"
                mailBody += "Country: \(self.getValue(stKey: "COUNTRY : ")) \(br)"
                mailBody += "Date of Birth: \(self.getValue(stKey: "DATE OF BIRTH : ")) \(br)"
        }else{ //Passport
            subjectTitle  = "iOS Test - MRZ + \(givenNames) \(surName)" //Mail Title
            
                mailBody += "Document: \(self.getValue(stKey: "DOCUMENT TYPE : ")) \(br)"
                mailBody += "Last Name: \(self.getValue(stKey: "LAST NAME : ")) \(br)"
                mailBody += "First Name: \(self.getValue(stKey: "FIRST NAME : ")) \(br)"
                mailBody += "Document No: \(self.getValue(stKey: "DOCUMENT NO : ")) \(br)"
                mailBody += "Document Check Number: \(self.getValue(stKey: "DOCUMENT CHECK NUMBER : ")) \(br)"
                mailBody += "Country: \(self.getValue(stKey: "COUNTRY : ")) \(br)"
                mailBody += "Nationality: \(self.getValue(stKey: "NATIONALITY : ")) \(br)"
                mailBody += "Sex: \(self.getValue(stKey: "SEX : ")) \(br)"
                mailBody += "Date of Birth: \(self.getValue(stKey: "DATE OF BIRTH : ")) \(br)"
                mailBody += "Birth Check Number: \(self.getValue(stKey: "BIRTH CHECK NUMBER : ")) \(br)"
                mailBody += "Expiration Check Number: \(self.getValue(stKey: "EXPIRATION CHECK NUMBER : ")) \(br)"
                mailBody += "Other ID: \(self.getValue(stKey: "OTHER ID : ")) \(br)"
                mailBody += "Other ID Check: \(self.getValue(stKey: "OTHER ID CHECK : ")) \(br)"
                mailBody += "Second Row Check Number: \(self.getValue(stKey: "SECOND ROW CHECK NUMBER : ")) \(br)"
                mailBody += "Result: \(self.getValue(stKey: "RESULT : ")) \(br)"
        }
        
        
            if self.obj_AppDelegate.selectedScanType == .AccuraScan{
                if !self.stLivenessResult.isEmpty{
                    mailBody += "Liveness Result : \(self.stLivenessResult) \(br)"
            }
        }
        
            if self.pageType == .ScanAadhar{
            cardType = "Adharcard"
            }else if self.pageType == .ScanPan{
            cardType = "Pancard"
        }else{
            cardType = "MRZ"
        }
        //=============================== Mail Body =============================== //
        
        print(mailBody)
            
            
            
        var dictParam: [String: String] = [String: String]()
        dictParam["mailSubject"] = subjectTitle
        dictParam["platform"] = "iOS"
        dictParam["type"] = cardType
        dictParam["facematch"] = fmScr == "" ? "False" : "True"
        dictParam["liveness"] = liveScr == "" ? "False" : "True"
        dictParam["mailBody"] = mailBody
    
        let sharedInstance = NetworkReachabilityManager()!
        var isConnectedToInternet:Bool {
            return sharedInstance.isReachable
        }
        if(isConnectedToInternet){
            let post = PostResult()
            post.postMethodWithParamsAndImage(parameters: dictParam, forMethod: "https://accurascan.com/sendEmailApi/sendEmail.php", image: arrDocument, faceImg: faceImage == nil ? nil : faceImage , success: { (response) in
                print(response)
            }) { (error) in
                print(error)
            }
        }
        }
        }
    }
    
//    func sendMail1(){
//        DispatchQueue.global(qos: .background).async {
//        var subjectTitle: String = ""
//        var mailBody: String = ""
//        var country: String = ""
//        var givenNames: String = ""
//        var fmScr : String = ""
//        var liveScr : String = ""
////        var faceImage: UIImage?
//        var arrDocument: [UIImage] = [UIImage]()
//        let br = "<br/>"
//
//
//            //=============================== Mail Body =============================== //
//
//            for (frontMailKey,frontMialValue) in self.dictFinalResultFront{
//                var dict: [String:AnyObject] = [String:AnyObject]()
//                dict = [KEY_VALUE: frontMialValue,KEY_TITLE:frontMailKey] as [String : AnyObject]
//                self.arrFrontMail.append(dict)
//            }
//
//            for (backMailKey,backMialValue) in self.dictFinalResultBack{
//                var dict: [String:AnyObject] = [String:AnyObject]()
//                dict = [KEY_VALUE: backMialValue,KEY_TITLE:backMailKey] as [String : AnyObject]
//                self.arrBackMail.append(dict)
//            }
//
//            if self.imgViewFront != nil{
//                arrDocument.append(self.imgViewFront!)
//            }
//
//            if self.imgViewBack != nil{
//                arrDocument.append(self.imgViewBack!)
//            }
//
//            for dictFinalData in self.arrDocumentData{
//            if dictFinalData[KEY_TITLE] != nil{
//                if dictFinalData[KEY_TITLE] as! String == "FIRST NAME : "{
//                    givenNames = dictFinalData[KEY_VALUE] as! String
//                }
//
//                if dictFinalData[KEY_TITLE] as! String == "COUNTRY : "{
//                    country = dictFinalData[KEY_VALUE] as! String
//                }
//            }
//            }
//
//                if self.obj_AppDelegate.selectedScanType == .AccuraScan{
//                    fmScr = self.getValue(stKey: "FACEMATCH SCORE : ")
//                if !fmScr.isEmpty{
//                    mailBody += "FaceMatch Score: \(fmScr) \(br)"
//                }
//
//                    liveScr = self.getValue(stKey: "LIVENESS SCORE : ")
//                if !liveScr.isEmpty{
//                    mailBody += "Liveness Score: \(liveScr) \(br)"
//                }
//
//            }
//
//            if !self.arrDocumentData.isEmpty{
//            subjectTitle  = "iOS OCR Test - MRZ + \(country) \(givenNames)" //Mail Title
//            }else{
//                subjectTitle  = "iOS OCR Test + \(self.modelCountryCard2?.countryName ?? "")" //Mail Title
//            }
//
//            if !self.arrFrontMail.isEmpty{
//                mailBody += "OCR FORNT:- \(br)"
//                for frontMail in self.arrFrontMail{
//                    mailBody += "\(frontMail[KEY_TITLE]!): \(frontMail[KEY_VALUE]!) \(br)"
//                }
//                mailBody += "\(br)"
//            }
//            if !self.arrBackMail.isEmpty{
//                mailBody += "OCR BACK:- \(br)"
//                for backMail in self.arrBackMail{
//                    mailBody += "\(backMail[KEY_TITLE]!): \(backMail[KEY_VALUE]!) \(br)"
//                }
//                mailBody += "\(br)"
//            }
//
//            if !self.arrDocumentData.isEmpty{
//                mailBody += "MRZ:- \(br)"
//                mailBody += "Document: \(self.getValue(stKey: "DOCUMENT TYPE : ")) \(br)"
//                mailBody += "Last Name: \(self.getValue(stKey: "LAST NAME : ")) \(br)"
//                mailBody += "First Name: \(self.getValue(stKey: "FIRST NAME : ")) \(br)"
//                mailBody += "Document No: \(self.getValue(stKey: "DOCUMENT NO : ")) \(br)"
//                mailBody += "Document Check Number: \(self.getValue(stKey: "DOCUMENT CHECK NUMBER : ")) \(br)"
//                mailBody += "Country: \(self.getValue(stKey: "COUNTRY : ")) \(br)"
//                mailBody += "Nationality: \(self.getValue(stKey: "NATIONALITY : ")) \(br)"
//                mailBody += "Sex: \(self.getValue(stKey: "SEX : ")) \(br)"
//                mailBody += "Date of Birth: \(self.getValue(stKey: "DATE OF BIRTH : ")) \(br)"
//                mailBody += "Birth Check Number: \(self.getValue(stKey: "BIRTH CHECK NUMBER : ")) \(br)"
//                mailBody += "Expiration Check Number: \(self.getValue(stKey: "EXPIRATION CHECK NUMBER : ")) \(br)"
//                mailBody += "Other ID: \(self.getValue(stKey: "OTHER ID : ")) \(br)"
//                mailBody += "Other ID Check: \(self.getValue(stKey: "OTHER ID CHECK : ")) \(br)"
//                mailBody += "Second Row Check Number: \(self.getValue(stKey: "SECOND ROW CHECK NUMBER : ")) \(br)"
//                mailBody += "Result: \(self.getValue(stKey: "RESULT : ")) \(br)"
//                mailBody += "\(br)"
//            }
//
//            print(mailBody)
//            print(subjectTitle)
//            //=============================== Mail Body =============================== //
//
//            var dictParam: [String: String] = [String: String]()
//            dictParam["mailSubject"] = subjectTitle
//            dictParam["platform"] = "iOS"
//            dictParam["facematch"] = fmScr == "" ? "False" : "True"
//            dictParam["liveness"] = liveScr == "" ? "False" : "True"
//            dictParam["mailBody"] = mailBody
//
//            let sharedInstance = NetworkReachabilityManager()!
//            var isConnectedToInternet:Bool {
//                return sharedInstance.isReachable
//            }
//            if(isConnectedToInternet){
//                let post = PostResult()
//                post.postMethodWithParamsAndImage(parameters: dictParam, forMethod: "https://accurascan.com/sendEmailApi/sendEmail.php", image: arrDocument, faceImg: self.faceImage == nil ? nil : self.faceImage , success: { (response) in
//                    print(response)
//                }) { (error) in
//                    print(error)
//                }
//            }
//
//
//        }
//    }
    
    
    //Find Value for array
    func getValue(stKey: String) -> String {
        if pageType == .ScanOCR{
            if !arrDocumentData.isEmpty{
                let arrResult = arrDocumentData.filter( { (details: [String:AnyObject]) -> Bool in
                    return ("\(details[KEY_TITLE] ?? "" as AnyObject)" == stKey )
                })
                
                let dictResult = arrResult.isEmpty ? [String:AnyObject]() : arrResult[0]
                var stResult: String = ""
                if dictResult[KEY_VALUE] != nil { stResult = "\(dictResult[KEY_VALUE] ?? "" as AnyObject)"  }
                else{ stResult = "" }
                return stResult
            }else{
                return ""
            }
        }else{
        let arrResult = arrDocumentData.filter( { (details: [String:AnyObject]) -> Bool in
            return ("\(details[KEY_TITLE] ?? "" as AnyObject)" == stKey )
        })
        print(arrResult)
        let dictResult = arrResult.isEmpty ? [String:AnyObject]() : arrResult[0]
        var stResult: String = ""
        if dictResult[KEY_VALUE] != nil { stResult = "\(dictResult[KEY_VALUE] ?? "" as AnyObject)"  }
        else{ stResult = "" }
        return stResult
        }
    }
    
    
    func getValueFace(stKey: String) -> String {
        if pageType == .ScanOCR{
        let arrResult = arrFaceLivenessScor.filter { (object) -> Bool in
            return object.name == stKey
        }

        let dictResult = arrResult.isEmpty ? Objects.init(sName: "", sObjects: "") : arrResult[0]
        var stResult: String = ""
        if dictResult.objects != nil { stResult = "\(dictResult.objects ?? "")"  }
        else{ stResult = "" }
        return stResult
        }else{
            let arrResult = arrDocumentData.filter( { (details: [String:AnyObject]) -> Bool in
                return ("\(details[KEY_TITLE_FACE_MATCH] ?? "" as AnyObject)" == stKey )
            })
            print(arrResult)
            let dictResult = arrResult.isEmpty ? [String:AnyObject]() : arrResult[0]
            var stResult: String = ""
            if dictResult[KEY_VALUE_FACE_MATCH] != nil { stResult = "\(dictResult[KEY_VALUE_FACE_MATCH] ?? "" as AnyObject)"  }
            else{ stResult = "" }
            return stResult
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
        var status:ZoomSDKStatus = Zoom.sdk.getStatus()
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
                print("AppToken validated successfully")
            } else {
                if Zoom.sdk.getStatus() != .initialized {
                    self.showInitFailedDialog()
                }
            }
        }
        
        // Configures the look and feel of Zoom
        var currentCustomization = ZoomCustomization()
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
        tblResult.reloadData()
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
    
    @IBAction func btnLivenessAction(_ sender: UIButton) {
        uniqStr = ProcessInfo.processInfo.globallyUniqueString
        if pageType == .Default{
            self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
        }else{
            if photoImage != nil || faceImage != nil{
                self.launchZoomToVerifyLivenessAndRetrieveFacemap() //lunchZoom setup
            }
        }
    }
    
    @IBAction func btnFaceMatchAction(_ sender: UIButton) {
        picker.delegate = self
        picker.allowsEditing = false
        picker.sourceType = .camera
        picker.mediaTypes = ["public.image"]
        self.present(picker, animated: true, completion: nil)
    }
    
    @IBAction func btnCancelAction(_ sender: UIButton) {
        if pageType == .ScanOCR{
            removeAllData()
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK:- Other Method
    func removeAllData(){
        dictFinalResultBack.removeAllObjects()
        dictFinalResultFront.removeAllObjects()
        dictFaceData.removeAllObjects()
        dictSecurityData.removeAllObjects()
        dictFaceBackData.removeAllObjects()
        arrMZRData.removeAll()
        arrSecurity.removeAll()
        arrFinalResultFront.removeAll()
        arrFinalResultBack.removeAll()
        stFace = nil
        imagePhoto = nil
        imgViewBack = nil
        imgViewFront = nil
        imgCamaraFace = nil
        faceImage = nil
        
        removeFaceFromDocumentDirectory(imageFace: "\(objDataAllCountry?.type ?? "")")
        //        UserDefaults.standard.removeObject(forKey: "ScanningDataMRZ")
        //        self.navigationController?.popViewController(animated: true)
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
                return arrFaceLivenessScor.count
            case 2:
                return arrFinalResultFront.count
            case 3:
                return arrFinalResultBack.count
            case 4:
                return arrDocumentData.count
            case 5:
                return arrSecurity.count
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
                
                    cell.User_img2.isHidden = true
                    cell.user_img.image = faceImage

                if imgCamaraFace != nil{
                    cell.User_img2.isHidden = false
                    cell.User_img2.image = imgCamaraFace
                }
                
                return cell
            }else if indexPath.section == 1{
               let cell: FaceMatchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FaceMatchResultTableViewCell") as! FaceMatchResultTableViewCell
               if !arrFaceLivenessScor.isEmpty{
                   cell.viewBG.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                cell.viewBG.layer.cornerRadius = 8.0
                let  dictResultData = arrFaceLivenessScor[indexPath.row]
                if indexPath.row == 0{
                 cell.imageView?.image = UIImage(named: "Icn_Face_Scan-1")
                }else{
                 cell.imageView?.image = UIImage(named: "icn_Liveness")
                }
                   cell.lblName.text = dictResultData.name.uppercased()
                   cell.lblValue.text = dictResultData.objects
               }
               
               return cell
            }else if indexPath.section == 2{
                
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell

                    cell.selectionStyle = .none

                    if !arrFinalResultFront.isEmpty{
                        let objData = arrFinalResultFront[indexPath.row]
                        
//                        if objData.name == "FACEMATCH SCORE : " || objData.name == "LIVENESS SCORE : "{
//                            setText(cell: cell, name: "Aller-Bold", color: UIColor.darkText)
//                        }else{
                            setText(cell: cell, name: "Aller-Regular", color: UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1))
//                        }
                        cell.lblName.text = objData.name.uppercased()
                        cell.lblValue.text = objData.objects

                        if objData.name.contains("Sign") || objData.name.contains("SIGN"){
                            if let decodedData = Data(base64Encoded: objData.objects, options: .ignoreUnknownCharacters) {
                                let image = UIImage(data: decodedData)
                                let attachment = NSTextAttachment()
                                attachment.image = image
                                let attachmentString = NSAttributedString(attachment: attachment)
                                cell.lblValue.attributedText = attachmentString
                            }

                        }
                        
                        if arrFinalResultFront.count == indexPath.row + 1{
                            cell.isCheckCell = true
                        }else{
                            cell.isCheckCell = false
                        }
                        
                        
                    }
            
                return cell
            }
            else if indexPath.section == 3{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                cell.selectionStyle = .none
                if !arrFinalResultBack.isEmpty{
                    setText(cell: cell, name: "Aller-Regular", color: UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1))

                        let objData = arrFinalResultBack[indexPath.row]
                        cell.lblName.text = objData.name.uppercased()
                        cell.lblValue.text = objData.objects
                        if objData.name.contains("Sign") || objData.name.contains("SIGN"){
                            if let decodedData = Data(base64Encoded: objData.objects, options: .ignoreUnknownCharacters) {
                                let image = UIImage(data: decodedData)
                                let attachment = NSTextAttachment()
                                attachment.image = image
                                let attachmentString = NSAttributedString(attachment: attachment)
                                cell.lblValue.attributedText = attachmentString
                            }
                        }

                    if arrFinalResultBack.count == indexPath.row + 1{
                        cell.isCheckCell = true

                    }else{
                        cell.isCheckCell = false
                    }
                }
                return cell
            }else if indexPath.section == 4{
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                if !arrDocumentData.isEmpty{
                    setText(cell: cell, name: "Aller-Regular", color: UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1))
                    let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            
                    if indexPath.row == 0{
                        cell.lblName.text = "MRZ:"
                        cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    }else{
                        cell.lblName.text = dictResultData[KEY_TITLE] as? String ?? ""
                        cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    }
                    
                    if arrDocumentData.count == indexPath.row + 1{
                        cell.isCheckCell = true

                    }else{
                        cell.isCheckCell = false
                    }
                    
                    
                }
                return cell
            }
            else if indexPath.section == 5{
                
                let cell: ResultTableCell = tableView.dequeueReusableCell(withIdentifier: "ResultTableCell") as! ResultTableCell
                if !arrSecurity.isEmpty{
 
                        let objData = arrSecurity[indexPath.row]
                        let objTrueFalse = arrSecurityTrueFalse[indexPath.row]
                    
                        tableViewReslut(cell: cell, objData: objData, objTrueFalse: objTrueFalse)
                    
                    
                    if arrSecurity.count == indexPath.row + 1{
                        cell.isCheckCell = true

                    }else{
                        cell.isCheckCell = false
                    }

                }
                
                return cell
            }else{
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                
                cell.viewBG.layer.cornerRadius = 8.0
                cell.viewBG.layer.borderWidth = 0.2
                cell.viewBG.layer.borderColor = UIColor.lightGray.cgColor
                
                cell.selectionStyle = .none
                
                cell.lblDocName.textColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                cell.lblDocName.font = UIFont.init(name: "Aller-Bold", size: 16)
                if indexPath.row == 0{
                    cell.lblDocName.text = "FRONT SIDE:"
                    if imgViewFront != nil{
                        cell.imgDocument.image = imgViewFront!
                    }
                }else{
                    cell.lblDocName.text = "BACK SIDE:"
                    if imgViewBack != nil{
                        cell.imgDocument.image = imgViewBack!
                    }
                }
                
                return cell
            }
        }else{
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            print(dictResultData)
            if dictResultData[KEY_FACE_IMAGE] != nil{
                //Set User Image
                let cell = tableView.dequeueReusableCell(withIdentifier: "UserImgTableCell") as! UserImgTableCell
                cell.selectionStyle = .none
                if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE]  as? UIImage{
                    cell.User_img2.isHidden = true
                    if (UIDevice.current.orientation == .landscapeRight) {
                        cell.user_img.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2))
                    } else if (UIDevice.current.orientation == .landscapeLeft) {
                        cell.user_img.transform = CGAffineTransform(rotationAngle: CGFloat(-(Double.pi / 2)))
                    }
                    cell.user_img.image = imageFace
                    ///UIImageWriteToSavedPhotosAlbum(imageFace, nil, nil, nil)
                }
                if dictResultData[KEY_FACE_IMAGE2] != nil{
                    cell.User_img2.isHidden = false
                    if let imageFace: UIImage =  dictResultData[KEY_FACE_IMAGE2]  as? UIImage{
                        cell.User_img2.image = imageFace
                        //UIImageWriteToSavedPhotosAlbum(imageFace, nil, nil, nil)
                    }
                }
                return cell
            }else if dictResultData[KEY_TITLE_FACE_MATCH] != nil || dictResultData[KEY_VALUE_FACE_MATCH] != nil{
                
                let cell: FaceMatchResultTableViewCell = tableView.dequeueReusableCell(withIdentifier: "FaceMatchResultTableViewCell") as! FaceMatchResultTableViewCell
              cell.viewBG.layer.cornerRadius = 8.0
                
                
               if(dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("FACEMATCH SCORE : ") ?? false || dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("LIVENESS SCORE : ") ?? false){
                
                
                
                cell.lblName.text = dictResultData[KEY_TITLE_FACE_MATCH] as? String ?? ""
                cell.lblValue.text = dictResultData[KEY_VALUE_FACE_MATCH] as? String ?? ""
                }
                if ((dictResultData[KEY_TITLE_FACE_MATCH]?.isEqual("FACEMATCH SCORE : "))!){
                    cell.imageView?.image = UIImage(named: "Icn_Face_Scan-1")
                }else{
                    cell.imageView?.image = UIImage(named: "icn_Liveness")
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
                    //                cell.lblSinglevalue.isHidden = true
                }
                if(dictResultData[KEY_TITLE]?.isEqual("FACEMATCH SCORE : ") ?? false || dictResultData[KEY_TITLE]?.isEqual("LIVENESS SCORE : ") ?? false){
                    
                    setText(cell: cell, name: "Aller-Bold", color: UIColor.darkText)
                }else{
                    setText(cell: cell, name: "Aller-Regular", color: UIColor(red: 85/255, green: 85/255, blue: 85/255, alpha: 1))
    
                }
                
                if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
                    //                cell.lblSinglevalue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    cell.lblSide.text = "MRZ"
                    cell.constarintViewHaderHeight.constant = 25
                    cell.lblName.text = "MRZ:"
                    cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                }else{
                    cell.constarintViewHaderHeight.constant = 0
                    //                cell.lblSinglevalue.text = dictResultData[KEY_VALUE] as? String ?? ""
                    cell.lblName.text = dictResultData[KEY_TITLE] as? String ?? ""
                    cell.lblValue.text = dictResultData[KEY_VALUE] as? String ?? ""
                }
                
                return cell
            }else{
                //Set Document Images
                let cell = tableView.dequeueReusableCell(withIdentifier: "DocumentTableCell") as! DocumentTableCell
                cell.selectionStyle = .none
                cell.imgDocument.contentMode = .scaleToFill
                cell.viewBG.layer.cornerRadius = 8.0
                cell.viewBG.layer.borderWidth = 0.5
                cell.viewBG.layer.borderColor = UIColor.lightGray.cgColor
                if dictResultData[KEY_DOC1_IMAGE] != nil {
                    if pageType == .ScanAadhar || pageType == .ScanPan{
                        cell.lblDocName.text = ""
                        cell.constraintLblHeight.constant = 0
                    }else{
                        cell.lblDocName.text = "Front Side :"
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
                        cell.lblDocName.text = "Back Side :"
                    
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
                return 140.0
            }else if indexPath.section == 1{
                return 50
            }else if indexPath.section == 2{
                return UITableView.automaticDimension
            }else if indexPath.section == 3{
                return UITableView.automaticDimension
            }else if indexPath.section == 4{
                return UITableView.automaticDimension
            }else if indexPath.section == 5{
                return UITableView.automaticDimension
            }else{
//                let stSaveImage2 = arrSaveImage[indexPath.row] as! String
//                               let imageSave2 = loadImageFromDocumentDirectory(nameOfImage: stSaveImage2)
//                               let ratio = imageSave2.size.width / imageSave2.size.height
//                               let cellWidth = (collectionView.bounds.width / 2)
//                               let newHeight = cellWidth / ratio
                
                
                
                
                let width = CGFloat(UIScreen.main.bounds.size.width * 0.98)
                let proportion = CGFloat(Double(objDataAllCountry!.height) / Double(objDataAllCountry!.width))
                
                let height = CGFloat(width * proportion)
                print(height)
                return height + 25
            }
        }else{
            let  dictResultData: [String:AnyObject] = arrDocumentData[indexPath.row]
            if dictResultData[KEY_FACE_IMAGE] != nil{
                return 140.0
            }else if dictResultData[KEY_TITLE_FACE_MATCH] != nil && dictResultData[KEY_VALUE_FACE_MATCH] != nil{
                return 50.0
            } else if dictResultData[KEY_TITLE] == nil && dictResultData[KEY_VALUE] != nil{
                return UITableView.automaticDimension
            }
            else if dictResultData[KEY_TITLE] != nil || dictResultData[KEY_VALUE] != nil{
                return UITableView.automaticDimension
            }
            else if dictResultData[KEY_DOC1_IMAGE] != nil || dictResultData[KEY_DOC2_IMAGE] != nil{
                return 240
            }else{
                return 0.0
            }
        }
        
        
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {

        if section == 0{
            return CGFloat.leastNonzeroMagnitude
        }else if section == 1{
           if !arrFaceLivenessScor.isEmpty{
                return 15
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 2{
            return 15
        }else if section == 3{
            if !arrFinalResultBack.isEmpty{
                return 15
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 4{
            if !arrDocumentData.isEmpty{
                return 15
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 5{
           if !arrSecurity.isEmpty{
                return 15
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else{
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
            return 30
        }else if section == 3{
            if !arrFinalResultBack.isEmpty{
                return 30
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 4{
            if !arrDocumentData.isEmpty{
                return 30
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else if section == 5{
           if !arrSecurity.isEmpty{
                return 30
            }else{
                return CGFloat.leastNonzeroMagnitude
            }
        }else{
            return CGFloat.leastNonzeroMagnitude
        }
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        if section == 2{
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
    
        let label = UILabel()
        label.frame = CGRect.init(x: 8, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
        label.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        label.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
        label.text = "FRONT SIDE OCR"
        label.font = UIFont.init(name: "Aller-Bold", size: 16)
        label.textAlignment = .center
        label.textColor = UIColor.white // my custom colour

        headerView.addSubview(label)
        return headerView
        }else if section == 3{
            if !arrFinalResultBack.isEmpty{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
            
                let label = UILabel()
                label.frame = CGRect.init(x: 8, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                label.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
             
                label.text = "BACK SIDE OCR"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .center
                label.textColor = UIColor.white // my custom colour

                headerView.addSubview(label)
            
            return headerView
            }else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        }else if section == 4{
            if !arrDocumentData.isEmpty{
            
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
            
                let label = UILabel()
                label.frame = CGRect.init(x: 8, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                label.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
               
                label.text = "MRZ"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                label.textAlignment = .center
                label.textColor = UIColor.white // my custom colour

                headerView.addSubview(label)
            return headerView
            }else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        }else if section == 5{
            if !arrSecurity.isEmpty{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 30))
            
                let label = UILabel()
                label.frame = CGRect.init(x: 8, y: 0, width: headerView.frame.width - 16, height: headerView.frame.height)
                label.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
                label.roundCorners(corners: [.topLeft, .topRight], radius: 8.0)
              
                    label.text = "SECURITY CHECK"
                label.font = UIFont.init(name: "Aller-Bold", size: 16)
                
                label.textAlignment = .center
                label.textColor = UIColor.white // my custom colour

                headerView.addSubview(label)
            return headerView
            }else{
                let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 0, height: 0))
                return headerView
            }
        }else{
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
    
    
    
//    func scrollToTop() {
//
//        DispatchQueue.main.async {
//            let indexPath = IndexPath(row: 0, section: 0)
//            self.tblResult.scrollToRow(at: indexPath, at: .top, animated: false)
//        }
//    }
//
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
                if pageType != .ScanOCR{
                    let dict = [KEY_VALUE_FACE_MATCH: "\((twoDecimalPlaces))",KEY_TITLE_FACE_MATCH:"FACEMATCH SCORE : "] as [String : AnyObject]
                    if pageType == .ScanPan || pageType == .ScanAadhar{
                        arrDocumentData.insert(dict, at: 1) // Insert Particular position
                    }else{
                        arrDocumentData.insert(dict, at: 1) // Insert Particular position
                    }
                }else{
                    let ansData = Objects.init(sName: "FACEMATCH SCORE : ", sObjects: "\(twoDecimalPlaces)")
                    self.arrFaceLivenessScor.insert(ansData, at: 0)
                }
                UIView.animate (withDuration: 0.1, animations: {
                    self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
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
        SVProgressHUD.show(withStatus: "Loading...")
        DispatchQueue.global(qos: .background).async {
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
                        
                        if self.pageType != .ScanOCR{
                            
                            var isFindImg: Bool = false
                            for (index,var dict) in self.arrDocumentData.enumerated(){
                                for st in dict.keys{
                                    if st == KEY_FACE_IMAGE{
                                        dict[KEY_FACE_IMAGE2] = chosenImage
                                        self.arrDocumentData[index] = dict
                                        isFindImg = true
                                        break
                                    }
                                    if isFindImg{ break }
                                }
                            }
                        }else{
                            self.imgCamaraFace = chosenImage
                        }
                        self.removeOldValue("LIVENESS SCORE : ")
                        self.btnFaceMathch.isHidden = true
                        self.removeOldValue("FACEMATCH SCORE : ")
                        
                        let twoDecimalPlaces = String(format: "%.2f", fm_Score * 100) //Match score Convert Float Value
                        if self.pageType != .ScanOCR{
                            let dict = [KEY_VALUE_FACE_MATCH: "\(twoDecimalPlaces)",KEY_TITLE_FACE_MATCH:"FACEMATCH SCORE : "] as [String : AnyObject]
                            if self.pageType == .ScanPan || self.pageType == .ScanAadhar{
                                self.arrDocumentData.insert(dict, at: 1)
                            }else{
                                self.arrDocumentData.insert(dict, at: 1)
                            }
                        }else{
                            let ansData = Objects.init(sName: "FACEMATCH SCORE : ", sObjects: "\(twoDecimalPlaces)")
                            self.arrFaceLivenessScor.insert(ansData, at: 0)
                        }
                    }else {
                        self.btnFaceMathch.isHidden = false
                    }
                    
                    self.sendMail()
                }
                UIView.animate (withDuration: 0.1, animations: {
                    self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
                }
                SVProgressHUD.dismiss()
            })
        }
    }
    
    //MARK:-  customURLConnection Delegate
    func customURLConnectionDidFinishLoading(_ connection: CustomAFNetWorking!, withTag tagCon: Int32, withResponse response: Any!) {
        SVProgressHUD.dismiss()
        if tagCon == LivenessTag{
            let dictResponse: NSDictionary = response as? NSDictionary ?? NSDictionary()
            let dictFinalResponse: NSDictionary = dictResponse["data"] as! NSDictionary
            if let livenseeScore: String = dictFinalResponse["livenessResult"] as? String{
                stLivenessResult = livenseeScore
            }
            if let livenessScore: Double = dictFinalResponse["livenessScore"] as? Double{
                self.removeOldValue("LIVENESS SCORE : ")
                btnLiveness.isHidden = true
                let twoDecimalPlaces = String(format: "%.2f", livenessScore)
                if pageType != .ScanOCR{
                    let dict = [KEY_VALUE_FACE_MATCH: "\((twoDecimalPlaces))",KEY_TITLE_FACE_MATCH:"LIVENESS SCORE : "] as [String : AnyObject]
                    if pageType == .ScanPan || pageType == .ScanAadhar{
                        arrDocumentData.insert(dict, at: 1)
                    }else{
                        arrDocumentData.insert(dict, at: 1)
                    }
                }else{
                    let ansData = Objects.init(sName: "LIVENESS SCORE : ", sObjects: "\(twoDecimalPlaces)")
                    self.arrFaceLivenessScor.insert(ansData, at: 0)
                }
                UIView.animate (withDuration: 0.1, animations: {
                    self.tblResult.scrollToRow(at: IndexPath(item: 0, section: 0), at: .top, animated: true)
                }) {(_) in
                    self.tblResult.reloadData()
                }
            }
            self.sendMail()
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
        if stFace != nil{
        if let decodedData = Data(base64Encoded: stFace!, options: .ignoreUnknownCharacters) {
            let image = UIImage(data: decodedData)
            faceImage = image
            }
        }else{
            faceImage = UIImage(named: "default_user")
        }
        
        DispatchQueue.main.async {
            self.faceRegion = nil;
            if (self.faceImage != nil){
                self.faceRegion = EngineWrapper.detectSourceFaces(self.faceImage) //Identify face in Document scanning image
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
