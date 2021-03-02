//
//  JobCell.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/17/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit

class JobCell: UITableViewCell {
    
    @IBOutlet weak var photoImageView: UIImageView!
    
    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var descriptionLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    
    @IBOutlet weak var distanceLabel: UILabel!
    
    @IBOutlet weak var secView: UIView!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
