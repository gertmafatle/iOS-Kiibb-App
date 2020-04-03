//
//  MyFriendsVC.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 8/7/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class MyFriendsVC: UITableViewController {
    
    // code obj
    var friends = [NSDictionary?]()
    var friends_avas = [UIImage]()
    var skip = 0
    var limit = 10
    var friendshipStatus = [Int]()
    
    // bool
    var isLoading = false
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // run functions
        loadFriends()
    }
    
    
    // pre-load func
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // show navigation bar for My Friends Page
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    
    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return friends.count
    }
    
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell which's in main.storyboard
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! MyFriendsCell
        
        // accessing firstname and lastname from the mother-array which stores the information laoded from the sercver
        let firstName = friends[indexPath.row]!["firstName"] as? String ?? String()
        let lastName = friends[indexPath.row]!["lastName"] as? String ?? String()
        
        // show loaded fullname in the label
        cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
        
        // assign index of the button to its tag, so letter on we can access the index via tag
        cell.removeButton.tag = indexPath.row
        
        
        // accessing the url and path of the ava
        let avaString = friends[indexPath.row]!["ava"] as! String
        let avaURL = URL(string: avaString)!
        
        // if there are still avas to be loaded
        if friends.count != friends_avas.count {
            
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                
                // failed downloading - assign placeholder
                if error != nil {
                    if let image = UIImage(named: "user.png") {
                        
                        self.friends_avas.append(image)
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                        
                    }
                    
                }
                
                // downloaded
                if let image = UIImage(data: data!) {
                    
                    self.friends_avas.append(image)
                    
                    DispatchQueue.main.async {
                        cell.avaImageView.image = image
                    }
                }
                
                }.resume()
            
        // cached ava
        } else {
            DispatchQueue.main.async {
                cell.avaImageView.image = self.friends_avas[indexPath.row]
            }
        }
        
        
        return cell
    }
    

    // loads all friends of the current user
    func loadFriends() {
        
        isLoading = true
        
        // get id of the current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=friends&id=\(id)&limit=\(limit)&offset=0"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error while connecting to the server
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
                // no errors, go to repsonse from the server
                do {
                    
                    // safe mode of accessing loaded data from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing all the values from the key "friends" received from the PHP backend
                    guard let friends = json?["friends"] as? [NSDictionary] else {
                        return
                    }
                    
                    // loading everyone's friendship status
                    for _ in friends {
                        self.friendshipStatus.append(3)
                    }
                    
                    // assigning all loaded friends to self.friends
                    self.friends = friends
                    
                    // incrementing skip value for the next load
                    self.skip += friends.count
                    
                    // reloading tableview to see all friends
                    self.tableView.reloadData()
                    
                // error while accessing json
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // executed while the tableView is getting scrolled
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more data if scrolled down 1 page + 60 pxls
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            moreFriends(limit: limit, skip: skip)
        }
        
    }
    
    
    // loads more friends by skipping previously laoded number
    func moreFriends(limit: Int, skip: Int) {
        
        isLoading = true
        
        // get id of the current user
        guard let id = currentUser?["id"] else {
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=friends&id=\(id)&limit=\(limit)&offset=\(skip)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // send request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error while connecting to the server
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
                // no errors, go to repsonse from the server
                do {
                    
                    // safe mode of accessing loaded data from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing all the values from the key "friends" received from the PHP backend
                    guard let friends = json?["friends"] as? [NSDictionary] else {
                        return
                    }
                    
                    // loading everyone's friendship status
                    for _ in friends {
                        self.friendshipStatus.append(3)
                    }
                    
                    // assigning all loaded friends to self.friends
                    self.friends.append(contentsOf: friends)
                    
                    // incrementing skip value for the next load
                    self.skip += friends.count
                    
                    // insert new rows
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< friends.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                // error while accessing json
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // remove button has been clicked
    @IBAction func removeButton_clicked(_ removeButton: UIButton) {
        
        
        // accessing tag of the button. Earlier indexPath was declared as the tag of the button
        let indexPathRow = removeButton.tag
        
        // accessing user id of the current user and id of the friend
        guard let currentUser_id = currentUser?["id"], let friendUser_id = self.friends[indexPathRow]!["id"] else {
            return
        }
        
        
        // if the user is currently a friend of the current user -> show sheet to delete the friend
        if friendshipStatus[indexPathRow] == 3 {
            
            // show action sheet
            showSheet(indexPathRow: indexPathRow, removeButton: removeButton)
        
        // once the request is sent -> cancel the request
        } else if friendshipStatus[indexPathRow] == 1 {
            
            // remove request from the server
            self.updateFriendshipRequest(with: "reject", user_id: currentUser_id, friend_id: friendUser_id)
            
            // no more relatiosn, even requests
            friendshipStatus[indexPathRow] = 0
            
            // update the button
            removeButton.setTitle("Add", for: .normal)
            
        // if the user (friend) was deleted -> don't show sheet. send friendship request
        } else {
            
            
            // update friendship request in the server
            self.updateFriendshipRequest(with: "add", user_id: currentUser_id, friend_id: friendUser_id)
            
            // update friendship request in the front-end's logic. 1 = current user sent a request
            friendshipStatus[indexPathRow] = 1
            
            // udpate the button
            removeButton.setTitle("Cancel", for: .normal)
            
        }
        
        
    }
    
    
    // presents action sheet
    func showSheet(indexPathRow: Int, removeButton: UIButton) {
        
        // accessing user id of the current user and id of the friend
        guard let currentUser_id = currentUser?["id"], let friendUser_id = self.friends[indexPathRow]!["id"] else {
            return
        }
        
        
        // declaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // creating delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // update friendship request in the front-end's logic. 0 = no relations
            self.friendshipStatus[indexPathRow] = 0
            
            // update the button
            removeButton.setTitle("Add", for: .normal)
            removeButton.setTitleColor(.white, for: .normal)
            removeButton.backgroundColor = UIColor(red: 63/255, green: 150/255, blue: 247/255, alpha: 1)
            for layer in removeButton.layer.sublayers! {
                layer.borderColor = UIColor.white.cgColor
                layer.cornerRadius = 3
            }
            
            // considering both scenarios: current user is the initiator of the friendship AND current user is the one who has accepted friendship request earlier
            self.updateFriendshipRequest(with: "delete", user_id: currentUser_id, friend_id: friendUser_id)
            self.updateFriendshipRequest(with: "delete", user_id: friendUser_id, friend_id: currentUser_id)
            
        }
        
        // creating cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // assigning buttons to the sheet
        sheet.addAction(delete)
        sheet.addAction(cancel)
        
        // showing the sheet
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    // updates friendhsip: delete friend or send a request
    func updateFriendshipRequest(with action: String, user_id: Any, friend_id: Any) {
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        var notification_body = ""
        
        
        // register notification in the server
        if action == "delete" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=delete"
        } else if action == "add" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=insert"
        } else if action == "reject" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=request&action=insert"
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
                    _ = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // executed before segue finishes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // going Guest from MyFriendsVC
        if segue.identifier == "from_MyFriendsVC" {
            
            // access index of selected sell, in order to access index of [users array]
            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }
            
            // access vc we're heading to, in order to access its vars
            let guestvc = segue.destination as! GuestVC
            
            // shortcuts prepared to send to GuestVC
            let id = self.friends[indexPath.row]!["id"] as! Int
            let firstName = self.friends[indexPath.row]!["firstName"] as! String
            let lastName = self.friends[indexPath.row]!["lastName"] as! String
            let avaPath = self.friends[indexPath.row]!["ava"] as! String
            let coverPath = self.friends[indexPath.row]!["cover"] as! String
            let bio = self.friends[indexPath.row]!["bio"] as! String
            let allow_friends = self.friends[indexPath.row]!["allow_friends"] as? Int ?? Int()
            let allow_follow = self.friends[indexPath.row]!["allow_follow"] as? Int ?? Int()
            let isFollowed = self.friends[indexPath.row]!["followed_user"] as? Int ?? Int()
            
            // assign shortcuts to vars
            guestvc.id = id
            guestvc.firstName = firstName
            guestvc.lastName = lastName
            guestvc.avaPath = avaPath
            guestvc.coverPath = coverPath
            guestvc.bio = bio
            guestvc.friendshipStatus = friendshipStatus[indexPath.row]
            guestvc.allow_friends = allow_friends
            guestvc.allow_follow = allow_follow
            guestvc.isFollowed = isFollowed
            
            // going Guest from FriendsTableView (tapped on a friend or request)
        }
        
    }
    
    
    
}







