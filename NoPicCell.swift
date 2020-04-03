//
//  NoPicCell.swift
//  FaceBook
//
//  Created by MacBook Pro on 5/16/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class NoPicCell: UITableViewCell {
    
    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var postTextLabel: UILabel!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var commentsButton: UIButton!
    @IBOutlet weak var optionsButton: UIButton!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }

    
}
