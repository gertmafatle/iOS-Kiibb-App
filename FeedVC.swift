//
//  FeedVC.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 8/14/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class FeedVC: UITableViewController {
    
    // posts obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var skip = 0
    var limit = 10
    var isLoading = false
    var liked = [Int]()
    
    // color obj
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 200
        
        
        // add observers for notifications
        NotificationCenter.default.addObserver(self, selector: #selector(loadNewPosts), name: NSNotification.Name(rawValue: "uploadPost"), object: nil)
        
        
        // run function
        loadPosts(offset: skip, limit: limit)
        
    }
    
    
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // hide navigation bar on Home Pagex
        navigationController?.setNavigationBarHidden(true, animated: true)
        
    }
    
    
    // exec-d when new post is published
    @objc func loadNewPosts() {
        
        // skipping 0 posts, as we want to load the entire feed. And we are extending Limit value based on the previous loaded posts.
        loadPosts(offset: 0, limit: skip + 1)
    }
    
    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the value (e.g. url) under the key 'picture' for every single element of the array (indexPath.row)
        let pictureURL = posts[indexPath.row]!["picture"] as! String
        
        // no picture in the post
        if pictureURL.isEmpty {
            
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "NoPicCell", for: indexPath) as! NoPicCell
            
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
            
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.dateLabel.text = formatterShow.string(from: date)
            
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.postTextLabel.text = text
            
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    
                    }.resume()
                
                // cached ava
            } else {
                
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            
            
            // picture logic
            pictures.append(UIImage())
            
            // get the index of the cell in order to get the certain post's id
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            
            // manipulating the appearance of the button based is the post has been liken or not
            DispatchQueue.main.async {
                if self.liked[indexPath.row] == 1 {
                    cell.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
                    cell.likeButton.tintColor = self.likeColor
                } else {
                    cell.likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
                    cell.likeButton.tintColor = UIColor.darkGray
                }
            }
            
            
            return cell
            
            
        // picture in the post
        } else {
            
            
            // accessing the cell from main.storyboard
            let cell = tableView.dequeueReusableCell(withIdentifier: "PicCell", for: indexPath) as! PicCell
            
            
            // fullname logic
            let firstName = posts[indexPath.row]!["firstName"] as! String
            let lastName = posts[indexPath.row]!["lastName"] as! String
            cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
            
            
            // date logic
            let dateString = posts[indexPath.row]!["date_created"] as! String
            
            // taking the date received from the server and putting it in the following format to be recognized as being Date()
            let formatterGet = DateFormatter()
            formatterGet.dateFormat = "yyyy-MM-dd HH:mm:ss"
            let date = formatterGet.date(from: dateString)!
            
            // we are writing a new readable format and putting Date() into this format and converting it to the string to be shown to the user
            let formatterShow = DateFormatter()
            formatterShow.dateFormat = "MMMM dd yyyy - HH:mm"
            cell.dateLabel.text = formatterShow.string(from: date)
            
            
            // text logic
            let text = posts[indexPath.row]!["text"] as! String
            cell.postTextLabel.text = text
            
            
            // avas logic
            let avaString = posts[indexPath.row]!["ava"] as! String
            let avaURL = URL(string: avaString)!
            
            // if there are still avas to be loaded
            if posts.count != avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.avas.append(image)
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    
                    }.resume()
                
                // cached ava
            } else {
                
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.avas[indexPath.row]
                }
            }
            
            
            // pictures logic
            let pictureString = posts[indexPath.row]!["picture"] as! String
            let pictureURL = URL(string: pictureString)!
            
            // if there are still pictures to be loaded
            if posts.count != pictures.count {
                
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.pictures.append(image)
                            
                            DispatchQueue.main.async {
                                cell.pictureImageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.pictures.append(image)
                        
                        DispatchQueue.main.async {
                            cell.pictureImageView.image = image
                        }
                    }
                    
                    }.resume()
                
                // cached picture
            } else {
                
                DispatchQueue.main.async {
                    cell.pictureImageView.image = self.pictures[indexPath.row]
                }
            }
            
            
            // get the index of the cell in order to get the certain post's id
            cell.likeButton.tag = indexPath.row
            cell.commentsButton.tag = indexPath.row
            cell.optionsButton.tag = indexPath.row
            
            
            // manipulating the appearance of the button based is the post has been liken or not
            DispatchQueue.main.async {
                if self.liked[indexPath.row] == 1 {
                    cell.likeButton.setImage(UIImage(named: "like.png"), for: .normal)
                    cell.likeButton.tintColor = self.likeColor
                } else {
                    cell.likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
                    cell.likeButton.tintColor = UIColor.darkGray
                }
            }
            
            
            return cell
            
        }
        
    }
    
    
    // loading posts from the server via@objc  PHP protocol
    func loadPosts(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)&action=feed"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
                do {
                    // access data - safe mode
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    print(json)
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts = posts
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip = posts.count
                    
                    
                    // clean up likes for the refetching
                    self.liked.removeAll(keepingCapacity: false)
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    
                    // reloading tableView to have an affect - show posts
                    self.tableView.reloadData()
                    
                    self.isLoading = false
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of the user : safe mode
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)&action=feed"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error occured
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                do {
                    // access data - safe mode
                    guard let data = data else {
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing json data - safe mode
                    guard let posts = json?["posts"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all successfully loaded posts to our Class Var - posts (after it got loaded successfully)
                    self.posts.append(contentsOf: posts)
                    
                    // we are skipping already loaded numb of posts for the next load - pagination
                    self.skip += posts.count
                    
                    
                    // logic of tracking liked posts
                    for post in posts {
                        if post["liked"] is NSNull {
                            self.liked.append(Int())
                        } else {
                            self.liked.append(1)
                        }
                    }
                    
                    
                    // reloading tableView to have an affect - show posts
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< posts.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            
            loadMore(offset: skip, limit: limit)
            
        }
        
    }
    
    
    // exec-ed when like button has been clicked
    @IBAction func likeButton_clicked(_ likeButton: UIButton) {
        
        
        // get the index of the cell in order to access relevat post's id
        let indexPathRow = likeButton.tag
        
        // access id of the current user
        guard let user_id = currentUser?["id"] else {
            return
        }
        
        // access id of the certain post which is related to the cell where the button like has been clicked
        guard let post_id = posts[indexPathRow]!["id"] else {
            return
        }
        
        // building logic / trigger / switcher to like or unlike the post
        var action = ""
        
        if liked[indexPathRow] == 1 {
            
            action = "delete"
            
            // keep in front-end that this post (at this indexPath.row) has been liken
            liked[indexPathRow] = Int()
            
            // change icon of the button
            likeButton.setImage(UIImage(named: "unlike.png"), for: .normal)
            likeButton.tintColor = UIColor.darkGray
            
        } else {
            
            action = "insert"
            
            // keep in front-end that this post (at this indexPath.row) has been liken
            liked[indexPathRow] = 1
            
            // change icon of the button
            likeButton.setImage(UIImage(named: "like.png"), for: .normal)
            likeButton.tintColor = likeColor
            
        }
        
        
        // animation of zooming / poping
        UIView.animate(withDuration: 0.15, animations: {
            
            // scale by 30% -> 1.3
            likeButton.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            
        }) { (completed) in
            
            // return to the initial state
            UIView.animate(withDuration: 0.15, animations: {
                likeButton.transform = CGAffineTransform.identity
            })
            
        }
        
        
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        var notification_body = ""
        
        if action == "insert" {
            notification_body = "byUser_id=\(user_id)&user_id=\(user_id)&type=like&action=insert"
        } else if action == "delete" {
            notification_body = "byUser_id=\(user_id)&user_id=\(user_id)&type=like&action=delete"
        }
        
        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
        
        
        
        // prepare request
        let url = URL(string: "http://localhost/fb/like.php")!
        let body = "post_id=\(post_id)&user_id=\(user_id)&action=\(action)"
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
                    // access in safe mode data received from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    let _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
            }.resume()
        
    }
    
    
    // exec-d when the Show Segue is about to be launched
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // getting index of the cell wherein comments button has been pressed in order to access the cell and track the index
        let indexPathRow = (sender as! UIButton).tag
        
        // accessing segue we need -> CommentsVC
        if segue.identifier == "CommentsVC" {
            
            // getting the fullname
            let firstName = posts[indexPathRow]!["firstName"] as! String
            let lastName = posts[indexPathRow]!["lastName"] as! String
            let fullname = firstName.capitalized + " " + lastName.capitalized
            
            // accessing destination ViewController -> CommentsVC
            let vc = segue.destination as! CommentsVC
            
            // assigning values to the vars of CommentsVC
            vc.avaImage = avas[indexPathRow]
            vc.fullnameString = fullname
            vc.dateString = posts[indexPathRow]!["date_created"] as! String
            
            vc.textString = posts[indexPathRow]!["text"] as! String
            
            // sending id of the post
            vc.post_id = posts[indexPathRow]!["id"] as! Int
            vc.postOwner_id = posts[indexPathRow]!["user_id"] as! Int
            
            // sending the image to the CommentsVC
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            
            guard let cell = tableView.cellForRow(at: indexPath) as? PicCell else {
                return
            }
            
            vc.pictureImage = cell.pictureImageView.image!
            
        }
        
    }
    
    
    // called when optionsButton has been clicked
    @IBAction func optionsButton_clicked(_ optionButton: UIButton) {
        
        // accessing indexPath.row of the cell
        let indexPathRow = optionButton.tag
        
        // accessing id of the post in order to specity it in the server
        let post_id = posts[indexPathRow]!["id"] as! Int
        let user_id = posts[indexPathRow]!["user_id"] as! Int
        
        // calling function which shows action sheet for reporting
        showReportSheet(post_id: post_id, user_id: user_id)
        
    }
    
    
    // calling actions sheet for reporting
    func showReportSheet(post_id: Int, user_id: Int) {
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating buttons
        let report = UIAlertAction(title: "Report", style: .default) { (action) in
            
            // declaring alert controller
            let alert = UIAlertController(title: "Report", message: "Please explain the reason", preferredStyle: .alert)
            
            // creating buttons
            let send = UIAlertAction(title: "Send", style: .default) { (action) in
                
                // accessing current user's id
                guard let currentUser_id = currentUser?["id"] else {
                    return
                }
                
                
                // access reason from alert's textField
                let textField = alert.textFields![0]
                
                // declaring url and body of url
                let url = "http://localhost/fb/report.php"
                let body = "post_id=\(post_id)&user_id=\(user_id)&reason=\(textField.text!)&byUser_id=\(currentUser_id)"
                
                // sends request to the server - global / common function
                _ = Helper().sendHTTPRequest(url: url, body: body, success: {
                    Helper().showAlert(title: "Success", message: "Report sent successfully", in: self)
                }, failure: {
                    Helper().showAlert(title: "Error", message: "Could not sent", in: self)
                })
                
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            
            // assigning buttons and adding textField
            alert.addAction(send)
            alert.addAction(cancel)
            alert.addTextField { (textField) in
                textField.placeholder = "I'm reporting because..."
                textField.font = UIFont(name: "HelveticaNeue-Regular", size: 17)
            }
            
            // showing alert controller
            self.present(alert, animated: true, completion: nil)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons
        sheet.addAction(report)
        sheet.addAction(cancel)
        
        // showing action sheet
        present(sheet, animated: true, completion: nil)
        
    }


}
