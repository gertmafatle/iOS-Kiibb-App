//
//  PostVC.swift
//  FaceBook
//
//  Created by MacBook Pro on 4/20/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class PostVC: UIViewController, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    @IBOutlet weak var postTextView: UITextView!
    
    // code obj
    var isPictureSelected = false
    
    
    // loaded when the view is shown to the user
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUser()
    }
    
    
    // loaded after adjusting the layouts
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
    }
    
    
    // loading user
    func loadUser() {
        
        // safely accessing user related detailes ["key">"value"]
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"] else {
            return
        }
        
        // assigning accessed details to the functions which loads the user
        Helper().loadFullname(firstName: firstName as! String, lastName: lastName as! String, showIn: fullnameLabel)
        Helper().downloadImage(from: avaPath as! String, showIn: avaImageView, orShow: "user.png")
    }
    
    
    // tracks whenver textView gets changed
    func textViewDidChange(_ textView: UITextView) {
        
        // if textview isn't empty -> there's some text in textView, show the label, otherwise -> hide
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        
    }
    
    
    // launched when addPicture has been clicked
    @IBAction func addPicture_clicked(_ sender: Any) {
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
        
        // adding buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        
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
    
    
    // executed whenever the image has been picked via pickerController
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        // accessing selected image
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        // assigning selected image to pictureImageView
        pictureImageView.image = image
        
        // cast boolean as TRUE -> Picture Is Selected
        isPictureSelected = true
        
        // remove pickerController
        dismiss(animated: true, completion: nil)
    }
    
    
    // exec when pictureImageView has been tapped
    @IBAction func pictureImageView_tapped(_ sender: Any) {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            self.pictureImageView.image = UIImage()
        }
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        // present action sheet to the user finally
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    // exec whenever the screen has been tapped
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        postTextView.resignFirstResponder()
    }
    
    
    // once the button Share has been pressed
    @IBAction func shareButton_clicked(_ sender: Any) {
        
        // safe method to access 2 values to be sent to the server
        guard let id = currentUser?["id"], let text = postTextView.text else {
            return
        }
        
        // declaring keys and values to be sent to the server
        let params = ["user_id": id, "text": text]
        
        // declaring URL and request
        let url = URL(string: "http://localhost/fb/uploadPost.php")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        // web development and MIME Type of passing information to the web server
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        // access / convert image to Data for sending to the server
        var imageData = Data()
        
        // if picture has been selected, compress the picture before sending to the server
        if isPictureSelected {
            imageData = UIImageJPEGRepresentation(pictureImageView.image!, 0.5)!
        }
        
        // building the full body along with the string, text, file parameters
        request.httpBody = Helper().body(with: params, filename: "\(NSUUID().uuidString).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        // run the session
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // if error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // access data / json
                do {
                
                    // safe mode of accessing received data from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of accessing / casting JSON
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // if post is uploaded successfully -> come back to HomeVC, else -> show error message
                    if parsedJSON["status"] as! String == "200" {
                        
                        // post notification in order to update the posts of the user in other viewControllers
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
                        
                        // comeback
                        self.dismiss(animated: true, completion: nil)
                        
                    } else {
                        Helper().showAlert(title: "Error", message: parsedJSON["message"] as! String, in: self)
                        return
                    }
                    
                // error while accessing data / json
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
        
    }
    
    
    
    // exec-d when cancel button has been clicked
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
