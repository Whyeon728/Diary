//
//  StarCell.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class StarCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.masksToBounds = true
        self.contentView.layer.cornerRadius = 5.0
        self.contentView.layer.borderWidth = 2.0
        self.contentView.layer.borderColor = UIColor.orange.cgColor

        layer.masksToBounds = false
        layer.shadowOpacity = 0.8
        layer.shadowOffset = CGSize(width: -2, height: 2)
        layer.shadowRadius = 3
    }
}
