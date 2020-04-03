//
//  RequestUserCell.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 7/7/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit


// Delegate Protocol to be sent to the motherViewControler along with the data (e.g. action, cell)
protocol FriendRequestCellDelegate: class {
    func updateFriendshipRequest(with action: String, status: Int, from cell: UITableViewCell)
}

class FriendRequestCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var confirmButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    var delegate: FriendRequestCellDelegate?
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // creating border for delete button
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: deleteButton.frame.width, height: deleteButton.frame.height)
        
        // assining border to delete button and making corners rounded
        deleteButton.layer.addSublayer(border)
        deleteButton.layer.cornerRadius = 3
        deleteButton.layer.masksToBounds = true
        
        // rounded corners for confirmButton
        confirmButton.layer.cornerRadius = 3
        
    }
    
    
    // exec-d when confirm button is clicked
    @IBAction func confirmButton_clicked(_ sender: Any) {
        
        // hide button and show label
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
        // message in the label
        messageLabel.text = "Request accepted"
        
        // execute / send protocol and assign to it data: 'confirm' and 'current cell'
        delegate?.updateFriendshipRequest(with: "confirm", status: 3, from: self)
        
    }
    
    
    // exec-d when delete button is clicked
    @IBAction func deleteButton_clicked(_ sender: Any) {
        
        // hide button and show label
        confirmButton.isHidden = true
        deleteButton.isHidden = true
        messageLabel.isHidden = false
        
        // message in the label
        messageLabel.text = "Request removed"
        
        // execute / send protocol and assign to it data: 'confirm' and 'current cell'
        delegate?.updateFriendshipRequest(with: "reject", status: 0, from: self)
        
    }
    
    
}






