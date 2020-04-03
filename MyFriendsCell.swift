//
//  MyFriendsCell.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 8/7/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class MyFriendsCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var removeButton: UIButton!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // creating the border, stroke or frame for the remove button
        let border = CALayer()
        border.borderWidth = 1.5
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: removeButton.frame.width, height: removeButton.frame.height)
        
        removeButton.layer.addSublayer(border)
        removeButton.layer.cornerRadius = 3
        removeButton.layer.masksToBounds = true
        
    }


}
