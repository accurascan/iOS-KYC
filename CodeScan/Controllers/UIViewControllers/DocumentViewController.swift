//
//  DocumentViewController.swift
//  CodeScan
//
//  Created by SSD on 08/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit

class DocumentViewController: UIViewController
{

    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.metallicSeaweed
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Menlo-Regular", size: 18.0)!]
        title = "Documents Supported"
        addBarButton(imageNormal: BACK_WHITE, imageHighlighted: nil, action: #selector(backBtnPressed), side: .west)

    }
    @objc func backBtnPressed()
    {
        self.navigationController?.popToRootViewController(animated: true);
        
    }
    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    

}
