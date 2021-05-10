//
//  SelectCodeVC.swift
//  CodeScan
//
//  ******************** File use to display list of barcode (for select or deselect particular barcode) ******************

import UIKit
import AVFoundation
import AccuraOCR

protocol SelectedTypesDelegate {
    func setSelectedTypes(types: String)
}

class SelectCodeVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
   
    //MARK:- Outlet
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var viewBakGround: UIView!
    
    //MARK:- Variable
    var Types: [String] = ["ALL FORMATS","AZTEC","CODABAR","CODE 39","CODE 93","CODE 128","DATA MATRIX", "EAN-8", "EAN-13","ITF", "PDF417", "QR CODE", "UPC-A","UPC-E"]
    var selectedTypes: String = String()
    var selectedTypesDelegate: SelectedTypesDelegate!
    
    //MARK:- UIView Controller Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // border radius
//        [v.layer setCornerRadius:30.0f];
//        viewBakGround.layer.cornerRadius = 8
//        view.layer.borderColor = UIColor.lightGray.cgColor
//        viewBakGround.layer.borderWidth = 1
//        viewBakGround.layer.shadowColor = UIColor.blue.cgColor
//        viewBakGround.layer.shadowOffset = CGSize(width: 1, height: 1)
//        viewBakGround.layer.shadowRadius = 1.0
//        viewBakGround.autoresizingMask = [.flexibleWidth, .flexibleHeight]
//        Types =  Types.sorted()
        //Register tableView cell
        tableView.register(BarcodeTypeTVC.nib(), forCellReuseIdentifier: BARCODE_TYPE_TVC)
        
        addBarButton(imageNormal: BACK_WHITE, imageHighlighted: nil, action: #selector(backBtnPressed), side: .west)
    }
    override func viewWillAppear(_ animated: Bool) {
        if(UserDefaults.standard.value(forKey: "type") == nil) {
            UserDefaults.standard.setValue(Types[0], forKey: "type")
        }
        
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
    }
    
    //MARK:- UITableView Methods
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let barcodeTypeHFV = UIView()
        return barcodeTypeHFV
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Types.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let type = Types[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: BARCODE_TYPE_TVC, for: indexPath) as! BarcodeTypeTVC
        if let t = UserDefaults.standard.value(forKey: "type") {
            if (t as! String == type) {
                cell.setSelected(code: type)
            } else {
                cell.setUnselected(code: type)
            }
        } else {
            cell.setUnselected(code: type)
        }
       
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
        
        let type = Types[indexPath.row]
        selectedTypes.append(type)
        UserDefaults.standard.setValue(type, forKey: "type")
        selectedTypesDelegate.setSelectedTypes(types: type)
        
        selectedTypes.append(type)
        tableView.reloadData()
        
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK:- UIButton Action 
    @objc func backBtnPressed() {
//       selectedTypesDelegate.setSelectedTypes(types: )
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func backAction(_ sender: Any)
    {
        selectedTypesDelegate.setSelectedTypes(types: selectedTypes)
//        navigationController?.popViewController(animated: true)
        self.dismiss(animated: true, completion: nil)
    }
    
}


enum Direction: String {
    case north = "north"
    case northEast = "northEast"
    case east = "east"
    case southEast = "southEast"
    case south = "south"
    case southWest = "southWest"
    case west = "west"
    case northWest = "northWest"
    case center = "center"

}

extension UIViewController {
    
    func addBarButton(imageNormal: String, imageHighlighted: String?, action: Selector, side: Direction) {
        
        let button = UIButton(type: .custom)
        button.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        button.addTarget(self, action: action, for: .touchUpInside)
        if side == .center
        {

            button.backgroundColor = UIColor.btnRed
            button.setTitle("   Contact US   ", for: .normal)

        }
        else
        {
            button.setImage(UIImage(named: imageNormal), for: .normal)
        }
        if let img = imageHighlighted {
            button.setImage(UIImage(named: img), for: .highlighted)
        }
        
        var barButton: UIBarButtonItem!
        
        if side == .west {
            
            barButton = UIBarButtonItem(customView: button)
            self.navigationItem.leftBarButtonItem = barButton
            
        } else if side == .east {
            
            barButton = UIBarButtonItem(customView: button)
            self.navigationItem.rightBarButtonItem = barButton
        }
        else if side == .center
        {
            self.navigationItem.titleView = button
        }
    }

}
