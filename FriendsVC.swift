//
//  FriendsVC.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 6/22/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class FriendsVC: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource, FriendRequestCellDelegate {
    
    
    // @delegate received / caught from the cell. This delegate is having assigned data / information to: 'action' and 'cell' vars
    func updateFriendshipRequest(with action: String, status: Int, from cell: UITableViewCell) {
        
        // getting indexPath of the cell
        guard let indexPath = friendsTableView.indexPath(for: cell) else {
            return
        }
        
        // if added as friend, update in app logic
        if action == "confirm" {
            friendshipStatus.append(3)
        } else {
            friendshipStatus.append(0)
        }
        
        // getting user_id (person who wants to add us to be his friend) AND friend_id (current user)
        guard let user_id = requestedUsers[indexPath.row]["id"], let friend_id = currentUser?["id"] else {
            return
        }
        
        // updating status of the request in the server
        updateFriendshipRequest(with: action, user_id: user_id, friend_id: friend_id)
        
    }
    
    
    
    // PART 1. Search
    // ui obj
    @IBOutlet weak var searchTableView: UITableView!
    
    // search obj
    var searchBar = UISearchBar()
    var searchedUsers = [NSDictionary]()
    var searchedUsers_avas = [UIImage]()
    
    // int
    var searchLimit = 15
    var searchSkip = 0
    
    var friendshipStatus = [Int]()
    
    
    // PART 2. Requests
    var requestedUsers = [NSDictionary]()
    var requestedUsers_avas = [UIImage]()
    var requestedUsersLimit = 10
    var requestedUsersSkip = 0
    
    
    // PART 3. Recommended Users
    var recommendedUsers = [NSDictionary]()
    var recommendedUsers_avas = [UIImage]()
    var recommendedUsers_friendshipStatus = [Int]()
    
    var headers = ["FRIEND REQUESTS", "PEOPLE YOU MAY KNOW"]
    
    
    
    // bool
    var isLoading = false
    var isSearchedUserStatusUpdated = false
    
    
    // PART 2. Requests and Friends
    @IBOutlet weak var friendsTableView: UITableView!
    
    
    
    // first load func
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /*
        // auto-determined cell height (tableViewRowHeight)
        searchTableView.rowHeight = UITableViewAutomaticDimension
        searchTableView.estimatedRowHeight = 100
        */
        
        // call func-s
        createSearchBar()
        loadRequsts()
        loadRecommendedUsers()
        
        // add observer of the notifications received/sent to current vc
        NotificationCenter.default.addObserver(self, selector: #selector(searchUsers), name: Notification.Name(rawValue: "friend"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadRequsts), name: Notification.Name(rawValue: "friend"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(loadRecommendedUsers), name: Notification.Name(rawValue: "friend"), object: nil)
        
    }
    
    
    // creates search bar programmatically
    func createSearchBar() {
        
        // creating search bar and configuring it
        searchBar.showsCancelButton = false
        searchBar.placeholder = "Search"
        searchBar.delegate = self
        searchBar.searchBarStyle = .minimal
        searchBar.tintColor = .white
        
        // accessing childView - textField inside of the searchBar
        let searchBar_textField = searchBar.value(forKey: "searchField") as? UITextField
        searchBar_textField?.textColor = .white
        searchBar_textField?.tintColor = .white
        
        // insert searchBar into navigationBar
        self.navigationItem.titleView = searchBar
        
    }
    
    
    // once the searchBar is tapped
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
        // show cancel button
        searchBar.setShowsCancelButton(true, animated: true)

        // show tableView that presents searched users
        searchTableView.isHidden = false
    }
    
    
    // cancel button in the searchBar has been clicked
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        
        // hide cancel button
        searchBar.setShowsCancelButton(false, animated: true)
        
        // hide tableView that presents searched users
        searchTableView.isHidden = true
        
        // hide keyboard
        searchBar.resignFirstResponder()
        
        // remove all searched results
        searchBar.text = ""
        searchedUsers.removeAll(keepingCapacity: false)
        searchedUsers_avas.removeAll(keepingCapacity: false)
        friendshipStatus.removeAll(keepingCapacity: false)
        searchTableView.reloadData()
        
    }
    
    
    // called whenever we typed any letter in the searchbar
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchUsers()
    }
    
    
    // searchUsers
    @objc func searchUsers() {
        
        isLoading = true
        
        // accessing id of current user
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        // name we want to find
        let name = searchBar.text!
        
        // prepare request to be sent to the server
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=search&name=\(name)&id=\(currentUser_id)&limit=\(searchLimit)&offset=0"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        // run request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error happened
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // no error
                do {
                    
                    // safe mode of accessing data received from the server
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // covnerting dat to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // show no users if nothing is found
                    if let status = json?["status"] as? String {
                        if status == "400" {
                            // remove all searched result
                            self.searchedUsers.removeAll(keepingCapacity: false)
                            self.searchedUsers_avas.removeAll(keepingCapacity: false)
                            self.searchTableView.reloadData()
                        }
                    }
                    
                    
                    // safe mode of accessing json
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    
                    // save accessed json (users) in our array
                    self.searchedUsers = users
                    
                    
                    // cleaning entire array of requested column, as we're loading this func first time, to avoid further bugs
                    self.friendshipStatus.removeAll(keepingCapacity: false)
                    self.searchedUsers_avas.removeAll(keepingCapacity: false)
                    
                    /*
                    // for every user in entire array of users (fetched from the server as per request), check is Requested Column null or not
                    for user in users {
                        if user["requested"] is NSNull {
                            self.friendshipStatus.append(Int())
                        } else {
                            self.friendshipStatus.append(1)
                        }
                    }
                    */
                    
                    // checking friendship status of every user
                    for user in users {
                        
                        // request sender is a current user
                        if user["request_sender"] is NSNull == false && user["request_sender"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(1)
                            
                        // request received by current user
                        } else if user["request_receiver"] is NSNull == false && user["request_receiver"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(2)
                        
                        // current user is the one who sent invitation of friendship which got accepted
                        } else if user["friendship_sender"] is NSNull == false {
                            self.friendshipStatus.append(3)
                            
                        // current user is the one who accepted the friendship
                        } else if user["friendship_receiver"] is NSNull == false {
                            self.friendshipStatus.append(3)
                        
                        // all other possible scenarios or failures
                        } else {
                            self.friendshipStatus.append(0)
                        }
                        
                    }
                    
                    // update skip value for further load (skip already loaded users)
                    self.searchSkip = users.count
                    
                    // update searchTableView
                    self.searchTableView.reloadData()
                    
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    // executed always whenever tableView is scrolling
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        // load more posts when the scroll is about to reach the bottom AND currently is not loading (posts)
        if searchTableView.contentOffset.y - searchTableView.contentSize.height + 60 > -searchTableView.frame.height && isLoading == false && searchedUsers.count >= searchLimit {
            
            searchMore(offset: searchSkip, limit: searchLimit)
            
        }
        
    }
    
    
    // load more users if scrolled down
    func searchMore(offset: Int, limit: Int) {
        
        isLoading = true
        
        // accessing id of current user
        guard let currentUser_id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        // name we want to find
        let name = searchBar.text!
        
        // prepare request to be sent to the server
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=search&name=\(name)&id=\(currentUser_id)&limit=\(limit)&offset=\(searchSkip)"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        // run request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error happened
                if error != nil {
                    self.isLoading = false
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // no error
                do {
                    
                    // safe mode of accessing data received from the server
                    guard let data = data else {
                        self.isLoading = false
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // covnerting dat to JSON
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // safe mode of accessing json
                    guard let users = json?["users"] as? [NSDictionary] else {
                        self.isLoading = false
                        return
                    }
                    
                    // add in existing array with data, more data
                    self.searchedUsers.append(contentsOf: users)
                    
                    // increment offset (skip all previously loaded users)
                    self.searchSkip += users.count
                    
                    
                    // cleaning entire array of requested column, as we're loading this func first time, to avoid further bugs
                    // self.requested.removeAll(keepingCapacity: false)
                    
                    /*
                    // for every user in entire array of users (fetched from the server as per request), check is Requested Column null or not
                    for user in users {
                        if user["requested"] is NSNull {
                            self.friendshipStatus.append(Int())
                        } else {
                            self.friendshipStatus.append(1)
                        }
                    }
                    */
                    
                    
                    // checking friendship status of every user
                    for user in users {
                        
                        // request sender is a current user
                        if user["request_sender"] is NSNull == false && user["request_sender"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(1)
                            
                            // request received by current user
                        } else if user["request_receiver"] is NSNull == false && user["request_receiver"] as? Int == Int(currentUser_id as! String) {
                            self.friendshipStatus.append(2)
                            
                            // current user is the one who sent invitation of friendship which got accepted
                        } else if user["friendship_sender"] is NSNull == false {
                            self.friendshipStatus.append(3)
                            
                            // current user is the one who accepted the friendship
                        } else if user["friendship_receiver"] is NSNull == false {
                            self.friendshipStatus.append(3)
                            
                            // all other possible scenarios or failures
                        } else {
                            self.friendshipStatus.append(0)
                        }
                        
                    }
                    
                    
                    // insert new cells
                    self.searchTableView.beginUpdates()
                    
                    for i in 0 ..< users.count {
                        let lastSectionIndex = self.searchTableView.numberOfSections - 1
                        let lastRowIndex = self.searchTableView.numberOfRows(inSection: lastSectionIndex)
                        let pathToLastRow = IndexPath(row: lastRowIndex + i, section: lastSectionIndex)
                        self.searchTableView.insertRows(at: [pathToLastRow], with: .fade)
                    }
                    
                    self.searchTableView.endUpdates()
                    
                    
                    self.isLoading = false
                    
                } catch {
                    self.isLoading = false
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // total numb of sections in the tableView
    func numberOfSections(in tableView: UITableView) -> Int {
        return headers.count
    }
    
    
    // number of cells
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // for searchTableView show total numb of cells equal to searched users
        if tableView == searchTableView {
            
            // searchTableView has only 1 section at index 0. We are clearing everything and sepcifying everything
            if section == 0 {
                return searchedUsers.count
            }
            
        // for other tableViews (friendsTableVeiw) show total numb of cells equal to number of relevant array.count
        } else {
            
            // section - requests
            if section == 0 {
                return requestedUsers.count
            
            // all other sections - recommended
            } else {
                return recommendedUsers.count
            }
            
        }
        
        return 0
        
    }
    
    
    // height of cells
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    
    // section header of cells
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        // for friendstableView only show headers
        if tableView == friendsTableView {
            
            // scenarios for all the section cases
            switch section {
                
            // section - requests
            case 0:
                if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                    return headers[section]
                }
                
            // section - recommended
            case 1:
                if self.tableView(tableView, numberOfRowsInSection: section) > 0 {
                    return headers[section]
                }
                
            // non of the section above - default case
            default:
                return nil
            }
            
        }
        
        return nil
        
    }
    
    
    // configur-n of header / section
    func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int) {
        
        // accessing header
        let header = view as! UITableViewHeaderFooterView
        
        // change text color and font
        header.textLabel?.font = UIFont(name: "HelveticaNeue-Light", size: 12)!
        header.textLabel?.textColor = UIColor.darkGray
        
    }
    
    
    // configur-n of cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // if currently is used searchTableView, configure cells accordingly
        if tableView == searchTableView {
            
            // access cell inside searchTableView
            let cell = searchTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! SearchUserCell
            
            // formatting fullname
            let firstName = searchedUsers[indexPath.row]["firstName"] as! String
            let lastName = searchedUsers[indexPath.row]["lastName"] as! String
            cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
            cell.friendButton.tag = indexPath.row
            
            // avas logic
            let avaString = searchedUsers[indexPath.row]["ava"] as! String
            
            var avaURL = URL(string: "http://")
            
            if avaString.isEmpty == false {
                avaURL = URL(string: avaString)
            }
            
            // if there are still avas to be loaded
            if searchedUsers.count != searchedUsers_avas.count {
                
                URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
                    
                    // failed downloading - assign placeholder
                    if error != nil {
                        if let image = UIImage(named: "user.png") {
                            
                            self.searchedUsers_avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                            
                        }
                        
                    }
                    
                    // downloaded
                    if let image = UIImage(data: data!) {
                        
                        self.searchedUsers_avas.append(image)
                        
                        DispatchQueue.main.async {
                            cell.avaImageView.image = image
                        }
                    }
                    
                }.resume()
                
            // cached ava
            } else {
                DispatchQueue.main.async {
                    cell.avaImageView.image = self.searchedUsers_avas[indexPath.row]
                }
            }
            
            
            // manipulate appearance of friendButton
            DispatchQueue.main.async {
                
                
                // if searched user isn't allowing a friendship request - hide "send request button" in the cell
                if self.searchedUsers[indexPath.row]["allow_friends"] as! Int == 0 {
                    cell.friendButton.isHidden = true
                    cell.accessoryType = .disclosureIndicator
                } else {
                    cell.friendButton.isHidden = false
                    cell.accessoryType = .none
                }
                
                
                // current user sent friendship request
                if self.friendshipStatus[indexPath.row] == 1 {
                    self.update(button: cell.friendButton, icon: "request.png", color: Helper().facebookColor)
                    
                // current user received friendship request
                } else if self.friendshipStatus[indexPath.row] == 2 {
                    self.update(button: cell.friendButton, icon: "respond.png", color: Helper().facebookColor)
                
                // current user and searched user are friends
                } else if self.friendshipStatus[indexPath.row] == 3 {
                    self.update(button: cell.friendButton, icon: "friends.png", color: Helper().facebookColor)
                
                // all other scenarios
                } else {
                    self.update(button: cell.friendButton, icon: "unfriend.png", color: .darkGray)
                }
                
            }
            
            
            return cell
            
        // configure cell of FriendsTableView
        } else {
            
            // configure cell for requests
            if indexPath.section == 0 {
            
                // access cell inside friendsTableView
                let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! FriendRequestCell
                
                // creating delegate relations from the cell to current vc in order to access protocols of the delegate class
                cell.delegate = self
                
                // formatting fullname
                let firstName = requestedUsers[indexPath.row]["firstName"] as! String
                let lastName = requestedUsers[indexPath.row]["lastName"] as! String
                cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                
                // avas logic
                let avaString = requestedUsers[indexPath.row]["ava"] as! String
                
                var avaURL = URL(string: "http://")
                
                if avaString.isEmpty == false {
                    avaURL = URL(string: avaString)
                }
                
                // if there are still avas to be loaded
                if requestedUsers.count != requestedUsers_avas.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.requestedUsers_avas.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                                
                            }
                            
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.requestedUsers_avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        
                        }.resume()
                    
                    // cached ava
                } else {
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.requestedUsers_avas[indexPath.row]
                    }
                }
             
                return cell
                
            } else {
                
                // access cell inside friendsTableView
                let cell = friendsTableView.dequeueReusableCell(withIdentifier: "cell2", for: indexPath) as! RecommendedUserCell
                
                // formatting fullname
                let firstName = recommendedUsers[indexPath.row]["firstName"] as! String
                let lastName = recommendedUsers[indexPath.row]["lastName"] as! String
                cell.fullnameLabel.text = firstName.capitalized + " " + lastName.capitalized
                
                // assign tags as indexPathRow for further access
                cell.addButton.tag = indexPath.row
                cell.removeButton.tag = indexPath.row
                
                // avas logic
                let avaString = recommendedUsers[indexPath.row]["ava"] as! String
                
                var avaURL = URL(string: "http://")
                
                if avaString.isEmpty == false {
                    avaURL = URL(string: avaString)
                }
                
                // if there are still avas to be loaded
                if recommendedUsers.count != recommendedUsers_avas.count {
                    
                    URLSession(configuration: .default).dataTask(with: avaURL!) { (data, response, error) in
                        
                        // failed downloading - assign placeholder
                        if error != nil {
                            if let image = UIImage(named: "user.png") {
                                
                                self.recommendedUsers_avas.append(image)
                                
                                DispatchQueue.main.async {
                                    cell.avaImageView.image = image
                                }
                                
                            }
                            
                        }
                        
                        // downloaded
                        if let image = UIImage(data: data!) {
                            
                            self.recommendedUsers_avas.append(image)
                            
                            DispatchQueue.main.async {
                                cell.avaImageView.image = image
                            }
                        }
                        
                        }.resume()
                    
                    // cached ava
                } else {
                    DispatchQueue.main.async {
                        cell.avaImageView.image = self.recommendedUsers_avas[indexPath.row]
                    }
                }
                
                
                // manipulate appearance of friendButton
                DispatchQueue.main.async {
                    
                    // current user sent friendship request
                    if self.recommendedUsers_friendshipStatus[indexPath.row] == 0 {
                        
                        // hide / show obj for no requests status
                        cell.addButton.isHidden = false
                        cell.removeButton.isHidden = false
                        cell.messageLabel.isHidden = true
                        
                    // current user received friendship request
                    } else if self.recommendedUsers_friendshipStatus[indexPath.row] == 1 {
                        
                        // hide / show obj for no requests status
                        cell.addButton.isHidden = true
                        cell.removeButton.isHidden = true
                        cell.messageLabel.isHidden = false
                        
                    }
                    
                }
                
                
                return cell
                
            }
            
        }
        
    }
    
    
    // updates any button with following params
    func update(button: UIButton, icon: String, color: UIColor) {
        
        // setting icon / background image
        button.setBackgroundImage(UIImage(named: icon), for: .normal)
        
        // setting color of the button
        button.tintColor = color
        
    }
    
    
    // when Friend Button has been clicked
    @IBAction func friendButton_clicked(_ friendButton: UIButton) {
        
        // accessing indexPath.row of the cell
        let indexPathRow = friendButton.tag
        
        // getting ids of the users
        guard let currentUser_id = currentUser?["id"], let friendUser_id = searchedUsers[indexPathRow]["id"] else {
            return
        }
        
        
        // current user didn't send friendship request -> send it
        if friendshipStatus[indexPathRow] == 0 {
            
            isSearchedUserStatusUpdated = true
            
            // update status in the app logic
            friendshipStatus[indexPathRow] = 1
            
            // update button
            update(button: friendButton, icon: "request.png", color: Helper().facebookColor)
            
            // send request to the server
            updateFriendshipRequest(with: "add", user_id: currentUser_id, friend_id: friendUser_id)
            
        // current user sent friendship request -> cancel it
        } else if friendshipStatus[indexPathRow] == 1 {
            
            isSearchedUserStatusUpdated = true
            
            // update status in the app logic
            friendshipStatus[indexPathRow] = 0
            
            // update button
            update(button: friendButton, icon: "unfriend.png", color: .darkGray)
            
            // send request to the server
            updateFriendshipRequest(with: "reject", user_id: currentUser_id, friend_id: friendUser_id)
        
        // current user received friendship request -> show action sheet
        } else if friendshipStatus[indexPathRow] == 2 {
            
            isSearchedUserStatusUpdated = true
            
            // show action sheet to update request: confirm or delete
            showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currentUser_id, indexPathRow: indexPathRow)
            
        // current user and searched users are friends -> show action sheet
        } else if friendshipStatus[indexPathRow] == 3 {
            
            isSearchedUserStatusUpdated = true
            
            // show action sheet to update friendship: delete
            showAction(button: friendButton, friendUser_id: friendUser_id, currentUser_id: currentUser_id, indexPathRow: indexPathRow)
            
        }
        
    }
    
    
    // shows action sheet for friendship further action
    func showAction(button: UIButton, friendUser_id: Any, currentUser_id: Any, indexPathRow: Int) {
        
        // delcaring sheet
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        // triger destructive action
        var destructiveAction = ""
        
        // current user received friendship request -> triger REJECTION
        if friendshipStatus[indexPathRow] == 2 {
            destructiveAction = "reject"
            
        // current user and searched user are friends -> triger DELETE
        } else {
            destructiveAction = "delete"
        }
        
        
        // delete button
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action) in
            
            // update status -> no more any relations
            self.friendshipStatus[indexPathRow] = 0
            
            // update button
            self.update(button: button, icon: "unfriend.png", color: .darkGray)
            
            // send request to the server
            self.updateFriendshipRequest(with: destructiveAction, user_id: currentUser_id, friend_id: friendUser_id)
            self.updateFriendshipRequest(with: destructiveAction, user_id: friendUser_id, friend_id: currentUser_id)
            
        }
        
        // confirm button
        let confirm = UIAlertAction(title: "Confirm", style: .default) { (action) in
            
            // udpate status -> now friends
            self.friendshipStatus[indexPathRow] = 3
            
            // update button
            self.update(button: button, icon: "friends.png", color: Helper().facebookColor)
            
            // send request to the server
            self.updateFriendshipRequest(with: "confirm", user_id: friendUser_id, friend_id: currentUser_id)
            
        }
        
        // cancel button
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        // adding buttons to the sheet
        sheet.addAction(delete)
        
        // show confirm button only if current user received friendship request. Hide confirm button if users are already a friends
        if friendshipStatus[indexPathRow] == 2 {
            sheet.addAction(confirm)
        }
        
        sheet.addAction(cancel)
        
        // show sheet
        present(sheet, animated: true, completion: nil)
        
    }
    
    
    // updates request (confirm / reject / send based on the action)
    func updateFriendshipRequest(with action: String, user_id: Any, friend_id: Any) {
        
        
        // send notification to the server
        let notification_url = "http://localhost/fb/notification.php"
        var notification_body = ""
        
        if action == "confirm" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=insert"
        } else if action == "delete" {
            notification_body = "byUser_id=\(user_id)&user_id=\(friend_id)&type=friend&action=delete"
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
                    
                    // if user's status got udpated from the searchTableView - effect friendsTableView
                    if self.isSearchedUserStatusUpdated == true {
                        
                        // update all requests
                        self.loadRequsts()
                        
                        // trigger back
                        self.isSearchedUserStatusUpdated = false
                    }
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // executed before segue finishes
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // going Guest from SearchTableView (tapped on the searched user)
        // exec-d once GuestVC-Segue (id) is executed (id is declared in Main.storyboard)
        if segue.identifier == "GuestVC_SearchTableView" {
            
            // access index of selected sell, in order to access index of [users array]
            guard let indexPath = searchTableView.indexPathForSelectedRow else {
                return
            }
            
            // access vc we're heading to, in order to access its vars
            let guestvc = segue.destination as! GuestVC
            
            // shortcuts prepared to send to GuestVC
            let id = searchedUsers[indexPath.row]["id"] as! Int
            let firstName = searchedUsers[indexPath.row]["firstName"] as! String
            let lastName = searchedUsers[indexPath.row]["lastName"] as! String
            let avaPath = searchedUsers[indexPath.row]["ava"] as! String
            let coverPath = searchedUsers[indexPath.row]["cover"] as! String
            let bio = searchedUsers[indexPath.row]["bio"] as! String
            let allow_friends = searchedUsers[indexPath.row]["allow_friends"] as? Int ?? Int()
            let allow_follow = searchedUsers[indexPath.row]["allow_follow"] as? Int ?? Int()
            let isFollowed = searchedUsers[indexPath.row]["followed_user"] as? Int ?? Int()
            
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
        } else if segue.identifier == "GuestVC_FriendTableView" {
            
            // access index of selected sell, in order to access index of [requested users array]
            guard let indexPath = friendsTableView.indexPathForSelectedRow else {
                return
            }
            
            // access vc we're heading to, in order to access its vars
            let guestvc = segue.destination as! GuestVC
            
            // shortcuts prepared to send to GuestVC
            let id = requestedUsers[indexPath.row]["id"] as! Int
            let firstName = requestedUsers[indexPath.row]["firstName"] as! String
            let lastName = requestedUsers[indexPath.row]["lastName"] as! String
            let avaPath = requestedUsers[indexPath.row]["ava"] as! String
            let coverPath = requestedUsers[indexPath.row]["cover"] as! String
            let bio = requestedUsers[indexPath.row]["bio"] as! String
            let allow_friends = requestedUsers[indexPath.row]["allow_friends"] as? Int ?? Int()
            let allow_follow = requestedUsers[indexPath.row]["allow_follow"] as? Int ?? Int()
            let isFollowed = requestedUsers[indexPath.row]["followed_user"] as? Int ?? Int()
            
            // assign shortcuts to vars
            guestvc.id = id
            guestvc.firstName = firstName
            guestvc.lastName = lastName
            guestvc.avaPath = avaPath
            guestvc.coverPath = coverPath
            guestvc.bio = bio
            guestvc.friendshipStatus = 2
            guestvc.allow_friends = allow_friends
            guestvc.allow_follow = allow_follow
            guestvc.isFollowed = isFollowed
            
        // going guest from the cell of Recommended User
        } else if segue.identifier == "GuestVC_RecommendedUserCell" {
            
            // access index of selected sell, in order to access index of [requested users array]
            guard let indexPath = friendsTableView.indexPathForSelectedRow else {
                return
            }
            
            // access vc we're heading to, in order to access its vars
            let guestvc = segue.destination as! GuestVC
            
            // shortcuts prepared to send to GuestVC
            let id = recommendedUsers[indexPath.row]["id"] as! Int
            let firstName = recommendedUsers[indexPath.row]["firstName"] as! String
            let lastName = recommendedUsers[indexPath.row]["lastName"] as! String
            let avaPath = recommendedUsers[indexPath.row]["ava"] as! String
            let coverPath = recommendedUsers[indexPath.row]["cover"] as! String
            let bio = recommendedUsers[indexPath.row]["bio"] as! String
            let allow_friends = recommendedUsers[indexPath.row]["allow_friends"] as? Int ?? Int()
            let allow_follow = recommendedUsers[indexPath.row]["allow_follow"] as? Int ?? Int()
            let isFollowed = recommendedUsers[indexPath.row]["followed_user"] as? Int ?? Int()
            
            // assign shortcuts to vars
            guestvc.id = id
            guestvc.firstName = firstName
            guestvc.lastName = lastName
            guestvc.avaPath = avaPath
            guestvc.coverPath = coverPath
            guestvc.bio = bio
            guestvc.friendshipStatus = recommendedUsers_friendshipStatus[indexPath.row]
            guestvc.allow_friends = allow_friends
            guestvc.allow_follow = allow_follow
            guestvc.isFollowed = isFollowed
            
        }
        
    }
    
    
    // laod all requests sent to current user
    @objc func loadRequsts() {
        
        isLoading = true
        
        // accessing current user's id
        guard let id = currentUser?["id"] else {
            isLoading = false
            return
        }
        
        // prepare request
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=requests&id=\(id)&limit=\(requestedUsersLimit)&offset=0"
        var request = URLRequest(url: url)
        request.httpBody = body.data(using: .utf8)
        request.httpMethod = "POST"
        
        
        // run request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // server error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
                do {
                    
                    // unwrapping data
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        self.isLoading = false
                        return
                    }
                    
                    // accessing json
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // unwrapping json
                    guard let requests = json?["requests"] as? [NSDictionary] else {
                        
                        // reload content of arrays
                        self.requestedUsers.removeAll(keepingCapacity: false)
                        self.requestedUsers_avas.removeAll(keepingCapacity: false)
                        self.requestedUsersSkip = 0
                        self.friendsTableView.reloadData()
                        
                        self.isLoading = false
                        return
                    }
                    
                    // assigning all loaded requests from json to requests dictionary array
                    self.requestedUsers = requests
                    
                    // assigning skip value to skip already loaded requests in further pagination
                    self.requestedUsersSkip = requests.count
                    
                    // reloading tableView to show all requests
                    self.friendsTableView.reloadData()
                    
                // json error
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    self.isLoading = false
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // loads all recommended users
    @objc func loadRecommendedUsers() {
        
        // access id
        guard let currentUser_id = currentUser?["id"] else {
            return
        }
        
        // preparing request
        let url = URL(string: "http://localhost/fb/friends.php")!
        let body = "action=recommended&id=\(currentUser_id)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body.data(using: .utf8)
        
        // sending request
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            DispatchQueue.main.async {
                
                // error
                if error != nil {
                    Helper().showAlert(title: "Server Error", message: error!.localizedDescription, in: self)
                    return
                }
                
                // no errors, so we're proceeding further
                do {
                    
                    // safe mode of accessing / casting data received from the server
                    guard let data = data else {
                        Helper().showAlert(title: "Data Error", message: error!.localizedDescription, in: self)
                        return
                    }
                    
                    // accessing / casting json via data received and casted
                    let json = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? NSDictionary
                    
                    // accessing all users from the json
                    guard let users = json?["users"] as? [NSDictionary] else {
                        
                        // if no users are loaded, clean tableView
                        self.recommendedUsers.removeAll(keepingCapacity: false)
                        self.recommendedUsers_avas.removeAll(keepingCapacity: false)
                        
                        self.isLoading = false
                        
                        return
                    }
                    
                    // reseting status of friendships
                    self.recommendedUsers_friendshipStatus.removeAll(keepingCapacity: false)
                    
                    // initial status of all recommended friends will be -> 0 (no requests have been sent no requests have been received no friendship at the moment)
                    // checking friendship status of every user
                    for user in users {
                        
                        // request sender is a current user
                        if user["request_sender"] is NSNull == false && user["request_sender"] as? Int == Int(currentUser_id as! String) {
                            self.recommendedUsers_friendshipStatus.append(1)
                            
                            // request received by current user
                        } else if user["request_receiver"] is NSNull == false && user["request_receiver"] as? Int == Int(currentUser_id as! String) {
                            self.recommendedUsers_friendshipStatus.append(2)
                        
                        // all other possible scenarios or failures
                        } else {
                            self.recommendedUsers_friendshipStatus.append(0)
                        }
                        
                    }
                    
                    // assigning all users to the mother array (mother array will load everything in the tableView)
                    self.recommendedUsers = users
                    
                    // reloading tableView to make changes live
                    self.friendsTableView.reloadData()
                    
                } catch {
                    Helper().showAlert(title: "JSON Error", message: error.localizedDescription, in: self)
                    return
                }
                
            }
        }.resume()
        
    }
    
    
    // add friend button has been clicked
    @IBAction func addButton_clicked(_ addButton: UIButton) {
        
        // accessing indexPath.row
        let indexPathRow = addButton.tag
        let indexPath = IndexPath(row: indexPathRow, section: 1)
        
        // cast status of friendship as Request is Sent
        recommendedUsers_friendshipStatus[indexPathRow] = 1
        
        // id of the current user
        guard let user_id = currentUser?["id"] else {
            return
        }
        
        // id of targeted user
        guard let friend_id = recommendedUsers[indexPathRow]["id"] else {
            return
        }
        
        // send HHTP request for the friendship
        updateFriendshipRequest(with: "add", user_id: user_id, friend_id: friend_id)
        
        
        // accel cell for update of ui obj
        let cell = friendsTableView.cellForRow(at: indexPath) as! RecommendedUserCell
        
        // hide / show obj
        cell.addButton.isHidden = true
        cell.removeButton.isHidden = true
        cell.messageLabel.isHidden = false
        
    }
    
    
    // remove button has been clicked
    @IBAction func removeButton_clicked(_ removeButton: UIButton) {
        
        // accessing indexPath.row
        let indexPathRow = removeButton.tag
        
        // remove value in array
        recommendedUsers.remove(at: indexPathRow)
        recommendedUsers_avas.remove(at: indexPathRow)
        recommendedUsers_friendshipStatus.remove(at: indexPathRow)
        
        // remove physical cell
        let indexPath = IndexPath(row: indexPathRow, section: 1)
        friendsTableView.beginUpdates()
        friendsTableView.deleteRows(at: [indexPath], with: .automatic)
        friendsTableView.endUpdates()
    }
    
    
}


