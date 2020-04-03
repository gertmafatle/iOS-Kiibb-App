//
//  GuestVC.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 7/5/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit


class GuestVC: UITableViewController {
    
    
    // ui obj
    @IBOutlet weak var headerView: UIView!
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var coverImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var bioLabel: UILabel!
    
    // button obj
    @IBOutlet weak var friendButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!
    
    // vars to catch recevied / passed data
    var id = Int()
    var firstName = String()
    var lastName = String()
    var avaPath = String()
    var coverPath = String()
    var bio = String()
    var allow_friends = Int()
    var allow_follow = Int()
    var isFollowed = Int()
    
    
    // post obj
    var posts = [NSDictionary?]()
    var avas = [UIImage]()
    var pictures = [UIImage]()
    var liked = [Int]()
    var skip = 0
    var limit = 10
    var isLoading = false
    
    // colors
    let likeColor = UIColor(red: 28/255, green: 165/255, blue: 252/255, alpha: 1)
    
    // trigger to check is guest requested to be a friend or not
    var friendshipStatus = 0
   
    
    // first load
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // apply new custom property to the bar button to make title under the icom / image
        friendButton.centerVertically(gap: 10)
        followButton.centerVertically(gap: 10)
        messageButton.centerVertically(gap: 10)
        moreButton.centerVertically(gap: 10)
        
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 536
        
        
        // run functions
        configure_avaImageView()
        loadUser()
        loadPosts(offset: skip, limit: limit)
        
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
    
    
    // loads all user related information
    func loadUser() {
        
        // show placeholder if no proper url to load ava or cover (if no ava or cover)
        if avaPath.count < 10 {
            avaImageView.image = UIImage(named: "user.png")
        } else {
            Helper().downloadImage(from: avaPath, showIn: avaImageView, orShow: "user.png")
        }
        
        if coverPath.count < 10 {
            coverImageView.image = UIImage(named: "HomeCover.jpg")
        } else {
            Helper().downloadImage(from: coverPath, showIn: coverImageView, orShow: "HomeCover.jpg")
        }
        
        
        // manipulating buttons based on the privacy settings of the guest user
        if allow_friends == 0 {
            friendButton.isEnabled = false
        }
        if allow_follow == 0 {
            followButton.isEnabled = false
        }
        
        
        // if guest user is followed, show followed icon in the button
        if isFollowed != Int() {
            update(button: followButton, icon: "follow.png", title: "Following", color: Helper().facebookColor)
            followButton.isEnabled = true
        }
        
        
        
        // assign fullname
        fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        // assign bio and manipulate the height of headerView
        bioLabel.text = bio
        
        if bio.isEmpty {
            headerView.frame.size.height -= 40
        }
        
        
        // manipulate the apperance of addFriend Button based on has request been sent or not
        // not requested
        if friendshipStatus == 0 {
            
            update(button: friendButton, icon: "unfriend.png", title: "Add", color: .darkGray)
            
        // current user got requested by the guest (guest-user)
        } else if friendshipStatus == 1 {
            
            update(button: friendButton, icon: "request.png", title: "Requested", color: Helper().facebookColor)
            
        // user requested current user to be his friend
        } else if friendshipStatus == 2 {
            
            update(button: friendButton, icon: "respond.png", title: "Respond", color: Helper().facebookColor)
            
        // they are friends
        } else if friendshipStatus == 3 {
            
            update(button: friendButton, icon: "friends.png", title: "Friends", color: Helper().facebookColor)
            
        }
        
    }

    
    // number of cells in tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }

    
    // main configuration of each / reusable cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
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
        if let avaURL = URL(string: avaString) {
        
            // if there are still avas to be loaded
            if posts.count != avas.count {
            
                URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                    DispatchQueue.main.async {
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                self.avas.append(image)
                                cell.avaImageView.image = image
                            }
                        
                        }
                    
                        // downloaded
                        if let image = UIImage(data: data!) {
                            self.avas.append(image)
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
            
        // unable to convert empty string (or whatever the reason) to be a proper url
        } else {
            
            // append array of avas with the placeholder image
            let placeholderImage = UIImage(named: "user.png")!
            self.avas.append(placeholderImage)
            
        }
        
        
        // pictures logic
        let pictureString = posts[indexPath.row]!["picture"] as! String
        if let pictureURL = URL(string: pictureString) {
        
            // if there are still pictures to be loaded
            if posts.count != pictures.count {
            
                URLSession(configuration: .default).dataTask(with: pictureURL) { (data, response, error) in
                    DispatchQueue.main.async {
                        // failed downloading - assign placeholder
                        if error != nil {
                            self.pictures.append(UIImage())
                            cell.pictureImageView.image = UIImage()
                        }
                
                        // downloaded
                        if let image = UIImage(data: data!) {
                            self.pictures.append(image)
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
            
        // unable to convert empty string (or whatever the reason) to be a proper url
        } else {
            
            // blank image in the backend array (no image)
            self.pictures.append(UIImage())
            
            // resize picture's height -> resize cell (as per auto layout)
            cell.pictureImageView_height.constant = 0
            cell.updateConstraints()
            
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
    
    
    // loading posts from the server via@objc  PHP protocol
    func loadPosts(offset: Int, limit: Int) {
        
        isLoading = true
        
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
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
    
    
    // executed always whenever tableView is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            
            loadMore(offset: skip, limit: limit)
            
        }
        
    }
    
    
    // loading more posts from the server via PHP protocol
    func loadMore(offset: Int, limit: Int) {
        
        isLoading = true
        
        
        // prepare request
        let url = URL(string: "http://localhost/fb/selectPosts.php")!
        let body = "id=\(id)&offset=\(offset)&limit=\(limit)"
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
            notification_body = "byUser_id=\(user_id)&user_id=\(self.id)&type=like&action=insert"
        } else if action == "delete" {
            notification_body = "byUser_id=\(user_id)&user_id=\(self.id)&type=like&action=delete"
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
        
        // getting index of the cell wherein comments button has been pressed
        let indexPathRow = (sender as! UIButton).tag
        
        // accessing segue we need -> CommentsVC
        if segue.identifier == "CommentsVC" {
            
            // accessing destination ViewController -> CommentsVC
            let commentsvc = segue.destination as! CommentsVC
            
            // assigning values to the vars of CommentsVC
            commentsvc.avaImage = avaImageView.image!
            commentsvc.fullnameString = fullnameLabel.text!
            commentsvc.dateString = posts[indexPathRow]!["date_created"] as! String
            
            commentsvc.textString = posts[indexPathRow]!["text"] as! String
            
            // sending id of the post
            commentsvc.post_id = posts[indexPathRow]!["id"] as! Int
            commentsvc.postOwner_id = posts[indexPathRow]!["user_id"] as! Int
            
            // sending the image to the CommentsVC
            let indexPath = IndexPath(item: indexPathRow, section: 0)
            
            commentsvc.pictureImage = pictures[indexPath.row]
            
            
            // hide navigation bar in commentsVC
            navigationController?.setNavigationBarHidden(true, animated: true)
            
        }
        
    }
    
    
    // pre load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
    }
    
    
    // update the button and all its configuration
    func update(button: UIButton, icon: String, title: String, color: UIColor) {
        
        // background of the button
        let image = UIImage(named: icon)
        
        // button configuration
        button.setBackgroundImage(image, for: .normal)
        button.tintColor = color
        button.setTitle(title, for: .normal)
        button.titleLabel?.textColor = color
        
        // animation of zooming / poping
        UIView.animate(withDuration: 0.15, animations: {
            
            // scale by -20%
            button.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { (completed) in
            
            // return to the initial state
            UIView.animate(withDuration: 0.15, animations: {
                button.transform = CGAffineTransform.identity
            })
            
        }
        
    }
    
    
    // update status of the requests
    func updateFriendshipRequest(with action: String, user_id: Any, friend_id: Any) {
        
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        var notification_body = ""
        
        if action == "confirm" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=insert"
        } else if action == "delete" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=delete"
        } else if action == "follow" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=follow&action=insert"
        } else if action == "unfollow" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=follow&action=delete"
        }
        
        _ = Helper().sendHTTPRequest(url: notification_url, body: notification_body, success: {}, failure: {})
        
        
        // preparing request
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=\(action)&user_id=\(user_id)&friend_id=\(friend_id)"
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
                
                // go to the data and responses received from the server
                do {
                    // safe mode to access / cast data received from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of casting json
                    guard let parsedJSON = json else {
                        return
                    }
                    
                    // if request is inserted into server successfully, sent notification to FriendVC to update the status of request
                    if parsedJSON["status"] as! String == "200" && action != "follow" && action != "unfollow" {
                        NotificationCenter.default.post(name: Notification.Name(rawValue: "friend"), object: nil)
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // called once friend button has been clicked
    @IBAction func friendButton_clicked(_ friendButton: UIButton) {
        
        
        // getting ids of the users
        guard let currentUser_id = currentUser?["id"], let friendUser_id = id as? Int else {
            return
        }
        
        
        // current user didn't send friendship request -> send it
        if friendshipStatus == 0 {
            
            // update status in the app logic
            friendshipStatus = 1
            
            // update button
            update(button: friendButton, icon: "request.png", title: "Requested", color: Helper().facebookColor)
            
            // send request to the server
            updateFriendshipRequest(with: "add", user_id: currentUser_id, friend_id: friendUser_id)
            
            // current user sent friendship request -> cancel it
        } else if friendshipStatus == 1 {
            
            // update status in the app logic
            friendshipStatus = 0
            
            // update button
            update(button: friendButton, icon: "unfriend.png", title: "Add", color: .darkGray)
            
            // send request to the server
            updateFriendshipRequest(with: "reject", user_id: currentUser_id, friend_id: friendUser_id)
            
            // current user received friendship request -> show action sheet
        } else if friendshipStatus == 2 {
            
            // show action sheet to update request: confirm or delete
            showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currentUser_id)
            
            // current user and searched users are friends -> show action sheet
        } else if friendshipStatus == 3 {
            
            // show action sheet to update friendship: delete
            showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currentUser_id)
            
        }
        
    }
    
    
    // creates action sheet and its behav
    func showAction(button: UIButton, friendUser_id: Any, currentUser_id: Any) {
        
        // delcaring sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // triger destructive action
        var destructiveAction = ""
        
        // current user received friendship request -> triger REJECTION
        if friendshipStatus == 2 {
            destructiveAction = "reject"
            
            // current user and searched user are friends -> triger DELETE
        } else {
            destructiveAction = "delete"
        }
        
        
        // delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // update status -> no more any relations
            self.friendshipStatus = 0
            
            // update button
            self.update(button: button, icon: "unfriend.png", title: "Add", color: .darkGray)
            
            // send request to the server
            self.updateFriendshipRequest(with: destructiveAction, user_id: currentUser_id, friend_id: friendUser_id)
            self.updateFriendshipRequest(with: destructiveAction, user_id: friendUser_id, friend_id: currentUser_id)
            
        }
        
        // confirm button
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
            // udpate status -> now friends
            self.friendshipStatus = 3
            
            // update button
            self.update(button: button, icon: "friends.png", title: "Friends", color: Helper().facebookColor)
            
            // send request to the server
            self.updateFriendshipRequest(with: "confirm", user_id: friendUser_id, friend_id: currentUser_id)
            
        }
        
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(delete)
        
        // show confirm button only if current user received friendship request. Hide confirm button if users are already a friends
        if friendshipStatus == 2 {
            sheet.addAction(confirm)
        }
        
        sheet.addAction(cancel)
        
        // show sheet
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    // sends request to the server to follow / unfollow the user
    @IBAction func followButton_clicked(_ followButton: UIButton) {
        
        // id of the current user
        guard let currentUser_id = currentUser?["id"] else {
            return
        }
        
        // id of the user to follow
        let follow_id = self.id
        
        
        // start following the user if currently isn't followed
        if isFollowed == Int() {
            
            // cast trigger as user started to follow the guest
            isFollowed = 1
            
            // updagte appearance of the button
            update(button: followButton, icon: "follow.png", title: "Following", color: Helper().facebookColor)
            
            // send request to the server
            updateFriendshipRequest(with: "follow", user_id: currentUser_id, friend_id: follow_id)
            
        // stop following the user if currently is followed
        } else {
            
            // cast trigger as user stopped following the guest
            isFollowed = Int()
            
            // update appearance of the button
            update(button: followButton, icon: "unfollow.png", title: "Follow", color: .darkGray)
            
            // send request to the server
            updateFriendshipRequest(with: "unfollow", user_id: currentUser_id, friend_id: follow_id)
            
        }
        
        
    }
    
    
    // more button has been clicked
    @IBAction func moreButton_clicked(_ sender: Any) {
        
        // calling function which shows action sheet for reporting
        showReportSheet(post_id: 0)
    }
    
    
    // called when options button in post cell has been clicked
    @IBAction func optionsButton_clicked(_ optionsButton: UIButton) {
        
        // accessing indexPath.row of the cell
        let indexPathRow = optionsButton.tag

        // accessing id of the post in order to specity it in the server
        let post_id = posts[indexPathRow]!["id"] as! Int

        // calling function which shows action sheet for reporting
        showReportSheet(post_id: post_id)
    }
    
    
    // calling actions sheet for reporting
    func showReportSheet(post_id: Int) {
        
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
                
                // id of the user we're complaining about
                let user_id = self.id
                
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


extension UIButton {
    
    
    // adjust the icon and title's position
    func centerVertically(gap: CGFloat) {
        
        // adjust title's width
        self.contentEdgeInsets = UIEdgeInsets(top: 0, left: -20, bottom: 0, right: -20)
        
        // vertical position of title
        let padding = self.frame.height + gap
        
        // accessing sizes
        let imageSize = self.imageView!.frame.size
        let titleSize = self.titleLabel!.frame.size
        let totalHeight = imageSize.height + titleSize.height + padding
        
        // applying the final apperance of the icon's insets
        self.imageEdgeInsets = UIEdgeInsets(top: -(totalHeight - imageSize.height), left: 0, bottom: 0, right: -titleSize.width)
        
        // applying the final position of title by vertical
        self.titleEdgeInsets = UIEdgeInsets(top: 0, left: -imageSize.width, bottom: -(totalHeight - titleSize.height), right: 0)
        
    }
    
    
}

