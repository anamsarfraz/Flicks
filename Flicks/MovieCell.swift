//
//  MovieCell.swift
//  Flicks
//
//  Created by Unum Sarfraz on 10/13/16.
//  Copyright © 2016 CodePath. All rights reserved.
//

import AFNetworking
import UIKit

class MovieCell: UITableViewCell {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var overViewLabel: UILabel!
        
    @IBOutlet weak var posterView: AFNetworking.UIImageView!

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
