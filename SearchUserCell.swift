//
//  SearchUserCell.swift
//  FaceBook
//
//  Created by Akhmed Idigov on 6/23/18.
//  Copyright © 2018 MacBook Pro. All rights reserved.
//

import UIKit

class SearchUserCell: UITableViewCell {

    // ui obj
    @IBOutlet weak var avaImageView: UIImageView!
    @IBOutlet weak var fullnameLabel: UILabel!
    @IBOutlet weak var friendButton: UIButton!
    
    
    // first load func (similar to viewDidLoad but for subViews like Cell)
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // rounded corners
        avaImageView.layer.cornerRadius = avaImageView.frame.width / 2
        avaImageView.clipsToBounds = true
        
    }
    
    
}
