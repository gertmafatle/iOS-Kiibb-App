//
//  NotificationsCell.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 7/31/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class NotificationsCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var messageLabel: UILabel!
    
    
    // first load func
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
        iconImageView.layer.cornerRadius = iconImageView.frame.width / 2
        iconImageView.clipsToBounds = true
        
    }
    
    
}
