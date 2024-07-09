
import UIKit

class FirstViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    //MARK:- Outlet
    @IBOutlet weak var tblFirst: UITableView!
    
    //MARK:- View Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.isHidden = true
        self.tblFirst.register(UINib.init(nibName: "FirstTableViewCell", bundle: nil), forCellReuseIdentifier: "FirstTableViewCell")
    }
    
    override func viewDidDisappear(_ animated: Bool) {
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        navigationController?.navigationBar.isHidden = true
    }
    
    //MARK:- TableView Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 190
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FirstTableViewCell") as! FirstTableViewCell
        cell.selectionStyle = .none
        switch indexPath.row {
        case 0:
            cell.lblTitle.text = "OCR"
            cell.lblContect.text = "Recognizes Passports, Driving License & National ID'sFron All Countries. Works Offline"
            cell.view.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.view.layer.cornerRadius = 10
            cell.view.layer.masksToBounds = true
            cell.imageview2.image = UIImage(named: "ic_check")
            cell.view4.isHidden = true
            cell.viewarrow2.isHidden = true
            cell.imageViewArrow.isHidden = true
            cell.label1.text = "Scan"
            cell.label2.text = "Check"
            cell.label3.text = "Result"
            break
        case 1:
            cell.lblTitle.text = "FACE MATCH"
            cell.lblContect.text = "AI & ML Based Powerful Face Detection & Recognition Solution. 1:1 and 1:N. Works Offline"
            cell.view.backgroundColor = #colorLiteral(red: 0.6039215686, green: 0.6039215686, blue: 0.6039215686, alpha: 1)
            cell.view.layer.cornerRadius = 10
            cell.view.layer.masksToBounds = true
            cell.imageview2.image = UIImage(named: "icn_Liveness")
            cell.view4.isHidden = true
            cell.viewarrow2.isHidden = true
            cell.imageViewArrow.isHidden = true
            cell.label1.text = "Capture"
            cell.label2.text = "Biometric"
            cell.label3.text = "Result"
            break
        default:
            break
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        switch indexPath.row {
        case 0:
            // print("Accura OCR")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let ocrVC = MainStoryBoard.instantiateViewController(withIdentifier: "CountryNameViewController") as? CountryNameViewController
            appDelegate?.selectedScanType = .OcrScan
            if let ocrVC = ocrVC {
                navigationController?.pushViewController(ocrVC, animated: true)
            }
        case 1:
            // print("Face Match")
            let MainStoryBoard = UIStoryboard(name: "MainStoryboard_iPhone", bundle: nil)
            let faceVC = MainStoryBoard.instantiateViewController(withIdentifier: "FaceMatchViewController") as? FaceMatchViewController
            appDelegate?.selectedScanType = .FMScan
            if let faceVC = faceVC {
                navigationController?.pushViewController(faceVC, animated: true)
            }
        default:
            break
        }
        
    }
    
}

// Helper function inserted by Swift 4.2 migrator.
fileprivate func convertToUIApplicationOpenExternalURLOptionsKeyDictionary(_ input: [String: Any]) -> [UIApplication.OpenExternalURLOptionsKey: Any] {
    return Dictionary(uniqueKeysWithValues: input.map { key, value in (UIApplication.OpenExternalURLOptionsKey(rawValue: key), value)})
}
