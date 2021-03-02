//
//  StrikeCell.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/21/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit

class StrikeCell: UITableViewCell {

    @IBOutlet weak var mainView: UIView!
    
    @IBOutlet weak var emailLabel: UILabel!
    
    @IBOutlet weak var reasonLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

    }

}
