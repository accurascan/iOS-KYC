//
//  ContactUsViewController.swift
//  CodeScan
//
//  Created by SSD on 07/06/18.
//  Copyright © 2018 Elite Development LLC. All rights reserved.
//

import UIKit
import SVProgressHUD
import Alamofire

class ContactUsViewController: UIViewController,UIPickerViewDelegate,UIPickerViewDataSource,UITextViewDelegate,UIAlertViewDelegate
{
    
    
    var fromCon = ""
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var country_list_picker: UIPickerView!
    @IBOutlet weak var txtMsg: UITextView!
    @IBOutlet weak var txtCountry: UITextField!
    @IBOutlet weak var txtCell: UITextField!
    @IBOutlet weak var txtEmailID: UITextField!
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtCompanyName: UITextField!
    var contry = ""
    // for picker data
    var pickerData: [String] = [String]()
    override func viewDidLoad()
    {
        super.viewDidLoad()
        navigationController?.navigationBar.tintColor = UIColor.white
        navigationController?.navigationBar.backgroundColor = UIColor.metallicSeaweed
        navigationController?.navigationBar.setBackgroundImage(nil, for: .default)
        navigationController?.navigationBar.titleTextAttributes = [NSAttributedStringKey.foregroundColor: UIColor.white, NSAttributedStringKey.font: UIFont(name: "Menlo-Regular", size: 18.0)!]
        title = "Contact US"
        addBarButton(imageNormal: BACK_WHITE, imageHighlighted: nil, action: #selector(backBtnPressed), side: .west)
        // add picker data
        pickerData = ["Afghanistan", "Albania", "Algeria", "Andorra", "Angola", "Antigua and Barbuda", "Argentina", "Armenia", "Aruba", "Australia", "Austria", "Azerbaijan", "Bahamas", "Bahrain", "Bangladesh", "Barbados", "Belarus", "Belgium", "Belize", "Benin", "Bhutan", "Bolivia", "Bosnia and Herzegovina", "Botswana", "Brazil", "Brunei", "Bulgaria", "Burkina Faso", "Burma", "Burundi", "Cambodia", "Cameroon", "Canada", "Cabo Verde", "Central African Republic", "Chad", "Chile", "China", "Colombia", "Comoros", "Czech Republic", "Costa Rica", "Cote d'Ivoire", "Croatia", "Cuba", "Curacao", "Cyprus", "Czechia", "Denmark", "Democratic Republic of Congo", "Djibouti", "Dominica", "Dominican Republic", "East Timor (see Timor-Leste)", "Ecuador", "Egypt", "El Salvador", "Equatorial Guinea", "Eritrea", "Estonia", "Ethiopia", "Fiji", "Finland", "France", "Gabon", "Gambia, The", "Georgia", "Germany", "Ghana", "Greece", "Grenada", "Guatemala", "Guinea", "Guinea-Bissau", "Guyana", "Haiti", "Holy See", "Honduras", "Hong Kong", "Hungary", "Iceland", "India", "Indonesia", "Iran", "Iraq", "Ireland", "Israel", "Italy", "Jamaica", "Japan", "Jordan", "Kazakhstan", "Kenya", "Kiribati", "Korea, North", "Korea, South", "Kosovo", "Kuwait", "Kyrgyzstan", "Laos", "Latvi", "Lebanon", "Lesotho", "Liberia", "Libya", "Liechtenstein", "Lithuania", "Luxembourg", "Macau", "Macedonia", "Madagascar", "Malawi", "Malaysia", "Maldives", "Mali", "Malta", "Marshall Islands", "Mauritania", "Mauritius", "Mexico", "Micronesia", "Monaco", "Mongolia", "Montenegro", "Morocco", "Mozambique", "Namibia", "Nauru", "Nepal", "Netherlands", "New Zealand", "Nicaragua", "Niger", "Nigeria", "North Korea", "Norway", "Oman", "Pakistan", "Palau", "Palestinian Territories", "Panama", "Papua New Guinea", "Paraguay", "Peru", "Philippines", "Poland", "Portugal", "Qatar", "Romania", "Russia", "Rwanda", "Saint Kitts and Nevis", "Saint Lucia", "Saint Vincent and the Grenadines", "Samoa", "San Marino", "Sao Tome and Principe", "Saudi Arabia", "Senegal", "Serbia", "Seychelles", "Sierra Leone", "Singapore", "Sint Maarten", "Slovakia", "Slovenia", "Solomon Islands", "Somalia", "South Africa", "South Korea", "South Sudan", "Spain", "Sri Lanka", "Sudan", "Suriname", "Swaziland", "Sweden", "Switzerland", "Syria", "Taiwan", "Tajikistan", "Tanzania", "Thailand", "Timor-Leste", "Togo", "Tonga", "Trinidad and Tobago", "Tunisia", "Turkey", "Turkmenistan", "Tuvalu", "Uganda", "Ukraine", "United Arab Emirates", "United Kingdom", "Uruguay", "Uzbekistan", "Vanuatu", "Venezuela", "Vietnam", "Yemen", "Zambia", "Zimbabwe"]
        country_list_picker.showsSelectionIndicator = true;
        country_list_picker.delegate = self;
        country_list_picker.isHidden = true;
        toolbar.isHidden = true;
        // txt place holder
        txtMsg.textColor = UIColor.white
        txtMsg.text = "LEAVE YOUR MESSAGE"
        txtMsg.delegate = self
        txtCompanyName.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        txtCountry.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        txtEmailID.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        txtCell.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")
        txtName.setValue(UIColor.white, forKeyPath: "_placeholderLabel.textColor")


    }

    override func didReceiveMemoryWarning()
    {
        super.didReceiveMemoryWarning()
    }
    @IBAction func cancelAction(_ sender: Any)
    {
        txtCountry.text = ""
        country_list_picker.isHidden = true
        toolbar.isHidden = true

    }
    @IBAction func doneAction(_ sender: Any)
    {
        if contry.count == 0
        {
            txtCountry.text = pickerData[0]
        }
        else
        {
            txtCountry.text = contry
        }
        country_list_picker.isHidden = true
        toolbar.isHidden = true

    }
    
    @IBAction func btnSend(_ sender: Any)
    {
        country_list_picker.isHidden = true;
        var str = txtCell.text!

        if(txtCompanyName.text?.characters.count == 0)
        {
            CommonErrorAlert().alert(info: "Please enter company name.", viewController: self)
        }
        else if(txtName.text?.characters.count == 0)
        {
            CommonErrorAlert().alert(info: "Please enter name.", viewController: self)
        }
        else if(txtEmailID.text?.characters.count == 0)
        {
            CommonErrorAlert().alert(info: "Please enter email.", viewController: self)
        }
        else if (!isValidEmail(testStr: txtEmailID.text!))
        {
            CommonErrorAlert().alert(info: "Invalid Email Address.", viewController: self)
        }
        else if((txtCell.text?.characters.count)! <= 0)
        {
            CommonErrorAlert().alert(info: "Please enter phone no.", viewController: self)
        }
        else if(txtCell.text!.characters.count > 12)
        {
            CommonErrorAlert().alert(info: "Please enter valid phone no.", viewController: self)
        }
        else if(txtCountry.text?.characters.count == 0)
        {
            CommonErrorAlert().alert(info: "Please select country.", viewController: self)
        }
        else if(txtMsg.text?.characters.count == 0)
        {
            CommonErrorAlert().alert(info: "Please leave your Message.", viewController: self)
        }
        else
        {
            self.callSignInWS();
        }
       
        

    }
    func isValidEmail(testStr:String) -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        
        let emailTest = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailTest.evaluate(with: testStr)
    }
    func callSignInWS() -> Void
    {
        if Reachability.isConnectedToNetwork() == false
        {
            CommonErrorAlert().alert(info: "Make sure your device is connected to the internet.", viewController: self)
        }
        else
        {
            SVProgressHUD.show()
            let parameters: [String: String] = ["name": txtName.text! , "company" : txtCompanyName.text! , "email" : txtEmailID.text! , "phone" : txtCell.text!,"country":txtCountry.text! ,"message":txtMsg.text!,"device_type":"1","accura_line":"1"]
//            let parameters: [String: String] = ["name": txtName.text! , "company" : txtCompanyName.text! , "email" : txtEmailID.text! , "phone" : txtCell.text!,"country":txtCountry.text! ,"message":txtMsg.text!,"device_type":"1"]
            let headers: HTTPHeaders = ["Apikey": "Qtm@1234"]
            AFWrapper.requestPOSTURL(Contact_US,  params:parameters as [String : AnyObject] , headers:headers , success:
                {
                    (JSON) -> Void in
                    print(JSON)
                    let ErrorCode : Int = JSON["status"].intValue
                     if(ErrorCode == 1)
                    {
                        SVProgressHUD.dismiss()

                        let alertView = UIAlertView(title: APP_NAME, message: JSON["message"].string!, delegate: self, cancelButtonTitle: "OK", otherButtonTitles: "Cancel")
                        alertView.delegate = self
                        alertView.tag = 10003
                        alertView.show()
                    }
                    else
                     {
                        SVProgressHUD.dismiss()
                        CommonErrorAlert().alert(info: JSON["message"].string!, viewController: self)
                        self.txtCountry.text="";
                        self.txtCell.text="";
                        self.txtName.text="";
                        self.txtEmailID.text="";
                        self.txtCompanyName.text="";
                        self.txtMsg.text="";
                    }

                    
            })
            {
                (Error) -> Void in
                print(Error)
                CommonErrorAlert().alert(info: Error as! String, viewController: self)
            }
            
        }
    }
    func alertView(_ alertView: UIAlertView, clickedButtonAt buttonIndex: Int) {
        if alertView.tag == 10003 {
            if 0 == buttonIndex {
                //cancel button
                txtCountry.text = ""
                txtCell.text = ""
                txtName.text = ""
                txtEmailID.text = ""
                txtCompanyName.text = ""
                txtMsg.text = ""
                navigationController?.popToRootViewController(animated: true)
            } else if 1 == buttonIndex {
                
            }
        }
    }

