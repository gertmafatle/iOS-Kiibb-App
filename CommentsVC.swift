//
//  CommentsVC.swift
//  FaceBook
//
//  Created by MacBook Pro on 5/27/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class CommentsVC: UIViewController, UITextViewDelegate, UITableViewDelegate, UITableViewDataSource {
    
    // top bar obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    // var will store data passed from the previous / mother vc
    var avaImage = UIImage()
    var fullnameString = String()
    var dateString = String()
    
    // post bar obj
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var textLabel: UILabel!
    @IBOutlet weak var pictureImageView: UIImageView!
    
    // var will store data passed from the previous / mother vc
    var textString = String()
    var pictureImage = UIImage()
    
    // messaging bar obj
    @IBOutlet weak var commentTextView: UITextView!
    @IBOutlet weak var commentTextView_bottom: NSLayoutConstraint!
    @IBOutlet weak var commentTextView_height: NSLayoutConstraint!
    var commentsTextView_bottom_identity = CGFloat()
    
    // comment obj
    var post_id = Int()
    
    @IBOutlet weak var tableView: UITableView!
    var avas = [UIImage]()
    var avasURL = [String]()
    var fullnames = [String]()
    var comments = [String]()
    var ids = [Int]()
    var users_ids = [Int]()
    var postOwner_id = Int()
    
    
    var limit = 10
    var skip = 0
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // assigning to the objects values received from the previous vc
        avaImageView.image = avaImage
        fullnameLabel.text = fullnameString
        dateLabel.text = dateString
        
        textLabel.text = textString
        pictureImageView.image = pictureImage
        
        
        // if post is without the picture - resize the post
        if pictureImage.size.width == 0 {
            pictureImageView.removeFromSuperview()
            containerView.frame.size.height -= pictureImageView.frame.height
        }
        
        
        // taking the date received from the server and putting it in the following format to be recognized as being Date()
        let formatterGet = DateFormatter()
        formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let date = formatterGet.date(from: dateString)!
        
        // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
        let formatterShow = DateFormatter()
        formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
        dateLabel.text = formatterShow.string(from: date)
        
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        commentTextView.layer.cornerRadius = 10
        
        
        // cache the commentTextView's position
        commentsTextView_bottom_identity = commentTextView_bottom.constant
        
        
        // add notification observation
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 72
        
        
        // run functions
        loadComments()
        
    }
    
    
    // pre last func
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // remove observers of notification when the viewController is left
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    // exec-d once notification is caught -> KeyboardWillShow
    @objc func keyboardWillShow(_ notification: Notification) {
        
        // getting the size of the keyboard
        if let keyboard_size = (notification.userInfo?[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue {
            
            // increasing the bottom constraint by the keyboard's height
            commentTextView_bottom.constant += keyboard_size.height
            
        }
        
        // updating the layout with animation
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    // exec-d once notification is caught -> KeyboardWillHide
    @objc func keyboardWillHide() {
        
        // bring back the commentTextView to the initial position
        commentTextView_bottom.constant = commentsTextView_bottom_identity
        
        // updating the layout with animation
        UIView.animate(withDuration: 0.3) {
            self.view.layoutIfNeeded()
        }
        
    }
    
    
    // exec-d whenever delegated textView has been changed by chars
    func textViewDidChange(_ textView: UITextView) {
        
        // declaring new size of the textView. we increase the height
        let new_size = textView.sizeThatFits(CGSize.init(width: textView.frame.width, height: CGFloat(MAXFLOAT)))
        
        // assign new size to the textView
        textView.frame.size = CGSize.init(width: CGFloat(fmaxf(Float(new_size.width), Float(textView.frame.width))), height: new_size.height)
        
        // resize the textView
        self.commentTextView_height.constant = new_size.height
        
        //UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()
        //}
        
    }
    
    
    // exec-d when Send button has been pressed
    @IBAction func sendButton_clicked(_ sender: Any) {
        
        // insert new comment if there is some text
        if commentTextView.text.isEmpty == false && commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            insertComment()
        }
        
    }
    
    
    // returning number of rows in the tableView - number of comments
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comments.count
    }
    
    // assign data to the cell's objects
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell of the tableView
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CommentsCell
        
        // assigning data to the cell's objects
        cell.fullnameLabel.text = fullnames[indexPath.row]
        cell.commentLabel.text = comments[indexPath.row]
        
        
        // loading'n'caching avas
        let avaString = avasURL[indexPath.row]
        let avaURL = URL(string: avaString)!
        
        // not all avas have been cached
        if comments.count != avas.count {
            
            // request to download the image
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed to load broken image -> Cached Placeholder
                if error != nil {
                    let image = UIImage(named: "user.png")!
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }

                }
                
                // loaded successfully -> Cached User's Ava
                if let image = UIImage(data: data!) {
                    self.avas.append(image)
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                }
                
            }.resume()
            
        // all avas have been loaded, show them in the cell
        } else {
            cell.avaImageView.image = avas[indexPath.row]
        }
        
        
        return cell
        
    }
    
    // allow to edit cells
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        
        // shortcuts to unwrap vars
        let currentUserID_String = currentUser?["id"] as! String
        let currentUserID_Int = Int(currentUserID_String)
        let commentatorID = users_ids[indexPath.row]
        
        if commentatorID == currentUserID_Int {
            return true
        } else {
            return false
        }
        
    }
    
    // delcaring action for the deleting cell
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        
        // enable delete action of the cell - swipe to delete
        if editingStyle == .delete {
            
            // here cell / comment gets deleted
            deleteComment(indexPath: indexPath)
            
        }
        
    }
    
    
    // send a HTTP request to isnert the comment
    func insertComment() {
        
        // validating vars before sending to the server
        guard let user_id = currentUser?["id"] as? String, let ava = currentUser_ava, let avaPath = currentUser?["ava"] else {
            
            // converting url string to the valid URL
            if let url = URL(string: currentUser?["ava"] as! String) {
                
                // downloading all data from the URL
                guard let data = try? Data(contentsOf: url) else {
                    return
                }
                
                // converting donwloaded data to the image
                guard let image = UIImage(data: data) else {
                    return
                }
                
                // assigning image to the global var
                currentUser_ava = image
            }
            
            return
        }
        
        
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        let notification_body = "byUser_id=\(user_id)&user_id=\(postOwner_id)&type=comment&action=insert"
        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
        
        
        
        // refresh UI, add new comment in the front ed
        let firstName = (currentUser?["firstName"] as! String).capitalized
        let lastName = (currentUser?["lastName"] as! String).capitalized
        let fullname = firstName + " " + lastName
        let user_id_int = Int(user_id)!
        let comment = commentTextView.text.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // insert new comment into front-end's arrays
        users_ids.insert(user_id_int, at: comments.endIndex)
        avas.insert(ava, at: comments.endIndex)
        avasURL.insert(avaPath as! String, at: comments.endIndex)
        fullnames.insert(fullname, at: comments.endIndex)
        comments.insert(comment, at: comments.endIndex)
        
        // update tableView
        let indexPath = IndexPath(row: comments.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        // scroll to the bottom
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
        
        // empty textView and reload it
        commentTextView.text = ""
        textViewDidChange(commentTextView)
        
        // prepare request
        let url = URL(string: "http://localhost/fb/comments.php")!
        let body = "user_id=\(user_id)&post_id=\(post_id)&comment=\(comment)&action=insert"
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error happened
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    // converting received data from the server into json format
                    let json = try JSONSerialization.jsonObject(with: data!, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of casting json
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // if the status of JSON is 200 - success
                    if parsedJSON["status"] as! String == "200" {
                        
                        // accessing the latest / newest / just typed comment's id and appending to the array of all ids
                        let new_comment_id = parsedJSON["new_comment_id"] as! Int
                        self.ids.append(new_comment_id)
                        
                    } else {
                        Helper().showAlert(title: "400", message: parsedJSON["message"] as! String, in: self)
                        return
                    }
                
                // json error
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // load comments
    func loadComments() {
        
        // prepared request
        let url = URL(string: "http://localhost/fb/comments.php")!
        let body = "post_id=\(post_id)&limit=\(limit)&offset=\(skip)&action=select"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    
                    // safe mode of accessing / casting data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of accessing json
                    guard let parsedJSON = json?["comments"] as? [NSDictionary] else {
                        return
                    }
                    
                    
                    // loop to access every object (comment related pack of inf) and fetch certain data
                    for everyComment in parsedJSON {
                        
                        // formatting fullname (firstname + lastname)
                        let firstName = everyComment["firstName"] as! String
                        let lastName = everyComment["lastName"] as! String
                        let fullname = firstName + " " + lastName
                        
                        // appending fetched information to the segmented array
                        self.fullnames.append(fullname)
                        self.comments.append(everyComment["comment"] as! String)
                        self.avasURL.append(everyComment["ava"] as! String)
                        self.ids.append(everyComment["id"] as! Int)
                        self.users_ids.append(everyComment["user_id"] as! Int)
                    }
                    
                    // reload tableView with updated information
                    self.tableView.reloadData()
                    
                    // scroll to the latest index (latest cell -> bottom)
                    let indexPath = IndexPath(row: self.comments.count - 1, section: 0)
                    self.tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
                    
                // json error
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // for deleting cell and the comment from the databse
    func deleteComment(indexPath: IndexPath) {
        
        
        // access id of current user
        guard let user_id = currentUser?["id"] else {
            return
        }
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        let notification_body = "byUser_id=\(user_id)&user_id=\(postOwner_id)&type=comment&action=delete"
        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
        
        
        
        // prepare request
        let id = ids[indexPath.row]
        let url = URL(string: "http://localhost/fb/comments.php")!
        let body = "id=\(id)&action=delete"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        
        // remove the cell from the front-end
        // cleaning up the arrays (datas in the background of the app)
        avas.remove(at: indexPath.row)
        avasURL.remove(at: indexPath.row)
        fullnames.remove(at: indexPath.row)
        comments.remove(at: indexPath.row)
        ids.remove(at: indexPath.row)
        users_ids.remove(at: indexPath.row)
        
        // remove the cell
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        
        // launch request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // processing data and json
                do {
                    
                    // safe mode of accessing and fetching data from the server (fetching to a new const)
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                // json error
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    

    
    
    // back button has been pressed
    @IBAction func backButton_clicked(_ sender: Any) {
        
        // come back to previous vc with Show Segue
        navigationController?.popViewController(animated: true)
    }
    

}
