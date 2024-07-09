
import UIKit
import Foundation

class DrivingPDF: UIView,UITableViewDataSource,UITableViewDelegate {

    //MARK:- Variable
    var keyArr = [String]()
    var valueArr = [String]()
   
    //MARK:- Outlet
    @IBOutlet weak var tblpdf: UITableView!
    
    //MARK:- Tableview Methods
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{

         return keyArr.count
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
       
        return 1
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       
        let cell = tableView.dequeueReusableCell(withIdentifier: "drivePDF", for: indexPath) as! DrivePDFTableViewCell
        
        cell.lblpreTitle.text = keyArr[indexPath.row] as  String;
        cell.lblValuetitle.text = valueArr[indexPath.row] as  String;
        

       return cell
    }
   
    //MARK:- UIView load methods
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        
        layer.cornerRadius = 3.0
        //Set tableView height
        tblpdf.estimatedRowHeight = 65.0;
        tblpdf.rowHeight = UITableView.automaticDimension
        
        //Register tableview cell
        tblpdf.register(UINib(nibName: "DrivePDFTableViewCell", bundle: nil), forCellReuseIdentifier: "drivePDF")
        tblpdf!.dataSource = self
  
    }

    class func nib() -> DrivingPDF {
        
        return UINib(nibName: self.nameOfClass, bundle: nil).instantiate(withOwner: nil, options: nil)[0] as! DrivingPDF
    }
    
    //MARK:- Button Action
    @IBAction func btnokpress(_ sender: Any) {
        
    }
    
    


}
