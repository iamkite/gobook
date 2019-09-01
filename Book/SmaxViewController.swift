
//  SminTwoViewController.swift
//  Book
//
//  Created by cscoi030 on 2019. 8. 23..
//  Copyright © 2019년 Korea University. All rights reserved.
//

import UIKit
import FirebaseDatabase

class SmaxViewController: UIViewController {
    @IBOutlet weak var tabTextView: UITextView!
    var database: DatabaseReference!
    var writings: [String:[String:Any]]! = [:]
    var databaseHandler: DatabaseHandle!
    let databaseName: String = "writings"
    
    var dataTitle: [String]=[]
    var showedData: [Int] = []
    
    func chooseNext ()->(String){
        let fileSize:Int = dataTitle.count
        var choosed: Bool = false
        var returnValue: Int = Int(arc4random_uniform(UInt32(fileSize)))
        var checkIndex: Int = -1
        var countInChoosed:Int = 5
        var countInChoosedInit: Int = 5
        if fileSize <= 7{
            if fileSize>=5 {
                countInChoosedInit = 3
            } else if fileSize>=3 {
                countInChoosedInit = 1
            } else {
                countInChoosedInit = 0
            }
        }
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
        return dataTitle[returnValue]
    }
    
    func configureDatabase() {
        database = Database.database().reference()
        databaseHandler = database.child(databaseName).observe(.value, with: {(snapshot) -> Void in
            guard let book = snapshot.value as? [String:[String:Any]] else {
                return
            }
            self.writings = book
            print("새 책이 추가 되었으며 총 개수는 \(self.writings.count)")
            self.setDataTitle()
        })
        print("return ")
    }
    func setDataTitle() {
        //var asdf = books!
        //        for i in asdf{
        //            print(asdf[(key:i,value[title:])])
        //        }
        ////        for i in books{
        //            print(books(key:i).title)
        //        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        self.configureDatabase()
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

