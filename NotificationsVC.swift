//
//  NotificationsVC.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 7/31/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class NotificationsVC: UITableViewController {
    
    // code obj
    var notifications = [NSDictionary]()
    var notifications_avas = [UIImage]()
    var notifications_limit = 15
    var notifications_skip = 0
    
    var isLoading = false
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // dynamic cell height
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 100
        
        // exec func-s
        loadNotifications()
        
    }
    
    
    // cell height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }


    // cell numb
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return notifications.count
    }

    
    // cell config
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // accessing the cell in the tableView via id
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! NotificationsCell
        
        // changing the color of the cell if notification has been viewed already by the current user
        if notifications[indexPath.row]["viewed"] as? String ?? String() == "yes" {
            cell.backgroundColor = .white
        } else {
            cell.backgroundColor = Helper().facebookColor.withAlphaComponent(0.15)
        }
        
        // formatting full name
        let firstName = notifications[indexPath.row]["firstName"] as? String ?? String()
        let lastName = notifications[indexPath.row]["lastName"] as? String ?? String()
        let fullName = firstName.capitalized + " " + lastName.capitalized
        
        
        // trigger message depending on the type of the notification
        var message = ""
        
        switch notifications[indexPath.row]["type"] as? String ?? String() {
        case "friend":
            message = " now is your friend."
            cell.iconImageView.image = UIImage(named: "notifications_friend")
        case "follow":
            message = " has started following you."
            cell.iconImageView.image = UIImage(named: "notifications_follow")
        case "like":
            cell.iconImageView.image = UIImage(named: "notifications_like")
            message = " liked your post."
        case "comment":
            cell.iconImageView.image = UIImage(named: "notifications_comment")
            message = " has commented your post."
        case "ava":
            cell.iconImageView.image = UIImage(named: "notifications_update")
            message = " has changed his (her) profile picture."
        case "cover":
            cell.iconImageView.image = UIImage(named: "notifications_update")
            message = " has changed his (her) cover."
        case "bio":
            cell.iconImageView.image = UIImage(named: "notifications_update")
            message = " has updated his (her bio)"
        default:
            message = ""
        }
        
        
        // custom format of the messag: bold + regular fonts
        let boldString = NSMutableAttributedString(string: fullName, attributes: [kCTFontAttributeName as NSAttributedStringKey: UIFont.boldSystemFont(ofSize: 17)])
        let regularString = NSMutableAttributedString(string: message)
        boldString.append(regularString)
        cell.messageLabel.attributedText = boldString
        
        
        // accessing ava path and converting it to proper url
        let avaString = notifications[indexPath.row]["ava"] as? String ?? String()
        let avaURL = URL(string: avaString)!
        
        // if notifications are more than loaded avas -> load remaining avas
        if notifications.count != notifications_avas.count {
            
            // sessions to load the image from the server
            URLSession(configuration: .default).dataTask(with: avaURL) { (data, response, error) in
                DispatchQueue.main.async {
                    
                    // if error occured, load placeholder
                    if error != nil {
                        let image = UIImage(named: "user.png")!
                        self.notifications_avas.append(image)
                        cell.avaImageView.image = image
                    }
                    
                    // if no errors, load the image
                    if let image = UIImage(data: data!) {
                        self.notifications_avas.append(image)
                        cell.avaImageView.image = image
                    }
                    
                }
                
            }.resume()
        
        // if total avas are equal to total notifications -> no more avas to be loaded
        } else {
            cell.avaImageView.image = notifications_avas[indexPath.row]
        }
        

        return cell
    }
    
    
    // loads first badge notifications from the server
    func loadNotifications() {
        
        isLoading = true
        
        // access id of current user
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/notification.php")!
        let body = "byUser_id=0&user_id=\(currentUser_id)&type=any&action=select&offset=0&limit=\(notifications_limit)"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        // launch the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error happened
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // proceed to receive data from the server
                do {
                    
                    // safe mode of accessing data from the server
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing notifications from the json
                    guard let notifications = json?["notifications"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // append loaded notifications to the notifications variable
                    self.notifications = notifications
                    self.notifications_skip += notifications.count
                    
                    // reload tableView to see all the data in the cells
                    self.tableView.reloadData()
                    
                    self.isLoading = false
                    
                    
                    // updating status of every notification
                    for notification in notifications {
                        let url = "http://localhost/fb/notification.php"
                        let body = "byUser_id=0&user_id=0&type=any&action=update&id=\(notification["id"] as! Int)&viewed=yes"
                        _ = Helper().sendHTTPRequest(url: url, body: body, success: {}, failure: {})
                    }
                    
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // exec-d always when it is scrolling
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // if tableView is scrolled down by 1 page + 60pxls and currently it's not loading anything ... exec pagination
        if tableView.contentOffset.y - tableView.contentSize.height + 60 > -tableView.frame.height && isLoading == false {
            moreNotifications(offset: notifications_skip, limit: notifications_limit)
        }
        
    }
    
    
    // loads first badge notifications from the server
    func moreNotifications(offset: Int, limit: Int) {
        
        isLoading = true
        
        // access id of current user
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/notification.php")!
        let body = "byUser_id=0&user_id=\(currentUser_id)&type=any&action=select&offset=\(offset)&limit=\(limit)"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        // launch the request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error happened
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // proceed to receive data from the server
                do {
                    
                    // safe mode of accessing data from the server
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // converting data to json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing notifications from the json
                    guard let notifications = json?["notifications"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // append loaded notifications to the notifications variable
                    self.notifications.append(contentsOf: notifications)
                    self.notifications_skip += notifications.count
                    
                    // reload tableView to see all the data in the cells
                    self.tableView.beginUpdates()
                    
                    for i in 0 ..< notifications.count {
                        let lastSectionIndex = self.tableView.numberOfSections - 1
                        let lastRowIndex = self.tableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.tableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.tableView.endUpdates()
                    
                    self.isLoading = false
                    
                    
                    // updating status of every notification
                    for notification in notifications {
                        let url = "http://localhost/fb/notification.php"
                        let body = "byUser_id=0&user_id=0&type=any&action=update&id=\(notification["id"] as! Int)&viewed=yes"
                        _ = Helper().sendHTTPRequest(url: url, body: body, success: {}, failure: {})
                    }
                    
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // cell tap
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // calling action sheet
        showSheet(indexPath: indexPath)
        
    }
    
    
    // shows actions sheet for the notifications
    func showSheet(indexPath: IndexPath) {
        
        // delcaring action sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // declaring hide button
        let hide = UIAlertAction(title: "Hide", style: .default) { (action) in
            
            // update the viewed status on the server
            let url = "http://localhost/fb/notification.php"
            let body = "byUser_id=0&user_id=0&type=any&action=update&id=\(self.notifications[indexPath.row]["id"] as! Int)&viewed=ignore"
            _ = Helper().sendHTTPRequest(url: url, body: body, success: {}, failure: {})
            
            // remove notification from the skeleton - clean up array from the element
            self.notifications.remove(at: indexPath.row)
            self.notifications_avas.remove(at: indexPath.row)
            
            // remove the cell itself
            self.tableView.beginUpdates()
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            self.tableView.endUpdates()
            
        }
        
        // declaring cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(hide)
        sheet.addAction(cancel)
        
        // showing the sheet
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    
}










