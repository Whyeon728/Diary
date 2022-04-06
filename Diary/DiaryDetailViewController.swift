//
//  DiaryDetailViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

//protocol DiaryDetailViewDelegate: AnyObject {
//    func didSelectDelete(indexPath: IndexPath)
//    func didSelectStar(indexPath: IndexPath, isStar: Bool) 노티피케이션으로 대체
//}

class DiaryDetailViewController: UIViewController {

    @IBOutlet weak var titleLabel: UILabel!
        
    @IBOutlet weak var contentsTextView: UITextView!
        
    @IBOutlet weak var dateLabel: UILabel!
    
    //weak var delegate: DiaryDetailViewDelegate?
    
    var starButton: UIBarButtonItem?
    
    // 일기장 콜렉션뷰에서 전달 받을 프로퍼티
    var diary: Diary? // 뷰컨트롤러에서 프리페어로 전달받음
    var indexPath: IndexPath?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureView() // 뷰 초기화
        NotificationCenter.default.addObserver(self, selector: #selector(starDiarynotification(_:)), name: NSNotification.Name("starDiary"), object: nil)
    }
    
    // 전달 받은 일기장을 뷰에 초기화
    private func configureView() {
        guard let diary = self.diary else { return }
        self.titleLabel.text = diary.title
        self.contentsTextView.text = diary.contents
        self.dateLabel.text = self.dateToString(date: diary.date)
        // 즐겨찾기 버튼 생성(별모양)
        self.starButton = UIBarButtonItem(image: nil, style: .plain, target: self, action: #selector(tabStarButton))
        self.starButton?.image = diary.isStar ? UIImage(systemName: "star.fill") : UIImage(systemName: "star")
        self.starButton?.tintColor = .orange
        self.navigationItem.rightBarButtonItem = self.starButton
    }
    
    @objc func starDiarynotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String : Any] else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        guard let diary = self.diary else { return }
        if diary.uuidString == uuidString {
            self.diary?.isStar = isStar
            self.configureView()
        }
    }
    
    @objc func tabStarButton() {
        guard let isStar = self.diary?.isStar else { return }

        if isStar {
            self.starButton?.image = UIImage(systemName: "star")
        } else {
            self.starButton?.image = UIImage(systemName: "star.fill")
        }
        self.diary?.isStar = !isStar
        //print("star toggled")                                      // 좌측 값이 null 이면 우측값 반환
        //self.delegate?.didSelectStar(indexPath: indexPath, isStar: self.diary?.isStar ?? false)
        
        //MARK: - Star Notification
        NotificationCenter.default.post(
            name: NSNotification.Name("starDiary"),
            object: [
                "diary": self.diary,
                "isStar": self.diary?.isStar ?? false,
                "uuidString": diary?.uuidString
            ],
            userInfo: nil)
    }
    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }
  
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        self.diary = diary
        self.configureView()
    }
    //MARK: - Edit Button ; WriteDiaryViewController로 Push
    @IBAction func tabEditButton(_ sender: UIButton) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "WriteDiaryViewController") as? WriteDiaryViewController else { return }
        
        //WriteDiaryViewController에 indexPath 값과 다이어리 객체를 열거형 객체에 넘겨줌
        guard let indexPath = self.indexPath else { return }
        guard let diary = self.diary else { return }
        // 화면 넘어가기전에 수정모드로 변경
        viewController.diaryEditorMode = .edit(indexPath, diary)
        
        //MARK: - Notification Observing
        //옵저버를 추가하게되면 특정이름의 노티피케이션의 이벤트가 발생하였는지 관찰하고 발생하면 특정 기능을 수행함
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        self.navigationController?.pushViewController(viewController, animated: true)
    }
    
    
    //MARK: - Delete Button
    // 현재 삭제될 일기장의 인덱스패쓰를 델리게이트에 넘겨주고 전 화면으로 팝
    @IBAction func tabDeleteButton(_ sender: UIButton) {
        guard let uuidString = self.diary?.uuidString else { return }
        //self.delegate?.didSelectDelete(indexPath: indexPath)
        NotificationCenter.default.post(
            name: NSNotification.Name("deleteDiary"),
            object: uuidString,
            userInfo: nil
        )
        self.navigationController?.popViewController(animated: true)
    }
    
    deinit { // 현재 뷰가 사용되지 않을때 제거
        NotificationCenter.default.removeObserver(self)
    }
}
