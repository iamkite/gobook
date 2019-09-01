//
//  ViewController.swift
//  Book
//
//  Created by cscoi028 on 2019. 8. 23..
//  Copyright © 2019년 Korea University. All rights reserved.
//

import UIKit
import UserNotifications
import FirebaseDatabase

class ViewController: UIViewController {
    
    
    var database : DatabaseReference!
    var databaseHandler : DatabaseHandle!
    var users : [String : [String : Any]]! = [:]
    var writings : [String : [String : Any]]! = [:]
    var userNames: [UserName] = []
    var dataContents : [String] = []
    // 주원 -(1) local notification
    /* 출처: https://www.youtube.com/watch?v=JuqQUP0pnZY
     https://medium.com/quick-code/local-notifications-with-swift-4-b32e7ad93c2 */
    
    
   // @objc func datePickerChanged(_ datePicker:UIDatePicker) {
    @objc func sendLocalNotification(_ notification: Notification) {
        let center = UNUserNotificationCenter.current()
        let options: UNAuthorizationOptions = [.alert, .sound /*, .badge*/]
        center.requestAuthorization(options: options) {
            (granted, error) in
            if !granted {
                print("User has declined notifications")
            }
        }
        center.getNotificationSettings { (settings) in
            if settings.authorizationStatus != .authorized {
                print("Notifications not allowed")
            }
        }
        for child in writings {
            if let tempType : String = child.value["type"] as? String {
                if tempType == "명언", let tempContent : String = child.value["contents"] as? String {
                    dataContents.append(tempContent)
                }
            }
        }
        
        let randomNum : Int = Int(arc4random_uniform(UInt32(dataContents.count - 1)))
        let content = UNMutableNotificationContent()
        content.title = "오늘의 문학이 배송되었습니다"
        //content.body = "여기용" // 여기에 넣기
        content.body = dataContents[randomNum]
        content.sound = UNNotificationSound.default()
        //content.badge = 1
        UIApplication.shared.applicationIconBadgeNumber = 0
        var date = DateComponents() //(timeIntervalSinceNow: 3600)
//        if let savedTime = UserDefaults.standard.object(forKey: "defaultRemindTime") as? String {
            //let hoursRange = savedTime.startIndex...savedTime.startIndex.advancedBy(1)
//            let hoursRange = savedTime.startIndex...savedTime.index(savedTime.startIndex, offsetBy: 1)
//
//            if let tempHour : Int = Int(savedTime[hoursRange]) {
//                date.hour = tempHour
//                print(type(of: date.hour))
//            }
//            //date.hour = Int(savedTime[hoursRange])
//            let minutesRange = savedTime.index(savedTime.startIndex, offsetBy: 2)..<savedTime.endIndex
//
//            if let tempMin : Int = Int(savedTime[minutesRange]) {
//                date.minute = tempMin
//                print(date.minute)
        
            
            //let minutesRange = savedTime.startIndex.advancedBy(2)...savedTime.endIndex.predecessor()
            //date.minute = Int(savedTime[minutesRange])
    
        date.hour = 15
        date.minute = 31
        
        
      //  let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 3600, repeats: true)
        let uuidString = UUID().uuidString
        let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: trigger)
        
        center.add(request) { (error) in
            if let error = error {
                print("Error")
            }
            
        }
        
    }
    // 여기까지
    
    override func viewDidLoad() {
        super.viewDidLoad()
        database = Database.database().reference()
        decodeAndPopup()
        
        // 주원 (2)
        NotificationCenter.default.addObserver(self, selector: #selector(sendLocalNotification(_:)), name: .remindTimeChanged, object: nil)

        // 여기까지
        databaseHandler = database.child("writings")
            .observe(.value, with: {(snapshot) -> Void in
                guard let tempWritings = snapshot.value as? [String : [String : Any]]
                    else{
                        print("데이터 불러오기 실패")
                        return
                }
                self.writings = tempWritings
        })
       // sendLocalNotification()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func tapShorts(_ sender: UITapGestureRecognizer) {
        let nextViewController = ContentsViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    @IBAction func tapLongs(_ sender: UITapGestureRecognizer) {
        let nextViewController = ContentsViewController()
        navigationController?.pushViewController(nextViewController, animated: true)
    }
    
    //초기에 사용자 받아오기
    func decodeAndPopup() {
        database = Database.database().reference()
        database.child("users").observeSingleEvent(of: .value) { (snapshot) in
            guard let tempUsers = snapshot.value as? [String : [String : Any]] else {
                print("users 데이터 불러오기 실패")
                return
            }
            self.users = tempUsers
            
            //주원
            
            let filePath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("userNames.json")
            let jsonData: Data
            do {
                jsonData = try Data(contentsOf: filePath)
                
                let decoder: JSONDecoder = JSONDecoder()
                do {
                    self.userNames.removeAll()
                    self.userNames = try decoder.decode([UserName].self, from: jsonData)
                    if self.userNames.isEmpty == true {
                        return
                    } else {
                        //나연----------
                        let userName = self.userNames[0].userName
                        
                        for child in self.users {
                            if let temp : String = child.value["name"] as? String {
                                if temp == userName {
                                    currentUserKey = child.key
                                    currentUser = child.value
                                    if let tempLikeArray = currentUser["likes"] as? [String] {
                                        likeArray = tempLikeArray
                                    }
                                    break
                                }
                            }
                            //값들 설정 필요
                        }
                        
                    }
                } catch {
                    print("decode json 실패" + error.localizedDescription)
                }
                
            } catch {
                print("load data 실패" + error.localizedDescription)
                return
            }
        }
        
        
    }
}


// 주원

extension UIViewController {
    func hideKeyboard() {
        let tapGesture: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}

