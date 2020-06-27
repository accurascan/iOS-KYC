//
//  PlaceHolderViewController.swift
//  CodeScan
//
//  Created by SSD on 07/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class PlaceHolderViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.metallicSeaweed
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Menlo-Regular", size: 18.0)!]
        title = "Accura Lines"
        addBarButton(imageNormal: MENU_WHITE, imageHighlighted: nil, action: #selector(menuBtnPressed), side: .west)
       
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
       
    }
    @objc func menuBtnPressed()
    {
        
        var control: MenuViewController?
        control = MenuViewController(nibName: "MenuViewController", bundle: nil)
        control?.view.frame = CGRect(x: -view.frame.size.width, y: 0, width: view.frame.size.width, height: UIScreen.main.bounds.size.height)
        if let aView = control?.view {
//            view.addSubview(aView)
            UIApplication.shared.keyWindow?.addSubview(aView)

        }
        control?.didMove(toParentViewController: self)
        if let aControl = control {
            addChildViewController(aControl)
        }
        UIView.beginAnimations("UpAnimation", context: nil)
        UIView.setAnimationDelegate(self)
        UIView.setAnimationDuration(0.2)
        control?.view.frame = CGRect(x: 0, y: 0, width: view.frame.size.width, height: UIScreen.main.bounds.size.height)
        UIView.commitAnimations()

        
    }

  

}
