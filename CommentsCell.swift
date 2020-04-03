//
//  CommentsCell.swift
//  FaceBook
//
//  Created by MacBook Pro on 6/2/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class CommentsCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var commentLabel: UILabel!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // round corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }
    
    
}
