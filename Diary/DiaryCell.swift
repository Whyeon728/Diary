//
//  DiaryCell.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class DiaryCell: UICollectionViewCell {
    
    @IBOutlet weak var titleLabel: UILabel!
    
    @IBOutlet weak var dateLabel: UILabel!
    
    //MARK: - DiaryCell 테두리 설정
    // UIView가 스토리보드 또는 XIB 를 통해 생성될때 이 생성자를 통해 생성됨
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        self.contentView.layer.cornerRadius = 3.0
        self.contentView.layer.borderWidth = 1.0
        self.contentView.layer.borderColor = UIColor.black.cgColor
        
    }
}
