//
//  AboutUsViewController.swift
//  CodeScan
//
//  Created by SSD on 08/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit
import SVProgressHUD

class AboutUsViewController: UIViewController,UIWebViewDelegate
{

    @IBOutlet weak var web: UIWebView!
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.metallicSeaweed
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Menlo-Regular", size: 18.0)!]
        title = "About US"
        addBarButton(imageNormal: BACK_WHITE, imageHighlighted: nil, action: #selector(backBtnPressed), side: .west)
        web.delegate = self;
        let websiteUrl = URL(string: "https://accurascan.com/about")
        var urlRequest: URLRequest? = nil
        if let anUrl = websiteUrl {
            urlRequest = URLRequest(url: anUrl)
        }
        if let aRequest = urlRequest {
            web.loadRequest(aRequest)
        }


    }
    override func viewDidDisappear(_ animated: Bool) {
        SVProgressHUD.dismiss()

    }
    @objc func backBtnPressed()
    {
        self.navigationController?.popToRootViewController(animated: true);
        
    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    func webViewDidStartLoad(_ webView: UIWebView) {
        SVProgressHUD.show()

    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        SVProgressHUD.dismiss()
    }


}
