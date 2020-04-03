//
//  EditVC.swift
//  FaceBook
//
//  Created by MacBook Pro on 5/4/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class EditVC: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    // ui obj
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var firstNameTextField: UITextField!
    @IBOutlet weak var lastNameTextField: UITextField!
    @IBOutlet weak var addBioButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var birthdayTextField: UITextField!
    @IBOutlet weak var genderTextField: UITextField!
    @IBOutlet weak var friendsSwitch: UISwitch!
    @IBOutlet weak var followSwitch: UISwitch!
    
    
    // code obj
    var imageViewTapped = ""
    var isCover = false
    var isAva = false
    var isPasswordChanged = false
    var isAvaChanged = false
    var isCoverChanged = false
    
    var datePicker: UIDatePicker!
    var genderPicker: UIPickerView!
    let genderPickerValues = ["Male", "Female"]
    
    
    // first load fund
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // call funcs
        configure_avaImageView()
        loadUser()
        
        
        // creating, configuring and implementing datePicker into BirthdayTextField
        datePicker = UIDatePicker()
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .year, value: -5, to: Date())
        datePicker.addTarget(self, action: #selector(self.datePickerDidChange(_:)), for: .valueChanged)
        birthdayTextField.inputView = datePicker
        
        // create and configure gender picker view for genderTextField
        genderPicker = UIPickerView()
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderTextField.inputView = genderPicker
        
    }
    
    
    // executed after laying out the viewController
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // call funcs
        configre_addBioButton()
    }
    
    
    // loads all user related information to be shown in the header
    @objc func loadUser() {

        print(currentUser)
        
       // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"],
            let lastName = currentUser?["lastName"],
            let email = currentUser?["email"],
            let birthday = currentUser?["birthday"] as? String,
            let gender = currentUser?["gender"] as? String,
            let avaPath = currentUser?["ava"],
            let coverPath = currentUser?["cover"],
            let allow_friends = currentUser?["allow_friends"] as? String,
            let allow_follow = currentUser?["allow_follow"] as? String
        else {
            return
        }
        
        
        // check in the front end is there any picture in the ImageView laoded from the server (is there a real html path / link to the image)
        if (avaPath as! String).count > 10 {
            isAva = true
        } else {
            avaImageView.image = UIImage(named: "user.png")
            isAva = false
        }
        
        if (coverPath as! String).count > 10 {
            isCover = true
        } else {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
            isCover = false
        }
        
        
        // check is currently user allowing friendship and follow
        // manipulate switchers based on the user's settings received from the server
        if Int(allow_friends) == 0 {
            friendsSwitch.isOn = false
        }
        
        if Int(allow_follow) == 0 {
            followSwitch.isOn = false
        }
        
        
        // assigning vars which we accessed from global var
        firstNameTextField.text = (firstName as! String).capitalized
        lastNameTextField.text = (lastName as! String).capitalized
        emailTextField.text = "\(email)"
        
        // downloading the images and assigning to certain imageViews
        Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        Helper().downloadImage(from: coverPath as! String, showIn: self.coverImageView, orShow: "HomeCover.jpg")
        
        
        
        // STEP 1 - To Show the Date in the UI format: To place string of date in the valid date format to convert to the Date Type
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss zzzz"
        let date = formatterGet.date(from: birthday)!
        
        // STEP 2 -To Show the Date in the UI format: To declare a new format of showing the date to the users
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMM dd, yyyy"
        birthdayTextField.text = formatterShow.string(from: date)
        
        
        // If the value in gender = 1, show Male or show Female
        if gender == "1" {
            genderTextField.text = "Male"
        } else {
            genderTextField.text = "Female"
        }
        
    }
    
    
    // configuring the appearance of AvaImageView
    func configure_avaImageView() {
        
        // creating layer that will be applied to avaImageView (layer - broders of ava)
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 5
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        // rounded corners
        avaImageView.layer.cornerRadius = 10
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
    }
    
    
    // will configre appearance of Add Bio Button
    func configre_addBioButton() {
        
        // creating constant named 'border' of type layer which acts as a border frame
        let border = CALayer()
        border.borderColor = UIColor.lightGray.cgColor
        border.borderWidth = 2
        border.frame = CGRect(x: 0, y: 0, width: addBioButton.frame.width, height: addBioButton.frame.height)
        
        // assign border to the obj (button)
        addBioButton.layer.addSublayer(border)
        
        // rounded corner
        addBioButton.layer.cornerRadius = 5
        addBioButton.layer.masksToBounds = true
        
    }
    
    
    
    // executed when Cover is tapped
    @IBAction func coverImageView_tapped(_ sender: Any) {
        
        // switching trigger
        imageViewTapped = "cover"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    
    // executed when Ava is tapped
    @IBAction func avaImageView_tapped(_ sender: Any) {
        
        // switching trigger
        imageViewTapped = "ava"
        
        // launch action sheet calling function
        showActionSheet()
    }
    
    
    // this function launches Action Sheet for the photos
    func showActionSheet() {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        
        // declaring camera button
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            // if camera available on device, than show
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                self.showPicker(with: .camera)
            }
            
        }
        
        
        // declaring library button
        let library = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            
            // checking availability of photo library
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                self.showPicker(with: .photoLibrary)
            }
            
        }
        
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // deleting profile picture (ava), by returning placeholder
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
                self.isAvaChanged = true
            } else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
                self.isCoverChanged = true
            }
            
        }
        
        
        // manipulating appearance of delete button for each scenarios
        if imageViewTapped == "ava" && isAva == false && imageViewTapped != "cover" {
            delete.isEnabled = false
        }
        
        if imageViewTapped == "cover" && isCover == false && imageViewTapped != "ava" {
            delete.isEnabled = false
        }
        
        
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
    }
    
    
    // takes us to the PickerController (Controller that allows us to select picture)
    func showPicker(with source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
    }
    
    
    // executed once the picture is selected in PickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // access image selected from pickerController
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // based on the trigger we are assigning selected pictures to the appropriated imageView
        if imageViewTapped == "cover" {
            
            // assign selected image to CoverImageView
            self.coverImageView.image = image
            
        } else if imageViewTapped == "ava" {
            
            // assign selected image to AvaImageView
            self.avaImageView.image = image
            
        }
        
        // completion handler, to communicate to the project that images has been selected (enable delete button)
        dismiss(animated: true) {
            if self.imageViewTapped == "cover" {
                self.isCover = true
                self.isCoverChanged = true
            } else if self.imageViewTapped == "ava" {
                self.isAva = true
                self.isAvaChanged = true
            }
        }
        
    }
    
    
    // executed whenever connected* textField has been changed
    @IBAction func textFieldDidChange(_ textField: UITextField) {
        
        // tracking is password changed or not
        if textField == passwordTextField {
            if isPasswordChanged == false {
                isPasswordChanged = true
            }
        }
        
    }
    
    
    // func will be executed whenever any date is selected
    @objc func datePickerDidChange(_ datePicker: UIDatePicker) {
        
        // declaring the format to be used in TextField while presenting the date
        let formatter = DateFormatter()
        formatter.dateStyle = DateFormatter.Style.medium
        birthdayTextField.text = formatter.string(from: datePicker.date)
        
    }
    
    
    // number of columns in the gender picker
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    // number of rows in the gender picker
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return genderPickerValues.count
    }
    
    // title for the row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return genderPickerValues[row]
    }
    
    // executed when picker selected
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        genderTextField.text = genderPickerValues[row]
        genderTextField.resignFirstResponder()
    }
    
    
    // exec-d when save button has been clicked
    @IBAction func saveButton_clicked(_ sender: Any) {
        
        // update user related info
        updateUser()
        
        // upload files
        if isAvaChanged == true {
            uploadImage(from: avaImageView, type: "ava") {
                Helper().showAlert(title: "Success!", message: "Ava has been updated", in: self)
            }
        }
        
        if isCoverChanged == true {
            uploadImage(from: coverImageView, type: "cover") {
                Helper().showAlert(title: "Success!", message: "Cover has been updated", in: self)
            }
        }
        
        // updating ava and cover at the same time (first update ava, then update cover)
        if isAvaChanged == true && isCoverChanged == true {
            
            // upload ava
            uploadImage(from: avaImageView, type: "ava") {
                
                // in completion handler we upload cover
                self.uploadImage(from: self.coverImageView, type: "cover", completion: {
                    
                    // in 2nd completion handler we show alert message
                    Helper().showAlert(title: "Success!", message: "Cover and Ava have been updated", in: self)
                })
                
            }
            
        }
        
    }
    
    
    // sends request to update user info
    func updateUser() {
        
        
        // access params / shortcuts
        guard let id = currentUser?["id"] else {
            return
        }
        
        
        // send notification to the server
        if isAvaChanged == true {
            
            // send notification to the server
            let notification_url = "http://localhost/fb/notification.php"
            let notification_body = "byUser_id=\(id)&user_id=\(id)&type=ava&action=insert"
            _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
            
        } else if isCoverChanged == true {
            
            // send notification to the server
            let notification_url = "http://localhost/fb/notification.php"
            let notification_body = "byUser_id=\(id)&user_id=\(id)&type=cover&action=insert"
            _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
            
        }
        
        
        
        let email = emailTextField.text!
        let firstName = firstNameTextField.text!
        let lastName = lastNameTextField.text!
        let birthday = datePicker.date
        let password = passwordTextField.text!
        
        var gender = ""
        if genderTextField.text == "Male" {
            gender = "1"
        } else {
            gender = "0"
        }
        
        // adjusting front end's logic to the backend's logic
        var allow_friends = ""
        if friendsSwitch.isOn == true {
            allow_friends = "1"
        } else {
            allow_friends = "0"
        }
        
        var allow_follow = ""
        if followSwitch.isOn == true {
            allow_follow = "1"
        } else {
            allow_follow = "0"
        }
        
        
        
        // logic of validation
        if Helper().isValid(email: email) == false {
            Helper().showAlert(title: "Invalid E-mail", message: "Please use valid E-mail address", in: self)
        } else if Helper().isValid(name: firstName) == false {
            Helper().showAlert(title: "Invalid name", message: "Please use valid name", in: self)
        } else if Helper().isValid(name: lastName) == false {
            Helper().showAlert(title: "Invalid surname", message: "Please use valid surname", in: self)
        } else if password.count < 6 {
            Helper().showAlert(title: "Invalid Password", message: "Password must contain at least 6 characters", in: self)
        }
        
        
        // prepare request
        let url = URL(string: "http://localhost/fb/updateUser.php")!
        let body = "id=\(id)&email=\(email)&firstName=\(firstName)&lastName=\(lastName)&birthday=\(birthday)&gender=\(gender)&newPassword=\(isPasswordChanged)&password=\(password)&allow_friends=\(allow_friends)&allow_follow=\(allow_follow)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        

        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    
                    // access data received from the server in the safe mode
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // convert data to being json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // cast json in the safe mode
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    
                    // show alert once saved
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving upaded user related information (e.g. ava's path, cover's path)
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        Helper().showAlert(title: "Success!", message: "Information has been saved", in: self)
                        
                        // sending notification to other vcs
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // sends request to the server to upload the Image (ava/cover)
    func uploadImage(from imageView: UIImageView, type: String, completion: @escaping () -> Void) {
        
        // save method of accessing ID of current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // STEP 1. Declare URL, Request and Params
        // url we gonna access (API)
        let url = URL(string: "http://localhost/fb/uploadImage.php")!
        
        // declaring reqeust with further configs
        var request = URLRequest(url: url)
        
        // POST - safest method of passing data to the server
        request.httpMethod = "POST"
        
        // values to be sent to the server under keys (e.g. ID, TYPE)
        let params = ["id": id, "type": type]
        
        // MIME Boundary, Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // if in the imageView is placeholder - send no picture to the server
        // Compressing image and converting image to 'Data' type
        var imageData = Data()
        
        if imageView.image != UIImage(named: "HomeCover.jpg") && imageView.image != UIImage(named: "user.png") {
            imageData = UIImageJPEGRepresentation(imageView.image!, 0.5)!
        }
        
        // assigning full body to the request to be sent to the server
        request.httpBody = Helper().body(with: params, filename: "\(type).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                
                do {
                    
                    // save mode of casting any data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // fetching JSON generated by the server - php file
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save method of accessing json constant
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // uploaded successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // saving upaded user related information (e.g. ava's path, cover's path)
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        // sending notification to other vcs
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateUser"), object: nil)
                        
                        completion()
                        
                        // error while uploading
                    } else {
                        
                        // show the error message in AlertView
                        if parsedJSON["message"] != nil {
                            let message = parsedJSON["message"] as! String
                            Helper().showAlert(title: "Error", message: message, in: self)
                        }
                        
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                }
                
            }
        }.resume()
        
    }
    
    
    // exec-d when cancel button has been clicked
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
