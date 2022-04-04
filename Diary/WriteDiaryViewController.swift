//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker() // 데이트 피커 객체 생성
    private var diaryDate: Date? // 데이트피커에서 선택된 날짜 데이터를 담는 프로퍼티
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
    }
    
    //MARK: - 내용 TextView 테두리 설정
    private func configureContentsTextView() {
        // UIColor 값 0.0 ~ 1.0 사이값 넣어야 함으로 255로 나누었음
        let borderColor = UIColor(red: 220/255, green: 220/255, blue: 220/255, alpha: 1.0)
        
        // UIKit 객체는 모두 layer 라는 core graphic 을 다루는 프로퍼티를 가지고 있음.
        //레이어에 색상을 지정하기 위해 컬러타입을 cgColor로 해줌
        self.contentsTextView.layer.borderColor = borderColor.cgColor
        self.contentsTextView.layer.borderWidth = 0.5 // 테두리 너비 설정
        self.contentsTextView.layer.cornerRadius = 5.0 // 테두리 동그란 정도 설정
    }
    
    //MARK: - 데이트피커 설정 함수
    private func configureDatePicker() {
        self.datePicker.datePickerMode = .date // 데이트피커 모드 설정; 날짜만 나오게
        self.datePicker.preferredDatePickerStyle = .wheels // 데이트피커 스타일 설정; 돌리기
        
        // addTarget 메소드는 UIController가 객체가 이벤트에 응답하는 방식을 설정해주는 메소드
        // 첫번째 파라미터 target은 처리할 컨트롤러; 두번째 파라미터 action에는 이벤트가 발생할때 응다하여 호출할 메소드;
        // 세번째 파라미터는 어떤 이벤트에서 해당함수가 동작하게 할건지 설정; 값 바뀔때로 설정
        self.datePicker.addTarget(self, action: #selector(datePickerValueDidChange(_:)), for: .valueChanged)
        self.dateTextField.inputView = self.datePicker // 데이트텍스트필드를 선택할때 데이트 피커가 나오게 한다.
    }
    
    //데이트피커 셀렉터
    @objc private func datePickerValueDidChange(_ datePicker: UIDatePicker) {
        let formatter = DateFormatter() //날짜와 텍스트를 변환해주는 역할
        formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)" // EEEEE 는 요일 한글자 표현; EEE 전체표현
        formatter.locale = Locale(identifier: "ko_KR") // 포멧 텍스트 한국어 설정
        self.diaryDate = datePicker.date // 데이트피커에서 선택한 날짜를 diaryDate에 Date 타입으로 할당
        //텍스트 필드에 데이트필드에서 선택한 날짜를 포매터를 이용해 내가 원하는 형식의 날짜를 문자열 타입으로 할당한다.
        self.dateTextField.text = formatter.string(from: datePicker.date)
    }
    
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
    }
}
