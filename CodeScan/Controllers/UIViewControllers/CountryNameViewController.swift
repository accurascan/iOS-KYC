
import UIKit
import SVProgressHUD
import AccuraOCR

struct CountryName {
    let id : Int?
    var country_name : String?
    let id_card : Int?
    let passport : Int?
    let pdf_file : Int?
  
    init( id:Int, country_name:String, id_card:Int, passport:Int, pdf_file:Int) {
        self.id = id
        self.country_name = country_name
        self.id_card = id_card
        self.passport = passport
        self.pdf_file = pdf_file
    }
}


class CountryNameViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate {
    
    //MARK:- Outlet
    @IBOutlet weak var tblViewCountryList: UITableView!
    
    @IBOutlet weak var viewNavigationBar: UIView!
    
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var lablelDataNotFound: UILabel!
    
    
    //MARK:- Variable
    var searchTxt = ""
    var arrCountryList = NSMutableArray()
    var isMRZCell = false
    var isPDFCell = false
    var videoCameraWrapper: VideoCameraWrapper? = nil
    
    //MARK:- View Controller Method
    override func viewDidLoad() {
        super.viewDidLoad()

        SVProgressHUD.show(withStatus: "Loading...")
        lablelDataNotFound.isHidden = true
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        videoCameraWrapper = VideoCameraWrapper.init()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            let sdkModel = self.videoCameraWrapper?.loadEngine(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)
            if(sdkModel != nil)
            {
                if(sdkModel!.isMRZEnable)
                {
                    self.isMRZCell = true
                }
                else{
                    self.isMRZCell = false
                }
                if(sdkModel!.isPDF417Enable)
                {
                    self.isPDFCell = true
                }
                else{
                    self.isPDFCell = false
                }
            }
            if(self.isMRZCell)
            {
                self.arrCountryList.add("Passport & ID MRZ")
            }
            if(self.isPDFCell)
            {
                self.arrCountryList.add("Barcode")
            }
            let countryListStr = self.videoCameraWrapper?.getOCRList()
            if(countryListStr != nil)
            {
                for i in countryListStr!{
                    self.arrCountryList.add(i)
                }
            }
            else{
                GlobalMethods.showAlertView("", with: self)
            }
            
             if(sdkModel != nil){
             if sdkModel!.i > 0{
                 self.videoCameraWrapper?.setFaceBlurPercentage(80)
                 self.videoCameraWrapper?.setHologramDetection(true)
                 self.videoCameraWrapper?.setLowLightTolerance(10)
                 self.videoCameraWrapper?.setMotionThreshold(4, stMassage: "")
                 self.videoCameraWrapper?.setGlarePercentage(6, intMax: 99)
                 self.videoCameraWrapper?.setCheckPhotoCopy(false)
             }
            }
            
            self.tblViewCountryList.delegate = self
            self.tblViewCountryList.dataSource = self
            self.tblViewCountryList.reloadData()
            SVProgressHUD.dismiss()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    

    
    //MARK:- Button Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    //MARK:- TableView Method
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if(arrCountryList.count == 0)
        {
            lablelDataNotFound.isHidden = false
        }
        else{
            lablelDataNotFound.isHidden = true
        }
        return arrCountryList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell : CountryListCell = tableView.dequeueReusableCell(withIdentifier: "CountryListCell") as! CountryListCell
        cell.layer.cornerRadius = 8.0
        let cellDict = arrCountryList.object(at: indexPath.row)
        if let stringCell = cellDict as? String {
            cell.viewCountryName.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            cell.lblCountryName.text = stringCell
        }
        else {
            let countrycellDict = arrCountryList.object(at: indexPath.row) as! NSDictionary
            cell.layer.cornerRadius = 8.0
            cell.viewCountryName.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.lblCountryName.text = "\(String(describing: (countrycellDict.value(forKey: "country_name"))!))"
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDict = arrCountryList.object(at: indexPath.row)
        if let stringCell = cellDict as? String {
            if(stringCell == "Barcode")
            {
                let loginVC = UIStoryboard(name: "CodeScanVC", bundle: nil).instantiateViewController(withIdentifier: "CodeScanVC") as! CodeScanVC
                loginVC.isBarcodeEnabled = true
                self.navigationController?.pushViewController(loginVC, animated: true)
            }
            else{
                let vc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.isCheckScanOCR = false
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
        else {
            let countrycellDict = arrCountryList.object(at: indexPath.row) as! NSDictionary
            let screenList = countrycellDict.value(forKey: "cards") as! NSArray
            let vc : ListViewVC = self.storyboard?.instantiateViewController(withIdentifier: "ListViewVC") as! ListViewVC
            vc.screenList = screenList.mutableCopy() as! NSMutableArray
            vc.countryId = countrycellDict.value(forKey: "country_id") as? Int
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

//MAARK: - Extension View
extension UIView {
    func setShadowToView() {
        self.layer.cornerRadius = 8.0
        self.layer.borderColor = UIColor.black.cgColor
        self.layer.borderWidth = 0.0
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowOpacity = 0.5
        self.layer.shadowRadius = 3.0
        self.layer.shadowOffset = CGSize(width: 0, height: 5.0)
    }
}