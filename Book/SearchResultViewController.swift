//
//  SearchResultViewController.swift
//  Book
//
//  Created by OneAndZero on 8/25/19.
//  Copyright © 2019 Korea University. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchResultViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    
    var pageController: UIPageViewController!
    
    @IBOutlet var likeButton: UIBarButtonItem!
    @IBOutlet var infoButton: UIBarButtonItem!
    @IBOutlet var textView: UITextView!
    
    var dataContents: [String]=[]
    var shuffled : [Int] = []
    var writings : [String : [String : Any]]! = [:]
    var results : Array<String> = []
    var random : [Int] = []
    
    var showedData: Array<Int> = []
    var nowTextNum : Int = -1
    
    var likedThisContent : Int = -1
    
    var fontSizeReceiver: String = ""
    var fontReceiver: String = ""
    
    
    var database : DatabaseReference!
    
    
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
    override func viewDidLoad() {
        super.viewDidLoad()
        
        database = Database.database().reference()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(share(sender:)))

        self.pageController = UIPageViewController(transitionStyle: .pageCurl, navigationOrientation: .horizontal, options: nil)
        self.pageController.delegate = self
        self.pageController.dataSource = self
        guard let poem = self.storyboard?.instantiateViewController(withIdentifier: "Poem") as? SminPageViewController else {
            return
        }
        
        //fill contents
        results = [String](repeating:"A", count : dataContents.count)
        
        random = [Int](repeating:0, count : dataContents.count)
        
        var number = [Int](repeating:0, count : dataContents.count)
        
        for i in 0...number.count - 1 {
            number[i] = i
        }
        
        for i in 0...random.count - 1 {
            let rand = Int(arc4random_uniform(UInt32(number.count)))
            
            random[i] = number[rand]
            
            number.remove(at: rand)
        }
        
        for i in 0...dataContents.count - 1 {
            guard let writing = writings[dataContents[random[i]]] else {
                return
            }
            
            if let tempWriting : String = writing["contents"] as? String {
                results[i] = tempWriting
            }
        }
        print("results count \(results.count)")
        self.nowTextNum = -1
        poem.test = "\n\n\n"+nextChoose()
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        var savedFontType = UserDefaults.standard.object(forKey: "defaultFontType")
        var savedFontSize = UserDefaults.standard.object(forKey: "defaultFontSize")
        
        if let defaultFontType = savedFontType as? String,
            let defaultFontSize = savedFontSize as? String{
            
            textView.font = UIFont(name: defaultFontType, size: CGFloat(NSString(string: defaultFontSize).floatValue))
    }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    //화면 넘기기 --- 나연
    func nextChoose () -> String {
        //다음 글 보여주기
        if nowTextNum < dataContents.count - 1 {
            nowTextNum += 1
            return results[nowTextNum]
        }
        else {
            print("result end")
            return String("end")
        }
        
    }
    func beforeChoose () -> String {
        //옛날 글 보여주기
        if nowTextNum > 0 {
            nowTextNum -= 1
            return results[nowTextNum]
        }
        else {
            print("result front")
            return String("front")
        }
    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let newViewController = storyboard?.instantiateViewController(withIdentifier: "Poem") as? SminPageViewController else {
            return nil
        }
        let checkFirst = nowTextNum
        newViewController.test = "\n\n\n"+beforeChoose()
        newViewController.fontReceiver = self.fontReceiver
        newViewController.fontSizeReceiver = self.fontSizeReceiver
        if checkFirst == nowTextNum {
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
        let checkFirst = nowTextNum
        newViewController.test = "\n\n\n"+nextChoose()
        newViewController.fontReceiver = self.fontReceiver
        newViewController.fontSizeReceiver = self.fontSizeReceiver
        if checkFirst == nowTextNum {
            let alert = UIAlertController(title: "마지막 페이지입니다", message: "검색 화면으로 이동하겠습니까", preferredStyle: .alert)
            let okAction = UIAlertAction(title: "확인", style: .default)  {
                (action) in
                self.navigationController?.popToRootViewController(animated: false)
            }
            let cancelAction = UIAlertAction(title: "취소", style: .cancel, handler: nil)
            alert.addAction(okAction)
            alert.addAction(cancelAction)
            self.present(alert, animated: true, completion: nil)
            return nil
        }
        
        checkLiked()
        return newViewController
    }
    
    func pageViewController(_ pageViewController: UIPageViewController,
                            didFinishAnimating finished: Bool,
                            previousViewControllers: [UIViewController],
                            transitionCompleted completed: Bool) {
        print(previousViewControllers.count)
        print(completed)
        if completed == false{
            beforeChoose()
        }
    }
    @IBAction func touchUpLikeButton(_ sender : UIButton) {
        if currentUserKey.count == 0 {
            //계정 없음
            let alert = UIAlertController(title: "로그인시 이용할 수 있는 서비스 입니다.", message: "", preferredStyle: .alert)
            let okAction = UIAlertAction(title : "확인", style: .default)
            
            alert.addAction(okAction)
            self.present(alert, animated: true, completion: nil)
            return
        }
        
        
        if checkLiked() {
            //삭제
            likeArray.remove(at: likedThisContent)
            database.child("users").child(currentUserKey).updateChildValues(["likes" : likeArray])
            //색 바꾸기
            sender.tintColor = UIColor.blue
        }
        else {
            //더하기
            likeArray.append(dataContents[random[nowTextNum]])
            database.child("users").child(currentUserKey).updateChildValues(["likes" : likeArray])
            sender.tintColor = UIColor.red
        }
    }
    
    func checkLiked() -> (Bool){
        if likeArray.count >= 1 {
            for i in 0...likeArray.count - 1 {
                if likeArray[i] == dataContents[random[nowTextNum]] {
                    likeButton.tintColor = UIColor.red
                    likedThisContent = i
                    return true
                }
            }
            likeButton.tintColor = nil
            return false
        }
        likeButton.tintColor = nil
        return false
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
        
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController = segue.destination as? SearchInfoViewController else {
            print("목적지가 SearchInfoViewController가 아닙니다")
            return
        }
        let writingsArray =  Array(self.writings)
        if nowTextNum != -1 {
            nextViewController.nowText = writingsArray[random[nowTextNum]].value
        }
    }
}


