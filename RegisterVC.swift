//
//  RegisterVC.swift
//  KiiApp
//
//  Created by macbook on 21/09/2019.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class RegisterVC: UIViewController {
    //Constraints objects
    @IBOutlet weak var contentView_width: NSLayoutConstraint!
    @IBOutlet weak var emailView_width: NSLayoutConstraint!
    @IBOutlet weak var nameView_width: NSLayoutConstraint!
    @IBOutlet weak var passwordView_width: NSLayoutConstraint!
    @IBOutlet weak var birthdayView_width: NSLayoutConstraint!
    @IBOutlet weak var genderView_width: NSLayoutConstraint!
   
    //UI objects
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    
    
    
    @IBOutlet weak var emailContinue_button: UIButton!
    @IBOutlet weak var fullnameContinue_button: UIButton!
    @IBOutlet weak var passwordContinue_button: UIButton!
    @IBOutlet weak var birthdayContinue_button: UIButton!
    @IBOutlet weak var femaleGender_button: UIButton!
    @IBOutlet weak var maleGender_button: UIButton!
    
    @IBOutlet weak var footerView: UIView!
    
    var datePicker: UIDatePicker!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //adjust width of the view for screen of the device
        contentView_width.constant = self.view.frame.width * 5
        
        emailView_width.constant = self.view.frame.width
        nameView_width.constant = self.view.frame.width
        passwordView_width.constant = self.view.frame.width
        birthdayView_width.constant = self.view.frame.width
        genderView_width.constant = self.view.frame.width
        
        cornerRadius(for: emailTextField)
        cornerRadius(for: firstNameTextField)
        cornerRadius(for: lastNameTextField)
        cornerRadius(for: passwordTextField)
        cornerRadius(for: birthdayTextField)
        
        cornerRadius(for: emailContinue_button)
        cornerRadius(for: fullnameContinue_button)
        cornerRadius(for: passwordContinue_button)
        cornerRadius(for: birthdayContinue_button)
        
        padding(for: emailTextField)
        padding(for: firstNameTextField)
        padding(for: lastNameTextField)
        padding(for: passwordTextField)
        padding(for: birthdayTextField)
        
        configure_footerView()
        
        //Date Picker
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.datePickerDidChange(_:)), for: .valueChanged)
        birthdayTextField.inputView = datePicker
        
        let swipe = UISwipeGestureRecognizer(target: self, action: #selector(self.handle(_:)))
        swipe.direction = .right
        self.view.addGestureRecognizer(swipe)
      
        
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(false)
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        DispatchQueue.main.async {
            
        self.configure_button(gender: self.maleGender_button)
        self.configure_button(gender: self.femaleGender_button)
            
        }
    }
    
    func cornerRadius(for view:UIView) {
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
    }
    
    func padding(for textField:UITextField) {
        
        let blankView = UIView.init(frame: CGRect(x: 0, y: 0, width: 10, height: 20))
        textField.leftView = blankView
        textField.leftViewMode = .always
    }
    
    func configure_footerView() {
        let topLine = CALayer()
        topLine.borderWidth = 1
        topLine.borderColor = UIColor(red: 222/255, green: 220/255, blue: 222/255, alpha: 1).cgColor
        topLine.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: 1)
        
        footerView.layer.addSublayer(topLine)
        
        
    }
    
    func configure_button(gender button: UIButton) {
        
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor(red: 222/255, green: 220/255, blue: 222/255, alpha: 1).cgColor
        border.frame = CGRect(x: 0, y: 0, width: button.frame.width, height: button.frame.height)
        
        button.layer.addSublayer(border)
        
        button.layer.cornerRadius = 2
        button.layer.masksToBounds = true
        
    }
    
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        let helper = Helper()
        
        if textField == emailTextField {
            
            if helper.isValid(email: emailTextField.text!) {
                emailContinue_button.isHidden = false
            }
        }else if textField == firstNameTextField || textField == lastNameTextField {
            if helper.isValid(name: firstNameTextField.text!) && helper.isValid(name: lastNameTextField.text!){
                fullnameContinue_button.isHidden = false
            }
            
        }else if textField == passwordTextField {
            if passwordTextField.text!.count >= 6 {
                passwordContinue_button.isHidden = false
                }
            }
            
        }
        
    
    
    
    @IBAction func emailContinueButton_clicked(_ sender: Any) {
        
        let position = CGPoint(x: self.view.frame.width, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        if firstNameTextField.text!.isEmpty {
            firstNameTextField.becomeFirstResponder()
            
        }else if lastNameTextField.text!.isEmpty {
            lastNameTextField.becomeFirstResponder()
        }else if firstNameTextField.text!.isEmpty == false && lastNameTextField.text!.isEmpty == false {
            firstNameTextField.resignFirstResponder()
            lastNameTextField.resignFirstResponder()
        }
     
    }
    
    
    
    @IBAction func fullnameContinueButton_clicked(_ sender: Any) {
        
        let position = CGPoint(x: self.view.frame.width * 2, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        if passwordTextField.text!.isEmpty {
            passwordTextField.becomeFirstResponder()
        }else if passwordTextField.text!.isEmpty == false {
            passwordTextField.resignFirstResponder()
        }
        
    }
    
    @IBAction func passwordContinueButton_clicked(_ sender: Any) {
        
        let position = CGPoint(x: self.view.frame.width * 3, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        if birthdayTextField.text!.isEmpty {
            birthdayTextField.becomeFirstResponder()
        }else if birthdayTextField.text!.isEmpty == false {
            birthdayTextField.resignFirstResponder()
        }
    }
    
    @objc func datePickerDidChange(_ datePicker:UIDatePicker) {
        
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        birthdayTextField.text = formatter.string(from: datePicker.date)
        
        let compareDateFormatter = DateFormatter()
        compareDateFormatter.dateFormat = "yyyy/MM/dd HH:mm"
        
        let compareDate = compareDateFormatter.date(from: "2013/01/01 00:01")
        
        if datePicker.date < compareDate! {
            birthdayContinue_button.isHidden = false
        }
        else {
            birthdayContinue_button.isHidden = true
        }
    }
    
    @IBAction func birthdayContinueButton_clicked(_ sender: Any) {
        
        let position = CGPoint(x: self.view.frame.width * 4, y: 0)
        scrollView.setContentOffset(position, animated: true)
        
        birthdayTextField.resignFirstResponder()
    }
    
    @objc func handle(_ gesture: UISwipeGestureRecognizer) {
        
        let current_x = scrollView.contentOffset.x
        
        let screen_width = self.view.frame.width
        
        let new_x = CGPoint(x: current_x - screen_width, y: 0)
        
        if current_x > 0 {
            
        scrollView.setContentOffset(new_x, animated: true)
            
        }
    }
    
    
    @IBAction func genderButton_clicked(_ sender: UIButton) {
        
        
        
        let url = URL(string: "http://localhost/KiiSite/register.php")!
        let body = "email=\(emailTextField.text!.lowercased())&firstName=\(firstNameTextField.text!.lowercased())&lastName=\(lastNameTextField.text!.lowercased())&password=\(passwordTextField.text!)&birthday=\(datePicker.date)&gender=\(sender.tag)"
        
        print(body)
        
        var request = URLRequest(url: url)
        
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            let helper = Helper()
            
            if error != nil {
                
                helper.showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                return
            }
            do {
                guard let data = data else{
                    helper.showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                
                guard let parsedJSON = json else{
                    print("Parsing Error")
                    return
                }
                if parsedJSON["status"] as! String == "200" {
                    
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
            }
            catch {
                
                helper.showAlert(title: "Json Error", message: error.localizedDescription, in: self)
            }
            
        }.resume()
    }
    
    
    @IBAction func cancelButton_clicked(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }

}
