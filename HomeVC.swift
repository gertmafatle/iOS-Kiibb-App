//
//  HomeVC.swift
//  KiiApp
//
//  Created by macbook on 06/12/2019.
//  Copyright © 2019 macbook. All rights reserved.
//

import UIKit

class HomeVC: UITableViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate {

    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var avaImageView: UIImageView!
    
    //Code Object
    var isCover = false
    var isAva = false
    var imageViewTapped = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        avaImageView_configure()

    }
    func avaImageView_configure() {
        
        //Layer applied to avaImageView
        let border = CALayer()
        border.borderColor = UIColor.white.cgColor
        border.borderWidth = 4
        border.frame = CGRect(x: 0, y: 0, width: avaImageView.frame.width, height: avaImageView.frame.height)
        avaImageView.layer.addSublayer(border)
        
        //Rounded corners
        avaImageView.layer.cornerRadius = 8
        avaImageView.layer.masksToBounds = true
        avaImageView.clipsToBounds = true
    }
    func showPicker(with source: UIImagePickerControllerSourceType) {
        
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        picker.sourceType = source
        present(picker, animated: true, completion: nil)
        
    }
    @IBAction func coverImageView_tapped(_ sender: Any) {
        
        imageViewTapped = "cover"
        
        showActionSheet()
        
    }
    
    @IBAction func avaImageView_tapped(_ sender: Any) {
        
        imageViewTapped = "ava"
        
        showActionSheet()
    }
    
    func showActionSheet() {
        
        let sheet = UIAlertController(title: nil, message: "", preferredStyle: .actionSheet)
        
        //Decalre camera button
        let camera = UIAlertAction(title: "Camera", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                
                self.showPicker(with: .camera)
            }
        }
        //Declare the library button
        let library = UIAlertAction(title: "Library", style: .default) { (action) in
            
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                
                self.showPicker(with: .photoLibrary)
            }
        }
        //Declare Cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        //Declare delelte button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
          
            if self.imageViewTapped == "ava" {
                self.avaImageView.image = UIImage(named: "user.png")
                self.isAva = false
            }else if self.imageViewTapped == "cover" {
                self.coverImageView.image = UIImage(named: "HomeCover.jpg")
                self.isCover = false
            }
        }
        //Appearence of delete button for every scinario
        if imageViewTapped == "ava" && isAva == false {
            delete.isEnabled = false
        } else if imageViewTapped == "cover" && isCover == false {
            delete.isEnabled = false
        }
        
        //Add buttons to the sheet
        sheet.addAction(camera)
        sheet.addAction(library)
        sheet.addAction(cancel)
        sheet.addAction(delete)
        
        //Present action sheet to the user
        self.present(sheet, animated: true, completion: nil)
    }
    
    //Executed once the image is selected in picker controller
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        //Access image selected from picker controller
        let image = info[UIImagePickerControllerEditedImage] as? UIImage
        
        if imageViewTapped == "cover" {
            self.coverImageView.image = image
            self.uploadImage(from: self.coverImageView)
        }else if imageViewTapped == "ava" {
            self.avaImageView.image = image
            self.uploadImage(from: avaImageView)
        }
        
        
        dismiss(animated: true) {
            
        if self.imageViewTapped == "cover" {
            self.isCover = true
        }else if self.imageViewTapped == "ava" {
            self.isAva = true
            }
        }
        
    }
    //Sends Request to the server to upload the image
    func uploadImage(from ImageView: UIImageView) {
        
        guard let id = currentUser?["id"] else {
            
            return
        }
        //Declare URL, Request, Parameters
        //Access URL(API)
        let url = URL(string: "http://localhost/KiiSite/image_upload.php")!
        
        var request = URLRequest(url: url)
        
        //Passing data to the server
        request.httpMethod = "POST"
        
        //Values to be sent to server
        let parameters = ["id": id, "type": imageViewTapped]
        
        //MIME Boundary or Header
        let boundary = "Boundary-\(NSUUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        //Image compression and conversion to 'Data' type
        let imageData = UIImageJPEGRepresentation(ImageView.image!, 0.5)!
        
        //Assigning full body to the request to be sent to server
        request.httpBody = Helper().body(with: parameters, filename: "\(imageViewTapped).jpg", filePathKey: "file", imageDataKey: imageData, boundary: boundary) as Data
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                if error != nil {
                    
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    //Save mode of casting any data
                    guard let data = data else {
                        
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    //Fetching json generated by the server
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    print(json ?? <#default value#>)
                }
                catch {
                    
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                }
            }
        }.resume()
        
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 0
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return 0
    }

}
