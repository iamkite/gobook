//
//  AccountViewController.swift
//  Book
//
//  Created by Juwon Lee on 8/23/19.
//  Copyright © 2019 Korea University. All rights reserved.
//

//writing이라는 모델이 있으면 되나..?



import UIKit
import Firebase

var currentUser : [String : Any]! = [:]
var currentUserKey : String = ""
var likeArray : [String] = []

class AccountViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var helloLabel: UILabel!
    let cellIdentifier = "userCell"
    var userNames: [UserName] = []
    
    var database : DatabaseReference!
    var users : [String : [String : Any]]! = [:]
    var databaseHandler : DatabaseHandle!
    var databaseName : String = "users"
    
    var writings : [String : [String : Any]]! = [:]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //DB
        database = Database.database().reference()
        database.child(databaseName).observeSingleEvent(of: .value) { (snapshot) in
            guard let tempUsers = snapshot.value as? [String : [String : Any]] else {
                print("users 데이터 불러오기 실패")
                return
            }
            self.users = tempUsers
            
            //주원
            self.tableView.dataSource = self
            self.tableView.delegate = self
            if self.userNames.isEmpty == true {
                self.helloLabel.text = "첫 방문자님 안녕하세요!"
            }
            self.decodeAndPopup()
        }
        
        databaseHandler = database.child(databaseName)
            .observe(.value, with: {(snapshot) -> Void in
                guard let tempUsers = snapshot.value as? [String : [String : Any]]
                    else{
                        return
                }
                self.users = tempUsers
                self.tableView.reloadData()
            })
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        database = Database.database().reference()
        database.child("writings").observeSingleEvent(of: .value) { (snapshot) in
            guard let tempWritings = snapshot.value as? [String : [String : Any]] else {
                print("writings 데이터 불러오기 실패")
                return
            }
            self.writings = tempWritings
            self.tableView.reloadData()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        decodeAndPopup()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        /*switch section {
         case 0:
         return passages.like.count
         case 1:
         return passages.comment.count
         case 2:
         return passages.myList.count
         default:
         return 0
         }*/
        
        //나연 일단 only like count
        if likeArray.count > 0 {
            return likeArray.count
        }
        else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        /*switch section {
         case 0:
         return "내가 좋아한 글"
         /*case 1:
         return "내가 단 댓글"
         case 2:
         return "내 리스트"*/
         default:
         return "뭔가 잘못됨"
         }*/
        return "내가 좋아한 글"
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        view.backgroundColor = UIColor(red : 237/255,green : 199/255, blue : 121/255,alpha : 0.5)
        
        return view
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
        if likeArray.count > 0 {
            let tempKey = likeArray[indexPath.row]
            guard let writing = writings[tempKey] else {
                return cell
            }
            
            if let passage : String = writing["title"] as? String {
                if passage.count > 0 {
                    cell.textLabel?.text = passage
                }
                else {
                    if let content : String = writing["contents"] as? String{
                        cell.textLabel?.text = content
                    }
                }
            }
            
        }
        else {
            cell.textLabel?.text = "좋아요 한 작품이 없습니다"
        }
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    //------------------------------------------------------------------------
    
    //이미 어플에 아이디가 있는 경우
    func decodeAndPopup() {
        //viewcontroller에서 decode해줌
        
        if currentUserKey.count > 0 , let _ : String = currentUser["name"] as? String {
            
            helloLabel.text = "\(currentUserKey)님 안녕하세요!"
            self.tableView.reloadData()
        }
        else if currentUserKey.count > 0 {
            signUp("닉네임이 등록되어있지않습니다 회원가입을 해주세요")
        }
        else {
            popUpAlert()
        }
    }
    
    //아이디가 없는 경우
    func popUpAlert() {
        
        let alert = UIAlertController(title: "환영합니다", message: "", preferredStyle: .alert)
        let signInAction = UIAlertAction(title : "로그인", style: .default) {
            (action) in self.signIn()
        }
        let signUpAction = UIAlertAction(title : "회원가입", style: .default) {
            (action) in self.signUp("닉네임을 입력해주세요")
        }
        
        alert.addAction(signInAction)
        alert.addAction(signUpAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func signIn() {
        let signInAlert = UIAlertController(title: "로그인", message: "닉네임을 입력해주세요", preferredStyle: .alert)
        signInAlert.addTextField {(textField) in
            textField.placeholder = "닉네임"
            textField.clearsOnBeginEditing = true
        }
        
        let okAction = UIAlertAction(title : "로그인", style: .default){
            (action) in
            let userNameTemp = signInAlert.textFields![0].text!
            for child in self.users {
                if child.key == userNameTemp {
                    currentUserKey = child.key
                    currentUser = child.value
                    if let tempLikeArray = currentUser["likes"] as? [String] {
                        likeArray = tempLikeArray
                    }
                    else{
                        print(currentUser["likes"]!)
                    }
                    //값들 설정 필요
                }
            }
            self.userNames.removeAll()
            let userName: UserName = UserName(userName: "\(signInAlert.textFields![0].text!)")
            self.userNames.append(userName)
            
            // encode
            let encoder: JSONEncoder = JSONEncoder()
            let jsonData: Data
            
            do {
                jsonData = try  encoder.encode(self.userNames)
            } catch {
                print("encode fail")
                return
            }
            let filePath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userNames.json")
            do {
                try jsonData.write(to: filePath)
            } catch{
                print("write to path 실패"+error.localizedDescription)
            }
            //print("저장완료")
            self.helloLabel.text = "\(self.userNames[0].userName)님 안녕하세요!"
            self.tableView.reloadData()
            
        }
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            (action) in self.popUpAlert()
        }
        
        signInAlert.addAction(okAction)
        signInAlert.addAction(cancelAction)
        self.present(signInAlert, animated: true, completion: nil)
    }
    
    func signUp(_ title : String) {
        
        //주원
        let signUPAlert = UIAlertController(title: "회원가입", message: title, preferredStyle: .alert)
        signUPAlert.addTextField {
            (textField) in
            textField.placeholder = "닉네임"
            textField.clearsOnBeginEditing = true
        }
        
        // cancel
        let cancelAction = UIAlertAction(title: "취소", style: .cancel) {
            (action) in self.popUpAlert()
        }
        
        // ok
        let okAction = UIAlertAction(title: "확인", style: .default) {
            (action) in
            self.userNames.removeAll()
            let userName: UserName = UserName(userName: "\(signUPAlert.textFields![0].text!)")
            
            //나연
            //중복체크
            for child in self.users {
                if let temp : String = child.value["name"] as? String {
                    if temp == userName.userName {
                        self.signUp("이미 닉네임이 존재합니다 로그인 하시려면 취소를 누르세요")
                        return
                    }
                }
            }
            
            
            self.userNames.append(userName)
            
            // encode
            let encoder: JSONEncoder = JSONEncoder()
            let jsonData: Data
            
            do {
                jsonData = try  encoder.encode(self.userNames)
            } catch {
                print("encode fail")
                return
            }
            let filePath = try! FileManager.default.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent("userNames.json")
            do {
                try jsonData.write(to: filePath)
            } catch{
                print("write to path 실패"+error.localizedDescription)
            }
            //print("저장완료")
            self.helloLabel.text = "\(self.userNames[0].userName)님 안녕하세요!"
            
            
            //나연 -- 데이터베이스에 정보 올리기 / 초기상태
            let newUser : [String : String] = ["alertTime" : "",
                                               "likes" : "",
                                               "name" : self.userNames[0].userName,
                                               "textFont" : "15",
                                               "textSize" : "굴림"]
            self.database.child(self.databaseName).child(self.userNames[0].userName).setValue(newUser)
            
            currentUser = newUser
            currentUserKey = self.userNames[0].userName
            if let tempLikeArray = currentUser["likes"] as? [String] {
                likeArray = tempLikeArray
            }
            self.tableView.reloadData()
            
        }
        
        // 넣기
        signUPAlert.addAction(okAction)
        signUPAlert.addAction(cancelAction)
        self.present(signUPAlert, animated: true, completion: nil)
    }
}

