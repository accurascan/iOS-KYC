//
//  MenuViewController.swift
//  CodeScan
//
//  Created by SSD on 07/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class MenuViewController: UIViewController,UITableViewDelegate,UITableViewDataSource
{

    @IBOutlet var tlbMenu: UITableView!

    override func viewDidLoad()
    {
        super.viewDidLoad()
        tlbMenu.register(MenuTableViewCell.nib(), forCellReuseIdentifier: MENU_TYPE_TVC)
        
//        tlbMenu.register(MenuTableViewCell.self, forCellReuseIdentifier: MENU_TYPE_TVC)
        tlbMenu.reloadData()
        tlbMenu.delegate = self
        tlbMenu.dataSource = self

    }
    override func viewWillAppear(_ animated: Bool)
    {
        UIView.beginAnimations("UpAnimation", context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.3)
        view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height: UIScreen.main.bounds.size.height)
        UIView.commitAnimations()
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func menuAction(_ sender: Any)
    {
        UIView.beginAnimations("UpAnimation", context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.3)
        view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height: UIScreen.main.bounds.size.height)
        UIView.commitAnimations()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3;
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
         let cell = tableView.dequeueReusableCell(withIdentifier: MENU_TYPE_TVC, for: indexPath) as! MenuTableViewCell
        switch indexPath.row
        {
            case 0:
                let str = "Contact Us"
                cell.lblMenu.text = str
                cell.menuImg.image = UIImage(named: "contact")
                break
            case 1:
                let str = "About Us"
                cell.lblMenu.text = str
                cell.menuImg.image = UIImage(named: "about")
                break
            case 2:
                let str = "Documents Supported"
                cell.lblMenu.text = str
                cell.menuImg.image = UIImage(named: "doc")
                break
            default:
                break
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    {
        switch indexPath.row
        {
            case 0:
                UIView.beginAnimations("UpAnimation", context: nil)
                UIView.setAnimationDelegate(self)
                UIView.setAnimationDuration(0.3)
                view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height:UIScreen.main.bounds.size.height)
                UIView.commitAnimations()
                let contactCodeVC = UIStoryboard(name: CODE_SCAN_VC, bundle: nil).instantiateViewController(withIdentifier: CONTACT_CODE_VC) as! ContactUsViewController
                navigationController?.pushViewController(contactCodeVC, animated: true)
                break
        case 1:
            UIView.beginAnimations("UpAnimation", context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.3)
            view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height:UIScreen.main.bounds.size.height)
            UIView.commitAnimations()
            let aboutCodeVC = UIStoryboard(name: CODE_SCAN_VC, bundle: nil).instantiateViewController(withIdentifier: ABOUT_CODE_VC) as! AboutUsViewController
            navigationController?.pushViewController(aboutCodeVC, animated: true)
            break
        case 2:
            UIView.beginAnimations("UpAnimation", context: nil)
            UIView.setAnimationDelegate(self)
            UIView.setAnimationDuration(0.3)
            view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height:UIScreen.main.bounds.size.height)
            UIView.commitAnimations()
            let docCodeVC = UIStoryboard(name: CODE_SCAN_VC, bundle: nil).instantiateViewController(withIdentifier: DOC_CODE_VC) as! DocumentViewController
            navigationController?.pushViewController(docCodeVC, animated: true)
            break
            default:
                break
        }
        
    }
    
    
}
