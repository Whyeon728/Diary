//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
        
    @IBOutlet weak var contentsTextView: UITextView!
        
    @IBOutlet weak var dateLabel: UILabel!
    
    // 일기장 콜렉션뷰에서 전달 받을 프로퍼티
    var diary: Diary?
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView() // 뷰 초기화

    }
    
    // 전달 받은 일기장을 뷰에 초기화
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
  
    @IBAction func tabEditButton(_ sender: UIButton) {
        
    }
    
    @IBAction func tabDeleteButton(_ sender: UIButton) {
    }
    
    
}