    @objc func backBtnPressed()
    {
        if fromCon == "1" {
            self.navigationController?.popViewController(animated: true)
        }
        else
        {
            self.navigationController?.popToRootViewController(animated: true);
        }
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return pickerData[row] as? String
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        //tag chage
        contry = pickerData[row]
    }
    @IBAction func btnContry(_ sender: Any)
    {
        view.endEditing(true)
        country_list_picker.isHidden = false
        toolbar.isHidden = false
    }
    //textfiled delegate
    func textFieldDidBeginEditing(_ textField: UITextField) {
        print("done")
        country_list_picker.isHidden = true
        toolbar.isHidden = true
    }
    // text view delegate
    func textViewShouldBeginEditing(_ textView: UITextView) -> Bool {
        //        [self keyBoardAppeared];
        txtMsg.text = ""
        txtMsg.textColor = UIColor.white
        country_list_picker.isHidden = true
        toolbar.isHidden = true
        return true
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //    [self keyBoardDisappeared];
        return true
    }
    func textViewDidChange(_ textView: UITextView) {
        country_list_picker.isHidden = true
        toolbar.isHidden = true
        if txtMsg.text.count == 0
        {
            txtMsg.textColor = UIColor.white
            txtMsg.text = "LEAVE YOUR MESSAGE"
            txtMsg.resignFirstResponder()
        }
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        country_list_picker.isHidden = true
        toolbar.isHidden = true
        if (text == "\n") {
            textView.resignFirstResponder()
            if txtMsg.text.count == 0 {
                txtMsg.textColor = UIColor.white
                txtMsg.text = "LEAVE YOUR MESSAGE"
                txtMsg.resignFirstResponder()
            }
            return false
        }
        return true
    }


    
    
}
