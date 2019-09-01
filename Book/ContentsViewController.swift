//
//  ContentsViewController.swift
//  Book
//
//  Created by cscoi029 on 2019. 8. 23..
//  Copyright © 2019년 Korea University. All rights reserved.


import UIKit
import FirebaseDatabase

class ContentsViewController: UIViewController , UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    @IBOutlet var text : UITextView!
    @IBOutlet var likeButton : UIBarButtonItem!
    
    var pageController: UIPageViewController!
    var database : DatabaseReference!
    var writings : [String : [String : Any]]! = [:]
    var writingsCount : Int = 0
    var databaseHandler : DatabaseHandle!
    var databaseName : String = "writings"
    //var writingsArray : Array = []
    var dataContents: [String]=[]
    var showedData: Array<Int> = []
    
    var nowTextNum : Int = -1
    var firstTimeLoad : Bool = true
    
    var fontSizeReceiver: String = ""
    var fontReceiver: String = ""
    
    var likedThisContent : Int = -1
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // 주원 - 공유버튼
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))
        
        UserDefaults.standard.set("15", forKey: "defaultFontSize")
        UserDefaults.standard.set("NanumSquareR", forKey: "defaultFontType")

        configureDatabase()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super .viewWillAppear(animated)
        //configureDatabase()
        
    }
    
    
    
    // text 세팅 :: 파이어베이스 불러오기
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName)
            .observe(.value, with: {(snapshot) -> Void in
                guard let tempWritings = snapshot.value as? [String : [String : Any]]
                    else{
                        print("데이터 불러오기 실패")
                        return
                }
                self.writings = tempWritings
                self.writingsCount = self.writings.count
                print("총 개수 \(self.writingsCount)")
                if self.firstTimeLoad {
                    self.firstTimeLoad = false
                    self.setDataContents()
                    self.nowTextNum = -1
                    self.pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
                    self.pageController.delegate = self
                    self.pageController.dataSource = self
                    guard let poem = self.storyboard?.instantiateViewController(withIdentifier: "Poem") as? SminPageViewController else {
                        return
                    }
                    poem.test = "\n\n\n"+self.chooseNext(index: 1)
                    poem.fontReceiver = self.fontReceiver
                    poem.fontSizeReceiver = self.fontSizeReceiver
                    self.addChildViewController(self.pageController)
                    self.view.addSubview(self.pageController.view)
                    self.pageController.view.translatesAutoresizingMaskIntoConstraints = false
                    self.pageController.view.topAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.topAnchor).isActive = true
                    self.pageController.view.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
                    self.pageController.view.leadingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.leadingAnchor).isActive = true
                    self.pageController.view.trailingAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.trailingAnchor).isActive = true
                    self.pageController.setViewControllers([poem],
                                                           direction: .forward,
                                                           animated: true,
                                                           completion: nil)
                }
            })
        
    }
    //불러온 데이터 콘텐츠를 배열로 세팅
    func setDataContents() {//나연
        
        nowTextNum = -1
        let writingsCount : Int = self.writings.count
        let writingsArray = Array(self.writings)
        dataContents = [String](repeating:"A", count : self.writings.count)
        for i in 0...writingsCount-1 {
            let writing = writingsArray[i]
            if let tempWriting : String = writing.value["contents"] as? String {
                dataContents[i] = tempWriting
            }
        }
    }
    
    //chooseNext  --- 민
    func chooseNext (index:Int)->(String){ //index에는 -1(이전)혹은 1(이후)만 들어올 수 있음
        //이전 텍스트
        if dataContents.count == 0 {
            print("Data가 없음")
            return "해당되는 자료가 없습니다"
        }
        if index == -1 {
            if nowTextNum >= 1 {
                nowTextNum -= 1
            }
        }
            //다음텍스트
        else if index == 1 {
            //한 번 보여줬던 텍스트면::nowTextNum++
            if(nowTextNum+1 < showedData.count){
                nowTextNum += 1
            }
                //아니면::새로운 랜덤 텍스트 선택
            else {
                let fileSize:Int = dataContents.count
                var choosed: Bool = false
                var returnValue: Int = Int(arc4random_uniform(UInt32(fileSize)))
                var checkIndex: Int = -1
                var countInChoosed:Int = 5
                var countInChoosedInit: Int = 5
                // fileSize에 따라 countInChoosedInit의 크기 조절
                if fileSize <= 7{
                    if fileSize>=5 {
                        countInChoosedInit = 3
                    } else if fileSize>=3 {
                        countInChoosedInit = 1
                    } else {
                        countInChoosedInit = 0
                    }
                }
                //countInChoosedInit개 만큼의 이전 페이지와 겹치지 않는 게 선택될 때까지 반복해서 랜덤뽑기
                while choosed == false {
                    checkIndex = showedData.endIndex - 1
                    choosed = true
                    countInChoosed = countInChoosedInit
                    returnValue = Int(arc4random_uniform(UInt32(fileSize)))
                    while countInChoosed>0 && checkIndex>=0 {
                        if returnValue == showedData[checkIndex] {
                            choosed = false
                        }
                        countInChoosed -= 1
                        checkIndex -= 1
                    }
                }
                showedData.append(returnValue)
                nowTextNum += 1
            }
        } else {
            print("chooseNext에 잘못된 매개변수가 들어옴")
        }
        return dataContents[showedData[nowTextNum]]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        print(previousViewControllers.count)
        print(completed)
        if completed == false{
            chooseNext(index: -1)
        }
    }
    /*pageView delegate 필수 */ // 민
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "Poem") as? SminPageViewController else {
            return nil
        }
        let checkFirst = nowTextNum
        newViewController.test = "\n\n\n"+chooseNext(index: -1)
        newViewController.fontReceiver = self.fontReceiver
        newViewController.fontSizeReceiver = self.fontSizeReceiver
        if checkFirst == nowTextNum && nowTextNum == 0 {
            let alert = UIAlertController(title: "첫 번째 페이지입니다", message: "오른쪽으로 넘겨주세요", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default) {
                (action) in
            }
            
            // 넣기
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        checkLiked()
        return newViewController
    }
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "Poem") as? SminPageViewController else {
            return nil
        }
        newViewController.test = "\n\n\n"+chooseNext(index: 1)
        newViewController.fontReceiver = self.fontReceiver
        newViewController.fontSizeReceiver = self.fontSizeReceiver
        checkLiked()
        return newViewController
    }
    
    @objc func fontSizeApplied(_ notification: Notification) {
        guard  let fontSizeText : String = notification.userInfo!["fontSizeKey"] as? String else {
            return
        }
        
        self.fontSizeReceiver = fontSizeText
    }
    
    
    @objc func fontTypeApplied(_ notification: Notification) {
        guard  let fontTypeText : String = notification.userInfo!["fontType"] as? String else {
            return
        }
        
        self.fontReceiver = fontTypeText
    }
    
    
    //----------------------------------------------------------------------------------------------------------
    
    //////좋아요 버튼 --- 나연
    @IBAction func touchUpLikeButton(_ sender : UIButton) {
        if currentUserKey.count == 0 {
            //계정 없음
            let alert = UIAlertController(title: "로그인시 이용할 수 있는 서비스 입니다.", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title : "확인", style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        let array = Array(self.writings)
        
        if checkLiked() {
            //삭제
            likeArray.remove(at: likedThisContent)
            database.child("users").child(currentUserKey).updateChildValues(["likes" : likeArray])
            //색 바꾸기
            sender.tintColor = UIColor.blue
        }
        else {
            //더하기
            likeArray.append(array[showedData[nowTextNum]].key)
            database.child("users").child(currentUserKey).updateChildValues(["likes" : likeArray])
            sender.tintColor = UIColor.red
        }
    }
    
    func checkLiked() -> (Bool){
        let array = Array(self.writings)
        
        if likeArray.count == 0 {
            return false
        }
        
        for i in 0...likeArray.count - 1 {
            if likeArray[i] == array[showedData[nowTextNum]].key {
                likeButton.tintColor = UIColor.red
                likedThisContent = i
                return true
            }
        }
        likeButton.tintColor = UIColor.blue
        return false
    }
    
    
    // 주원 - 공유버튼
        @IBOutlet weak var shareButton: UIBarButtonItem!
    /* 출처:  https://stackoverflow.com/questions/37938722/how-to-implement-share-button-in-swift/47569815#47569815 */
    @objc func share(sender:UIView){
     UIGraphicsBeginImageContext(view.frame.size)
     view.layer.render(in: UIGraphicsGetCurrentContext()!)
     let image = UIGraphicsGetImageFromCurrentImageContext()
     UIGraphicsEndImageContext()
     
     let textToShare = "Check out my app"
     
     if let myWebsite = URL(string: "http:itunes.apple.com/app/idXXXXXXXXX") {//Enter link to your app here
     let objectsToShare = [textToShare, myWebsite, image ?? #imageLiteral(resourceName: "app-logo")] as [Any]
     let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
     
     //Excluded Activities
     activityVC.excludedActivityTypes = [UIActivity.ActivityType.airDrop, UIActivity.ActivityType.addToReadingList]
     
     
     activityVC.popoverPresentationController?.sourceView = sender
     
     self.present(activityVC, animated: true, completion: nil)
     }    }
    
     
 
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController = segue.destination as? ContentInfoViewController else {
            print("목적지가 ContentInfoViewController가 아닙니다")
            return
        }
        let writingsArray =  Array(self.writings)
        if nowTextNum != -1 {
            nextViewController.nowText = writingsArray[showedData[nowTextNum]].value
        }
    }
    
    
    
    //------------------------------------------------------------------------------------------------------------
    
    
    ////////////바 숨기기
    //    @IBAction func showHiddenBar(_ sender: UITapGestureRecognizer) {
    //        self.navigationController?.navigationBar.isHidden = true
    //    }
    //    self.navigationController?.hidesBarsOnTap
    //    self.navigationController?.navigationBar.isHidden = true
    //    self.tabBarController?.tabBar.isHidden = true
    
}
