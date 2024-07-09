
import UIKit
import ProgressHUD
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
    
    @IBOutlet weak var buttonOrtientation: UIButton!
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var lablelDataNotFound: UILabel!
    
    
    //MARK:- Variable
    var searchTxt = ""
    var arrCountryList = NSMutableArray()
    var isMRZCell = false
    var isPDFCell = false
    var isBankCard = false
    var isBarcode = false
    var accuraCameraWrapper: AccuraCameraWrapper? = nil
    
    //MARK:- View Controller Method
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let orientastion = UIApplication.shared.statusBarOrientation
        if(orientastion ==  UIInterfaceOrientation.portrait) {
            buttonOrtientation.isSelected = false
        } else {
            buttonOrtientation.isSelected = true
        }

        ProgressHUD.show("Loading...")
        lablelDataNotFound.isHidden = true
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        accuraCameraWrapper = AccuraCameraWrapper.init()
        DispatchQueue.global(qos: .default).async {
            self.getKeyValue(urlLicense: "https://dev.accurascan.com/mahdiedit/", pathLicense: "accura-config.json")
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    override func viewWillAppear(_ animated: Bool) {
        let orientastion = UIApplication.shared.statusBarOrientation
        if orientastion ==  UIInterfaceOrientation.landscapeLeft {
            buttonOrtientation.isSelected = true
        } else if orientastion == UIInterfaceOrientation.landscapeRight {
            buttonOrtientation.isSelected = true
        } else {
            buttonOrtientation.isSelected = false
        }
    }
    

    
    //MARK:- Button Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func buttonChangeOriwentation(_ sender: UIButton) {
        if(sender.isSelected == true) {
            sender.isSelected = false
            AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        } else {
            sender.isSelected = true
            AppDelegate.AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        }
        
    }

    func completion(path: String){
        DispatchQueue.main.async{

        let sdkModel = self.accuraCameraWrapper?.loadEngine(path,documentDirectory:NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String)
        if(sdkModel != nil)
        {
            //                if(sdkModel!.i < 0){
            //                    GlobalMethods.showAlertView("Invalid license", with: self)
            //                }
            
            if(sdkModel!.isMRZEnable)
            {
                self.isMRZCell = true
            }
            else{
                self.isMRZCell = false
            }
            if(sdkModel!.isBankCardEnable) {
                self.isBankCard = true
            } else {
                self.isBankCard = false
            }
            if(sdkModel!.isBarcodeEnable) {
                self.isBarcode = true
            } else {
                self.isBarcode = false
            }
        }
        if(self.isMRZCell)
        {
            self.arrCountryList.add("Passport MRZ")
            self.arrCountryList.add("ID card MRZ")
            self.arrCountryList.add("VISA MRZ")
            self.arrCountryList.add("All MRZ")
        }
        if(self.isBankCard) {
            self.arrCountryList.add("Bank Card")
            
        }
        if(self.isBarcode) {
            self.arrCountryList.add("Barcode")
        }
        let countryListStr = self.accuraCameraWrapper?.getOCRList()
        if(countryListStr != nil)
        {
            for i in countryListStr!{
                self.arrCountryList.add(i)
            }
        }
        else{
            //                GlobalMethods.showAlertView("", with: self)
        }
        
        if(sdkModel != nil){
            if sdkModel!.i > 0{
                self.accuraCameraWrapper?.setFaceBlurPercentage(80)
                self.accuraCameraWrapper?.setHologramDetection(true)
                self.accuraCameraWrapper?.setLowLightTolerance(10)
                self.accuraCameraWrapper?.setMotionThreshold(25)
                self.accuraCameraWrapper?.setGlarePercentage(6, intMax: 99)
                self.accuraCameraWrapper?.setBlurPercentage(60)
                self.accuraCameraWrapper?.setCameraFacing(.CAMERA_FACING_BACK)
            }
        }
            self.tblViewCountryList.delegate = self
            self.tblViewCountryList.dataSource = self
            self.tblViewCountryList.reloadData()
        }

        ProgressHUD.dismiss()

    }
    
    func getKeyValue(urlLicense: String, pathLicense: String){
        // Retrieve the stored value from UserDefaults
        var defaultVer = UserDefaults.standard.string(forKey: "defaulAccuraVersion")
        
        // Check if the stored value exists, otherwise set a default value
        if defaultVer == nil {
            defaultVer = "0.0"
            
            // Save the default value to UserDefaults
            UserDefaults.standard.set(defaultVer, forKey: "defaulAccuraVersion")
            UserDefaults.standard.synchronize()
        }

        let sema = DispatchSemaphore(value: 0)
        let serverUrl = "\(urlLicense)\(pathLicense)"
        
        if let url = URL(string: serverUrl) {
            var request = URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 10.0)
            request.httpMethod = "GET"
            
            let session = URLSession.shared
            
            let dataTask = session.dataTask(with: request) { (data, response, error) in
                if let error = error {
                    print(error)
                    sema.signal()
                    
//                    DispatchQueue.main.async {
                        let path = Bundle.main.path(forResource: "key", ofType: "license")
                    self.completion(path: path!)
//                    }
                } else {
                    if let httpResponse = response as? HTTPURLResponse {
                        do {
                            if let responseDictionary = try JSONSerialization.jsonObject(with: data!, options: []) as? [String: Any] {
                                if responseDictionary.isEmpty {
                                    let path = Bundle.main.path(forResource: "key", ofType: "license")
                                    self.completion(path: path!)
                                } else {
                                    if let version = responseDictionary["version"] as? String {
                                        if version.isEmpty {
                                            let path = Bundle.main.path(forResource: "key", ofType: "license")
                                            self.completion(path: path!)
                                        } else {
                                            if let platForm1 = responseDictionary["iOS"] as? [String: Any]{
//                                               let cardParams = platForm1["card_params"] as? [String: Any] {
                                                // ...

//                                                DispatchQueue.main.async {
                                                    var path: String?

                                                    if version == defaultVer {
                                                        if version == "0.0" {
                                                            path = Bundle.main.path(forResource: "key", ofType: "license")
                                                            UserDefaults.standard.set("key.license", forKey: "accuraKey")
                                                            UserDefaults.standard.set("accuraface.license", forKey: "accuraFaceKey")
                                                            UserDefaults.standard.set(path, forKey: "accurapath")
                                                            self.completion(path: path!)
                                                        } else {
                                                            let paths = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)
                                                            let documentsDirectory = paths[0]
                                                            path = "\(documentsDirectory)/\(UserDefaults.standard.string(forKey: "accuraKey") ?? "")"
                                                            self.completion(path: path!)
                                                        }
                                                    } else {
                                                        // Assuming this code is within the completion block after parsing the version
//                                                        DispatchQueue.global(qos: .default).async {
                                                            print("Downloading Started")
                                                            guard let platForm = responseDictionary["iOS"] as? [String: Any],
                                                                  let ocrLicense = platForm["ocr_license"] as? String,
                                                                  let faceLicense = platForm["face_license"] as? String else {
//                                                                DispatchQueue.main.async {
                                                                    let path = Bundle.main.path(forResource: "key", ofType: "license")
                                                                self.completion(path: path!)
//                                                                }
                                                                return
                                                            }

                                                            UserDefaults.standard.set(version, forKey: "accuraVersion")
                                                            UserDefaults.standard.set(ocrLicense, forKey: "accuraKey")
                                                            UserDefaults.standard.set(faceLicense, forKey: "accuraFaceKey")

                                                            let urlToDownload = urlLicense + ocrLicense
                                                            let urlToDownloadFace = urlLicense + faceLicense

                                                            guard let url = URL(string: urlToDownload),
                                                                  let urlFace = URL(string: urlToDownloadFace) else {
//                                                                DispatchQueue.main.async {
                                                                    let path = Bundle.main.path(forResource: "key", ofType: "license")
                                                                self.completion(path: path!)
//                                                                }
                                                                return
                                                            }

                                                            do {
                                                                let urlData = try Data(contentsOf: url)

                                                                if let urlDataFace = try? Data(contentsOf: urlFace) {
                                                        //            GL.setNo("1")

                                                                    let pathsFace = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                                    let documentsDirectoryFace = pathsFace[0]
                                                                    let pathFace = documentsDirectoryFace.appendingPathComponent(faceLicense)
                                                                    UserDefaults.standard.set(pathFace.path, forKey: "accuraFacepath")

//                                                                    DispatchQueue.main.async {
                                                                        do {
                                                                            try urlDataFace.write(to: pathFace, options: .atomic)
                                                                        } catch {
                                                                            print("Error writing face license file: \(error)")
                                                                        }
//                                                                    }
                                                                }

                                                                let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
                                                                let documentsDirectory = paths[0]
                                                                var path = documentsDirectory.appendingPathComponent(ocrLicense)

//                                                                DispatchQueue.main.async {
                                                                    do {
                                                                        try urlData.write(to: path, options: .atomic)
                                                                        self.completion(path: path.path)

                                                                        UserDefaults.standard.set(path.path, forKey: "accurapath")
                                                                        UserDefaults.standard.set(version, forKey: "defaulAccuraVersion")
                                                                        UserDefaults.standard.synchronize()
                                                                        print("File Saved!")
                                                                    } catch {
                                                                        DispatchQueue.main.async {
                                                                            let path = Bundle.main.path(forResource: "key", ofType: "license")
                                                                            self.completion(path: path!)
                                                                        }
                                                                    }
//                                                                }
                                                            } catch {
//                                                                DispatchQueue.main.async {
                                                                    let path = Bundle.main.path(forResource: "key", ofType: "license")
                                                                self.completion(path: path!)
//                                                                }
                                                            }
//                                                        }


                                                    }
//                                                }
                                            } else {
//                                                DispatchQueue.main.async {
                                                self.completion(path: "")
//                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        } catch {
                            print("Error parsing JSON: \(error)")
                        }
                    }
                }
            }
            
            dataTask.resume()
            sema.wait()
        }
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
            } else if(stringCell == "Bank Card") {
                let vc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                vc.isCheckScanOCR = true
                vc.cardType = 3
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
                if(stringCell == "Passport MRZ") {
                    vc.MRZDocType = 1
                } else if(stringCell == "ID card MRZ") {
                    vc.MRZDocType = 2
                } else if(stringCell == "VISA MRZ") {
                    vc.MRZDocType = 3
                } else {
                    vc.MRZDocType = 0
                }
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
