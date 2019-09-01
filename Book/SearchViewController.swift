//
//  SearchViewController.swift
//  Book
//
//  Created by cscoi029 on 2019. 8. 23..
//  Copyright © 2019년 Korea University. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SearchViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var sayingButton : UIButton!
    @IBOutlet var poetryButton : UIButton!
    @IBOutlet var oldPoetryButton : UIButton!
    @IBOutlet var novelButton : UIButton!
    
    @IBOutlet var personalityButton : UIButton!
    @IBOutlet var positiveButton : UIButton!
    @IBOutlet var calmButton : UIButton!
    @IBOutlet var hopeButton : UIButton!
    @IBOutlet var memoryButton : UIButton!
    @IBOutlet var lessonButton : UIButton!
    @IBOutlet var loveButton : UIButton!
    
    @IBOutlet var searchBar : UITextField!
    
    var selectedTypeButton : UIButton?
    var selectedGenreButton : UIButton?
    var searchTypeName : String?
    var searchGenreName : String?
    var searchResult : [String] = []
    var searchTextInput : Bool = false
    var tagSelected : Bool = false
    
    var database : DatabaseReference!
    var writings : [String : [String : Any]]! = [:]
    var databaseHandler : DatabaseHandle!
    var databaseName : String = "writings"
    
    var fontSizeReceiver: String = ""
    var fontReceiver: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.addTarget(self, action: #selector(self.textFieldChanged(_:)), for: UIControlEvents.editingChanged)
        fontReceiver = "굴림"
        fontSizeReceiver = "15"
        NotificationCenter.default.addObserver(self, selector: #selector(fontSizeApplied(_:)), name: .fontSizeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(fontTypeApplied(_:)), name: .fontTypeChanged, object: nil)
        self.hideKeyboard()
        // Do any additional setup after loading the view.
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.hideKeyboard()
        navigationController?.setNavigationBarHidden(true, animated: animated)
        
        database = Database.database().reference()
        database.child(databaseName)
            .observeSingleEvent(of: .value, with: {(snapshot) in
                guard let tempWritings = snapshot.value as? [String : [String : Any]]
                    else{
                        print("데이터 불러오기 실패")
                        return
                }
                self.writings = tempWritings
            })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    
    @IBAction func touchUpTypeButton (_ sender : UIButton) {
        if !searchTextInput{
            checkTypeButton(sender)
        }
        else {
            popUpAlert("검색어가 입력되어있을 때는 태그 선택이 불가능 합니다.")
        }
    }
    
    @IBAction func touchUpGenreButton (_ sender : UIButton) {
        if !searchTextInput {
            checkGenreButton(sender)
        }
        else {
            popUpAlert("검색어가 입력되어있을 때는 태그 선택이 불가능 합니다.")
        }
    }
    
    
    func checkTypeButton (_ button : UIButton) {
        guard let nowSelectedButton : UIButton = selectedTypeButton else {
            //선택
            selectedTypeButton = button
            button.isSelected = true
            tagSelected = true
            searchTypeName = button.titleLabel?.text
            searchBarInput()
            return
        }
        
        if nowSelectedButton == button {
            //버튼 선택 취소
            selectedTypeButton = nil
            button.isSelected = false
            if selectedGenreButton == nil {
                tagSelected = false
            }
            searchTypeName = nil
            searchBarInput()
        }
        else {
            //원래것 취소하고 버튼 새로 선택
            nowSelectedButton.isSelected = false
            button.isSelected = true
            tagSelected = true
            selectedTypeButton = button
            searchTypeName = button.titleLabel?.text
            searchBarInput()
        }
    }
    
    func checkGenreButton (_ button : UIButton) {
        guard let nowSelectedButton : UIButton = selectedGenreButton else {
            //선택
            selectedGenreButton = button
            button.isSelected = true
            tagSelected = true
            searchGenreName = button.titleLabel?.text
            searchBarInput()
            return
        }
        
        if nowSelectedButton == button {
            //버튼 선택 취소
            selectedGenreButton = nil
            button.isSelected = false
            if selectedTypeButton == nil {
                tagSelected = false
            }
            searchGenreName = nil
            searchBarInput()
        }
        else {
            //원래것 취소하고 버튼 새로 선택
            nowSelectedButton.isSelected = false
            button.isSelected = true
            tagSelected = true
            selectedGenreButton = button
            searchGenreName = button.titleLabel?.text
            searchBarInput()
        }
    }
    
    //tag input
    func searchBarInput () {
        if let genreName : String = searchGenreName, let typeName : String = searchTypeName {
            searchBar.text = typeName + " " + genreName
        }
        else if let genreName : String = searchGenreName{
            searchBar.text = genreName
        }
        else if let typeName : String = searchTypeName {
            searchBar.text = typeName
        }
        else {
            searchBar.text = nil
        }
    }
    
    func popUpAlert(_ alert : String) {
        // alert 띄우기
        let alert = UIAlertController(title: alert, message: "", preferredStyle: .alert)
        
        // ok
        let okAction = UIAlertAction(title: "확인", style: .default) {
            (action) in
        }
        
        // 넣기
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func cannotSearchNow(_ sender : UITapGestureRecognizer) {
        if tagSelected {
            popUpAlert("태그가 입력되어있을 때는 검색어 입력이 불가능 합니다.")
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if tagSelected {
            return false
        }
        else {
            return true
        }
    }
    
    @objc func textFieldChanged(_ sender : UITextField){
        guard let tempText : String = searchBar.text else {
            return
        }
        
        if tempText.count > 0 {
            searchTextInput = true
        }
        else {
            searchTextInput = false
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let nextViewController = segue.destination as? SearchResultViewController else {
            print("목적지가 SearchResultViewController가 아닙니다")
            return
        }
        
        if !searchTextInput, !tagSelected {
            popUpAlert("입력어가 없습니다.")
            return
        }
        
        let writingsArray = Array(self.writings)
        
        if tagSelected {
            if var tempTypeName : String = self.searchTypeName, var tempGenreName : String = self.searchGenreName {
                
                tempTypeName = String(tempTypeName[tempTypeName.index(after: tempTypeName.startIndex)..<tempTypeName.endIndex])
                tempGenreName = String(tempGenreName[tempGenreName.index(after: tempGenreName.startIndex)..<tempGenreName.endIndex])
                for child in writingsArray {
                    if child.value["type"] as! String == tempTypeName, child.value["genre"] as! String == tempGenreName {
                        self.searchResult.append(child.key)
                    }
                }
            }
            else if var tempGenreName : String = self.searchGenreName {
                tempGenreName = String(tempGenreName[tempGenreName.index(after: tempGenreName.startIndex)..<tempGenreName.endIndex])
                for child in writingsArray {
                    if child.value["genre"] as! String == tempGenreName {
                        self.searchResult.append(child.key)
                    }
                }
            }
            else if var tempTypeName : String = self.searchTypeName {
                tempTypeName = String(tempTypeName[tempTypeName.index(after: tempTypeName.startIndex)..<tempTypeName.endIndex])
                for child in writingsArray {
                    if child.value["type"] as! String == tempTypeName {
                        self.searchResult.append(child.key)
                    }
                }
            }
        }
        else if searchTextInput {
            guard let searchText : String = searchBar.text else {
                return
            }
            
            for child in writingsArray {
                if (child.value["contents"] as! String).contains(searchText), !self.searchResult.contains(child.key) {
                    self.searchResult.append(child.key)
                }
                if (child.value["title"] as! String).contains(searchText), !self.searchResult.contains(child.key) {
                    self.searchResult.append(child.key)
                }
                if (child.value["author"] as! String).contains(searchText), !self.searchResult.contains(child.key) {
                    self.searchResult.append(child.key)
                }
            }
        }
        
        if self.searchResult.count > 0 {
            nextViewController.dataContents = self.searchResult
            nextViewController.writings = self.writings
            nextViewController.fontReceiver = self.fontReceiver
            nextViewController.fontSizeReceiver = self.fontSizeReceiver
        }
        else {
            //검색결과 없음
            popUpAlert("검색결과가 없습니다.")
            return
        }
        
        self.searchBar.text = nil
        self.searchGenreName = nil
        self.searchTypeName = nil
        self.selectedTypeButton?.isSelected = false
        self.selectedGenreButton?.isSelected = false
        self.searchResult = []
        self.tagSelected = false
        self.searchTextInput = false
        
    }
    
    @objc func fontSizeApplied(_ notification: Notification) {
        guard  let fontSizeText : String = notification.userInfo!["fontSizeKey"] as? String else {
            return
        }
        
        print("received")
        self.fontSizeReceiver = fontSizeText
    }
    
    
    @objc func fontTypeApplied(_ notification: Notification) {
        guard  let fontTypeText : String = notification.userInfo!["fontType"] as? String else {
            return
        }
        
        self.fontReceiver = fontTypeText
    }
    
}
