//
//  LoginVC.swift
//  KiiApp
//
//  Created by macbook on 16/09/2019.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class LoginVC: UIViewController {
    
    @IBOutlet weak var textFieldsView: UIView!
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var registerButton: UIButton!
    @IBOutlet weak var rightLineView: UIView!
    @IBOutlet weak var leftLineView: UIView!
   
    @IBOutlet weak var handsImageView_top: NSLayoutConstraint!
    
    //Constraints objects
    @IBOutlet weak var coverImageView_top: NSLayoutConstraint!
    @IBOutlet weak var handsImageView: UIImageView!
    @IBOutlet weak var whiteIconImageView_y: NSLayoutConstraint!
    @IBOutlet weak var registerButton_bottom: NSLayoutConstraint!
    
    var coverImageView_top_cache: CGFloat!
    var handsImageView_top_cache: CGFloat!
    var whiteIconImageView_y_cache: CGFloat!
    var registerButton_bottom_cache: CGFloat!
    
    
    
    //Executed when the scene is loaded
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        coverImageView_top_cache = coverImageView_top.constant
        handsImageView_top_cache = handsImageView_top.constant
        whiteIconImageView_y_cache = whiteIconImageView_y.constant
        registerButton_bottom_cache = registerButton_bottom.constant
       
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: Notification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: Notification.Name.UIKeyboardWillHide, object: nil)
    }
    
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        self.view.endEditing(false)
    }
    
    //executed once the keyboard is about to be shown
    @objc func keyboardWillShow(notification: Notification) {
        
        coverImageView_top.constant -= 75
        handsImageView_top.constant -= 75
        whiteIconImageView_y.constant += 50
        
        /*
        coverImageView_top.constant = -self.view.frame.width / 5.52
        handsImageView_top.constant = -self.view.frame.width / 5.52
        whiteIconImageView_y.constant = self.view.frame.width / 8.28
        */
        
        
        if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            registerButton_bottom.constant += keyboardSize.height
            //registerButton_bottom.constant = self.view.frame.width / 1.75423
        }
    
        
        
        UIView.animate(withDuration: 0.5) {
            
            self.handsImageView.alpha = 0
            
            self.view.layoutIfNeeded()
        }
        
    }
    @objc func keyboardWillHide(notification: Notification) {
        
        coverImageView_top.constant = coverImageView_top_cache
        handsImageView_top.constant = handsImageView_top_cache
        whiteIconImageView_y.constant = whiteIconImageView_y_cache
        
        //if let keyboardSize = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            registerButton_bottom.constant = registerButton_bottom_cache
       // }
        
        UIView.animate(withDuration: 0.5) {
            
            self.handsImageView.alpha = 1
            
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    //executed after aligning the object
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //Functions to be executed
        configure_textFieldView()
        configure_loginBtn()
        configure_orLabel()
        configure_registerButton()
    }
    
    
    func configure_textFieldView() {
        //Declare the contants to store information which will be assigned to 'object'
        let width = CGFloat(2)
        let color = UIColor.groupTableViewBackground.cgColor
        
        let border = CALayer()
        border.borderColor = color
        border.borderWidth = width
        border.frame = CGRect(x: 0, y: 0, width: textFieldsView.frame.width, height: textFieldsView.frame.height)
        
        let line = CALayer()
        line.borderWidth = width
        line.borderColor = color
        line.frame = CGRect(x: 0, y: textFieldsView.frame.height / 2 - width, width: textFieldsView.frame.width, height: width)
        
        //assigning layers to the view
        textFieldsView.layer.addSublayer(border)
        textFieldsView.layer.addSublayer(line)
        
        textFieldsView.layer.cornerRadius = 5
        textFieldsView.layer.masksToBounds = true
        
        
        
    }
    
    func configure_loginBtn() {
        
        loginButton.layer.cornerRadius = 15
        loginButton.layer.masksToBounds = true
        //loginButton.isEnabled = false
    }
    
    func configure_orLabel() {
        
        let width = CGFloat(1)
        let color = UIColor.groupTableViewBackground.cgColor
        //let color = UIColor.lightGray.cgColor
        
        let leftLine = CALayer()
        leftLine.borderWidth = width
        leftLine.borderColor = color
        leftLine.frame = CGRect(x: 0, y: leftLineView.frame.height / 2 - width, width: leftLineView.frame.width, height: width)
        
        let rightLine = CALayer()
        rightLine.borderWidth = width
        rightLine.borderColor = color
        rightLine.frame = CGRect(x: 0, y: rightLineView.frame.height / 2 - width, width: rightLineView.frame.width, height: width)
        
        leftLineView.layer.addSublayer(leftLine)
        rightLineView.layer.addSublayer(rightLine)
        
    }
    
    func configure_registerButton() {
        
        let border = CALayer()
        //border.borderColor = UIColor.black.cgColor
        border.borderColor = UIColor(red: 222/255, green: 220/255, blue: 222/255, alpha: 1).cgColor
        border.borderWidth = 1
        border.frame = CGRect(x: 0, y: 0, width: registerButton.frame.width, height: registerButton.frame.height)
        
        registerButton.layer.addSublayer(border)
        
        registerButton.layer.cornerRadius = 1
        registerButton.layer.masksToBounds = true
    }
    
    
    //Executed when the login button is clickeds
    @IBAction func loginButton_clicked(_ sender: Any) {
        
        let helper = Helper()
        
        if(helper.isValid(email: emailTextField.text!) == false){
            helper.showAlert(title: "Invalid email", message: "Please enter valid email", in: self)
            return
        } else if passwordTextField.text!.count < 6 {
            helper.showAlert(title: "Invalid password", message: "Password must contain at least 6 characters", in: self)
            return
        }
        loginRequest()
    }
    
    func loginRequest() {
        
        let url = URL(string: "http://localhost/KiiSite/login.php")!
        let body = "email=\(emailTextField.text!)&password=\(passwordTextField.text!)"
        
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
            
            
            let helper = Helper()
            
            if error != nil {
                
                helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                return
            }
            
            do {
                guard let data = data else {
                    helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                    return
                }
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                guard let parsedJSON = json else {
                    print("Parse Error")
                    return
                }
                if parsedJSON["status"] as! String == "200" {
                    
                    //Go to TabBar
                    helper.instatiateViewController(identifier: "TabBar", animated: true, by: self, completion: nil)
                    //Saving logged user
                    currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                    UserDefaults.standard.set(currentUser, forKey: "currentUser")
                    UserDefaults.standard.synchronize()
                    
                }
                else {
                    
                    if parsedJSON["message"] != nil {
                        
                        let message = parsedJSON["message"] as! String
                        helper.showAlert(title: "Error", message: message, in: self)
                    }
                }
                print(parsedJSON)
            }
            catch {
                
                helper.showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
            }
        }
        }.resume()
    }
}











