//
//  UserCell.swift
//  UrbanHeroApplication
//
//  Created by Stefan Kjoropanovski on 1/20/21.
//  Copyright © 2021 Stefan Kjoropanovski-Resen. All rights reserved.
//

import UIKit

class UserCell: UITableViewCell {

    lazy var backView: UIView = {
        let view = UIView(frame: CGRect(x: 10, y:6, width: self.frame.width - 20 + 90, height: 110))
        view.backgroundColor = UIColor.white
        return view
    }()
    
    lazy var userImage: UIImageView  = {
        let userImg = UIImageView(frame: CGRect(x: 4, y: 4, width: 104, height: 104))
        userImg.contentMode = .scaleAspectFill
        return userImg
    }()
    
    lazy var nameLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 116, y: 8, width: backView.frame.width - 116, height: 30))
        label.textAlignment = .left
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        return label
    }()
    
    lazy var typeLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 116, y: 42, width: backView.frame.width - 116, height: 30))
        label.textAlignment = .left
        label.font = label.font.withSize(14)
        return label
    }()
    
    lazy var dateLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 116, y: 76, width: backView.frame.width - 116, height: 30))
        label.textAlignment = .left
        label.font = label.font.withSize(14)
        return label
    }()
    
    override func layoutSubviews() {
        contentView.backgroundColor = UIColor.clear
        backgroundColor = UIColor.clear
        userImage.layer.cornerRadius = 52
        userImage.clipsToBounds = true
        backView.layer.cornerRadius = 45
        backView.clipsToBounds = true
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        addSubview(backView)
        backView.addSubview(userImage)
        backView.addSubview(nameLabel)
        backView.addSubview(typeLabel)
        backView.addSubview(dateLabel)
    }

}
