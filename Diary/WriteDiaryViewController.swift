//
//  WriteDiaryViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

//MARK: - 일기작성 화면에서 작성된 내용을 전달하는 delegate
protocol WriteDiaryViewDelegate: AnyObject {
    func didSelectRegister(diary: Diary) // 내용이 작성된 다이어리 객체를 전달하는 메소드
}


class WriteDiaryViewController: UIViewController {

    @IBOutlet weak var titleTextField: UITextField!
    
    @IBOutlet weak var contentsTextView: UITextView!
    
    @IBOutlet weak var dateTextField: UITextField!
    
    @IBOutlet weak var confirmButton: UIBarButtonItem!
    
    private let datePicker = UIDatePicker() // 데이트 피커 객체 생성
    private var diaryDate: Date? // 데이트피커에서 선택된 날짜 데이터를 담는 프로퍼티
    weak var delegate: WriteDiaryViewDelegate? // 델리게이트 프로퍼티 선언
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureContentsTextView()
        self.configureDatePicker()
        self.confirmButton.isEnabled = false // 처음 뷰를 로드할때 등록버튼 비활성
        self.configureInputField() // 등록버튼 활성화여부 타겟, 델리게이트
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
        self.datePicker.locale = Locale(identifier: "ko_KR")
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
        self.dateTextField.sendActions(for: .editingChanged) // 날짜가 변경될때마다 editingChanged 이벤트 발생.
    }
    
    //유저가 화면을 터치할때 실행되는 메소드
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true) // 빈화면을 터치하면 편집을 끝낸다. 즉 데이트피커를 닫아줌.
    }
    
    //MARK: - 제목, 내용, 날짜 비워져있으면 등록버튼 비활성
    private func configureInputField() { //뷰디드로드에 호출
        self.contentsTextView.delegate = self //내용 필드는 delegate로 옵저빙해서 활성여부 판단.
        
        //제목필드는 애드타겟으로 편집 이벤트 감지하여 등록버튼 활성여부 판단.
        self.titleTextField.addTarget(self, action: #selector(titleTextFieldDidChange(_:)), for: .editingChanged)
        
        //날짜필드도 애드타겟으로 편집 이벤트 감지하여 등록버튼 활성여부 판단. 하지만 editingChanged는 키보드 입력이므로 데이트 피커에서 날짜를 입력해도 바뀌지 않음. 따라서 데이트피커가 바뀔때마다 editingChanged 이벤트를 발생하도록 datePickerValueDidChange에 명시.
        self.dateTextField.addTarget(self, action: #selector(dateTextFieldDidChange(_:)), for: .editingChanged)
    }
    
    //제목필드 타겟 셀렉터
    @objc private func titleTextFieldDidChange(_ textField: UITextField) { //제목이 입력될때 호출
        self.validateInputField() //3개의 인풋필드 확인
    }
    
    //날짜필드 타겟 셀렉터
    @objc private func dateTextFieldDidChange(_ textField: UITextField) {
        self.validateInputField() // 날짜가 변경될때마다 등록버튼 활성화 여부 체킹
    }
    
    //모든 인풋필드가 비어있지 않으면 등록버튼이 활성되게하는 메서드; 제목,내용,날짜 필드에 입력될때 이 메서드를 호출해 체킹
    private func validateInputField() {
        self.confirmButton.isEnabled = !(self.titleTextField.text?.isEmpty ?? true) &&
        !(self.dateTextField.text?.isEmpty ?? true) && !self.contentsTextView.text.isEmpty
    }
    
    //MARK: - 등록버튼 동작
    // 등록버튼을 눌렀을때 다이어리 객체를 생성하고 델리게이트에 정의한
    // didSelectRegister()를 호출해 다이어리 객체를 ViewController에 데이터 전달
    @IBAction func tabConfirmButton(_ sender: UIBarButtonItem) {
        guard let title = self.titleTextField.text else {return}
        guard let contents = self.contentsTextView.text else {return}
        guard let date = self.diaryDate else { return } //데이트 피커에서 선택된 값을 문자열로 저장한 프로퍼티 할당
        let diary = Diary(title: title, contents: contents, date: date, isStar: false) // 다이어리객체 생성
        self.delegate?.didSelectRegister(diary: diary)
        self.navigationController?.popViewController(animated: true) // 전 화면으로 이동
    }
    
    
}

extension WriteDiaryViewController: UITextViewDelegate {
    
    //textView의 text가 입력될때마다 호출되는 메소드
    func textViewDidChange(_ textView: UITextView) {
        // 내용필드에 입력되면 3개필드다 입력완료되있는지 체킹
        self.validateInputField()
    }
}
