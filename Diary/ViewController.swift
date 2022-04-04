//
//  ViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]() {
        didSet { //다이어리 리스트의 값이 바뀔때마다  userdefaults에 저장
            self.saveDiaryList()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configureCollectionView() // delegate, dataSource 프로토콜 채택후 호출
        self.loadDiaryList() // UserDefaults 데이터 호출
    }
    
    //MARK: - 콜렉션뷰 속성 설정
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout() // 스크롤속성, 헤더푸터설정 등의 기능을 가짐.
        //콜렉션 뷰의 좌우위아래 간격 10으로 설정
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //일기 작성 화면으로 전환시 객체 인스턴스를 가져온다
        if let writeDiaryViewController = segue.destination as? WriteDiaryViewController {
            // 현재의 컨트롤러를 일기작성화면 delegate 프로퍼티에 넘겨준다.
            writeDiaryViewController.delegate = self // 현재 컨트롤러에 프로토콜을 채택해준다
        }
    }
    
    //MARK: - User Defaults Save
    private func saveDiaryList() {
        let data = self.diaryList.map {
            [
                "title": $0.title,
                "contents": $0.contents,
                "date": $0.date,
                "isStar": $0.isStar
            ]
        }
        //UserDefaults 객체를 가져옴
        let userDefaults = UserDefaults.standard
        userDefaults.set(data, forKey: "diaryList")
    }
    
    //MARK: - User Defaults Load
    private func loadDiaryList() {
        let userDefaults = UserDefaults.standard
        //object 메소드는 Any 타입으로 리턴이되므로 딕셔너리타입으로 타입캐스팅이 필요함.
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String: Any]] // 딕셔너리 배열형태
        else {return}
        self.diaryList = data.compactMap {//축약인자로 딕셔너리에 차례로 접근
            // 딕셔너리의 value가 Any타입이므로 String, Date, Bool 으로 타입캐스팅
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil }
            guard let date = $0["date"] as? Date else {return nil}
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(title: title, contents: contents, date: date, isStar: isStar)
        }
        
        //MARK: - 로드될때 일기가 최신순으로 정렬이 되도록 하는 기능
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 내림차순 정렬
        })
    }

    
    private func dateToString(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yy년 MM월 dd일(EEEEE)"
        formatter.locale = Locale(identifier: "ko_KR")
        return formatter.string(from: date)
    }

}

//MARK: - extension WriteDiaryViewDelegate 프로토콜 채택

extension ViewController: WriteDiaryViewDelegate {
    func didSelectRegister(diary: Diary) {
        self.diaryList.append(diary) // 현재 컨트롤러의 다이어리 리스트에 WriteDiaryViewController에서 작성된 일기를 추가한다.
        //MARK: - 등록하고난 뒤에 일기가 최신순으로 정렬이 되도록 하는 기능
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending // 내림차순 정렬
        })
        self.collectionView.reloadData() // 등록버튼을 눌러 일기가 추가될때마다 컬랙션뷰를 다시 로드
    }
}

//MARK: - extension UICollectionViewDataSource 프로토콜 채택

// 콜렉션뷰로 보여지는 콘텐츠의 데이터를 관리하는 객체
extension ViewController: UICollectionViewDataSource {
    
    // 섹션에 몇개에 셀을 보이게 할지 정하는 함수
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count //일기의 개수만큼 보여지게 한다.
    }
    
    // 컬렉션뷰에 지정된 위치에 표시할 셀을 요청하는 메소드
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        //재사용할 셀 모양과 배치될 위치를 받아 인스턴스를 가지게된다;
        guard let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "DiaryCell", for: indexPath) as? DiaryCell else {
            return UICollectionViewCell()}// DiaryCell로 다운캐스팅 실패시 빈 셀 반환
        let diary = self.diaryList[indexPath.row] // 행 값이 일기 개수만큼 가질수 있음.
        cell.titleLabel.text = diary.title // 컬렉션뷰의 제목라벨에 일기 제목
        cell.dateLabel.text = self.dateToString(date: diary.date) // 데이트포매터를 통해 문자열로 바꾸어 할당
        return cell // 값이 저장된 셀을 반환
    }
    
}

extension ViewController: UICollectionViewDelegateFlowLayout {
    
    //셀의 사이즈를 설정하는 역할을하는 메소드; CGSize로 설정
    // 행에 2개씩 일기가 보이고 행과 행간에 220포인트가 된다
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // 현재 구동되는 아이폰 화면 넓이에서 configureCollectionView() 에서 contentInset 에 설정한 간격(10) 보다 크게 빼준다; 여백위해서
        // 높이는 200고정
        //Editor placeholder in source file; 커맨드+쉬프트+B 로 해결가능
        return CGSize(width: (UIScreen.main.bounds.width / 2) - 20, height: 200)
        
    }
}
