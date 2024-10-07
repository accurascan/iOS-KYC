
import UIKit
import AccuraOCR

struct CardType {
    let id : Int?
    let card_type : String?
    
    init( id:Int, card_type:String) {
        self.id = id
        self.card_type = card_type
    }
}

class ListViewVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
    //MARK:- Outlet
    @IBOutlet var tblList: UITableView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var viewNavigationBar: UIView!
    @IBOutlet weak var viewStatusBar: UIView!
    @IBOutlet weak var btnBack: UIButton!
    @IBOutlet weak var buttonOrientation: UIButton!
    
    //MARK:- Variable
    var screenList = NSMutableArray()
    var arrResponse : [[String:AnyObject]] = [[String:AnyObject]]()
    var countryId : Int? = 0
    var cardtype: Int? = 0
    
    //MARK:- ViewController
    override func viewDidLoad() {
        super.viewDidLoad()
        viewStatusBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        viewNavigationBar.backgroundColor = UIColor(red: 231.0 / 255.0, green: 52.0 / 255.0, blue: 74.0 / 255.0, alpha: 1.0)
        self.tblList.register(UINib.init(nibName: "ListTableCell", bundle: nil), forCellReuseIdentifier: "ListTableCell")
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        let orientation = UIApplication.shared.statusBarOrientation
        if(orientation ==  UIInterfaceOrientation.portrait) {
            buttonOrientation.isSelected = false
        } else {
            buttonOrientation.isSelected = true
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        // print("Success")
    }
    
    //MARK:- Button Action
    @IBAction func btnBackAction(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func buttoOrientationAction(_ sender: UIButton) {
        if(sender.isSelected == true) {
            sender.isSelected = false
            AppDelegate.AppUtility.lockOrientation(.portrait, andRotateTo: .portrait)
        } else {
            sender.isSelected = true
            AppDelegate.AppUtility.lockOrientation(.landscapeRight, andRotateTo: .landscapeRight)
        }
    }
    
    //MARK: UITableView Delegate and Datasource method
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return screenList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ListTableCell") as! ListTableCell
        cell.selectionStyle = .none
        let cellDict = screenList.object(at: indexPath.row) as! NSDictionary
            cell.lbl_list_title.text = "\(String(describing: (cellDict.value(forKey: "card_name"))!))"
            cell.vw.backgroundColor = #colorLiteral(red: 0.8352941176, green: 0.1960784314, blue: 0.2470588235, alpha: 1)
            cell.vw.layer.masksToBounds = true
    
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cellDict = screenList.object(at: indexPath.row) as! NSDictionary
            let vc: ViewController = self.storyboard?.instantiateViewController(withIdentifier: "ViewController") as! ViewController
            vc.cardid = cellDict.value(forKey: "card_id") as? Int
            vc.docName = (cellDict.value(forKey: "card_name") as? String)!
            vc.countryid = countryId
            vc.isCheckScanOCR = true
            
            vc.cardType = cellDict.value(forKey: "card_type") as? Int//cardtype
            
            self.navigationController?.pushViewController(vc, animated: true)
    }
    
}
