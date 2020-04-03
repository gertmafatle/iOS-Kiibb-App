//
//  BioVC.swift
//  FaceBook
//
//  Created by MacBook Pro on 4/14/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class BioVC: UIViewController, UITextViewDelegate {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var placeholderLabel: UILabel!
    @IBOutlet weak var counterLabel: UILabel!
    @IBOutlet weak var bioTextView: UITextView!
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // run funcs
        configure_avaImageView()
        loadUser()
        
    }
    
    
    // loads all user related information to be shown in the header
    func loadUser() {
        
        // safe method of accessing user related information in glob var
        guard let firstName = currentUser?["firstName"], let lastName = currentUser?["lastName"], let avaPath = currentUser?["ava"] else {
            return
        }
        
        // assigning vars which we accessed from global var, to fullnameLabel
        fullnameLabel.text = "\((firstName as! String).capitalized) \((lastName as! String).capitalized)" // "Bob Michael"
        
        // downloading the images and assigning to certain imageViews
        Helper().downloadImage(from: avaPath as! String, showIn: self.avaImageView, orShow: "user.png")
        
    }
    
    
    // configures appearance of avaImageView
    func configure_avaImageView() {
        
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }
    
    
    // executed whenever we are typing some text in the TextView object which has delegate relation with the viewControlelr
    func textViewDidChange(_ textView: UITextView) {
        
        // calculation of characters
        let allowed = 101
        let typed = textView.text.count
        let remaining = allowed - typed
        
        counterLabel.text = "\(remaining)/101"
        
        // if some text is in textView -> hide placeholder, otherwise, show it
        if textView.text.isEmpty {
            placeholderLabel.isHidden = false
        } else {
            placeholderLabel.isHidden = true
        }
        
    }
    
    
    // executed FIRSTLY whenever textView is about to be changed. return TRUE -> allow change, return FALSE -> do not allow
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        
        // do not allow white lines (breakes)
        guard text.rangeOfCharacter(from: CharacterSet.newlines) == nil else {
            return false
        }
        
        // stop entry while reached 101 character
        return textView.text.count + (text.count - range.length) <= 101
    }
    
    
    // runs when save button has been clicked
    @IBAction func saveButton_clicked(_ sender: Any) {
        
        // run updateBio function if there are no whitelines and white spaces
        if bioTextView.text.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines).isEmpty == false {
            self.updateBio()
        }
        
    }
    
    
    // updating bio by sending request to the server
    func updateBio() {
        
        // STEP 1. Access var / params to be sent to the server
        guard let id = currentUser?["id"], let bio = bioTextView.text else {
            return
        }
        
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        let notification_body = "byUser_id=\(id)&user_id=\(id)&type=bio&action=insert"
        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})

        
        
        // STEP 2. Declare URL, Request, Method, etc
        let url = URL(string: "http://localhost/fb/updateBio.php")!
        let body = "id=\(id)&bio=\(bio)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // STEP 3. Execute and Launch Request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // go to data and jsoning
                do {
                    
                    // save method of casting data received from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // STEP 4. Parse JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // save method of casting json
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // updated successfully
                    if parsedJSON["status"] as! String == "200" {
                        
                        // save updated user information in the app
                        currentUser = parsedJSON.mutableCopy() as? NSMutableDictionary
                        UserDefaults.standard.set(currentUser, forKey: "currentUser")
                        UserDefaults.standard.synchronize()
                        
                        // post notification -> update Bio on Home Page
                        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "updateBio"), object: nil)
                        self.dismiss(animated: true, completion: nil)
                    
                    // error while updating (e.g. Status = 400)
                    } else {
                        Helper().showAlert(title: "400", message: "Error while updating the bio", in: self)
                    }
                    
                // error while processing/accessing json
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                }
                
            }
            
        }.resume()
        
    }
    
    
    // cancel button has been clicked
    @IBAction func cancelButton_clicked(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
}
