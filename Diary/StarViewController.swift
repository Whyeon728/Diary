//
//  StarViewController.swift
//  Diary
//
//  Created by Whyeon on 2022/04/04.
//

import UIKit

class StarViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    private var diaryList = [Diary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.loadStarDiaryList()
        self.configureCollectionView()
        
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(editDiaryNotification(_:)),
            name: NSNotification.Name("editDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(starDiaryNotification(_:)),
            name: NSNotification.Name("starDiary"),
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(deleteDiaryNotification(_:)),
            name: NSNotification.Name("deleteDiary"),
            object: nil
        )

    }
    //MARK: - 콜렉션뷰 속성설정
    private func configureCollectionView() {
        self.collectionView.collectionViewLayout = UICollectionViewFlowLayout()
        //셀끼리의 앞뒤좌우 간격 설정
        self.collectionView.contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        self.collectionView.delegate = self
        self.collectionView.dataSource = self
    }
    
    // 유저디폴츠에서 즐겨찾기된 일기만 가져오기
    private func loadStarDiaryList() {
        let userDefaults = UserDefaults.standard
        guard let data = userDefaults.object(forKey: "diaryList") as? [[String : Any]] else { return }
        self.diaryList = data.compactMap {
            guard let uuidString = $0["uuidString"] as? String else { return nil}
            guard let title = $0["title"] as? String else { return nil }
            guard let contents = $0["contents"] as? String else { return nil}
            guard let date = $0["date"] as? Date else { return nil }
            guard let isStar = $0["isStar"] as? Bool else { return nil }
            return Diary(uuidString: uuidString, title: title, contents: contents, date: date, isStar: isStar)
        }.filter({
            $0.isStar == true
        }).sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
    }
    
    //수정이 일어났을때 호출되는 셀렉터
    @objc func editDiaryNotification(_ notification: Notification) {
        guard let diary = notification.object as? Diary else { return }
        guard let index = self.diaryList.firstIndex(where: {
            $0.uuidString == diary.uuidString
        }) else { return }
        self.diaryList[index] = diary
        self.diaryList = self.diaryList.sorted(by: {
            $0.date.compare($1.date) == .orderedDescending
        })
        self.collectionView.reloadData()
    }
    
    //즐겨찾기 토글 이벤트가 발생했을때 호출되는 셀렉터
    @objc func starDiaryNotification(_ notification: Notification) {
        guard let starDiary = notification.object as? [String : Any] else { return }
        guard let diary = starDiary["diary"] as? Diary else { return }
        guard let isStar = starDiary["isStar"] as? Bool else { return }
        guard let uuidString = starDiary["uuidString"] as? String else { return }
        if isStar {
            self.diaryList.append(diary)
            self.diaryList = self.diaryList.sorted(by: {
                $0.date.compare($1.date) == .orderedDescending
            })
            self.collectionView.reloadData()
        } else {
            guard let index = self.diaryList.firstIndex(where: { $0.uuidString == uuidString }) else { return }
            self.diaryList.remove(at: index)
            self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])
        }
    }
    
    //삭제 이벤트 발생시 즐겨찾기 리스트에서도 삭제대도록 하는 셀렉터
    @objc func deleteDiaryNotification(_ notification: Notification) {
        guard let uuidString = notification.object as? String else { return }
        guard let index = self.diaryList.firstIndex(where: {
            $0.uuidString == uuidString
        }) else { return }
        self.diaryList.remove(at: index)
        self.collectionView.deleteItems(at: [IndexPath(row: index, section: 0)])

    }
}
private func dateToString(date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy년 MM월 dd일(EEEEE)"
    formatter.locale = Locale(identifier: "ko_KR")
    return formatter.string(from: date)
}

extension StarViewController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.diaryList.count // 즐겨찾기된 일기장의 갯수만큼 아이템 생성
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell { // 재사용할셀 선택; 다운캐스팅 실패시 빈셀 반환
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "StarCell", for: indexPath)
                as? StarCell else { return UICollectionViewCell() }
        let diary = self.diaryList[indexPath.row] // 배열에 저장되있는 일기를 가져오기
        cell.titleLabel.text = diary.title
        cell.dateLabel.text = dateToString(date: diary.date)
        return cell
    }
}

extension StarViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: UIScreen.main.bounds.width - 20, height: 80)
    }
}

//MARK: - 즐겨찾기 탭에서 아이템 클릭시 상세화면이동 델리게이트
extension StarViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let viewController = self.storyboard?.instantiateViewController(withIdentifier: "DiaryDetailViewController") as? DiaryDetailViewController else { return }
        let diary = self.diaryList[indexPath.row]
        viewController.diary = diary
        viewController.indexPath = indexPath
        self.navigationController?.pushViewController(viewController, animated: true)
    }
}
