//
//  RecommendedUserCell.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 7/23/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class RecommendedUserCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var addButton: UIButton!
    @IBOutlet weak var removeButton: UIButton!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // create border for the removeButton
        let border = CALayer()
        border.borderWidth = 2
        border.borderColor = UIColor.lightGray.cgColor
        border.frame = CGRect(x: 0, y: 0, width: removeButton.frame.width, height: removeButton.frame.height)
        
        // assign border and make corners rounded
        removeButton.layer.addSublayer(border)
        removeButton.layer.cornerRadius = 3
        removeButton.layer.masksToBounds = true
        addButton.layer.cornerRadius = 3
        
    }


}
