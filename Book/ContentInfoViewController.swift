//
//  ContentInfoViewController.swift
//  Book
//
//  Created by OneAndZero on 8/25/19.
//  Copyright © 2019 Korea University. All rights reserved.
//

import UIKit

class ContentInfoViewController: UIViewController {
    
    var nowText: [String:Any]! = [:]
    
    @IBOutlet var authorPicture: UIImageView!
    @IBOutlet var authorName: UILabel!
    @IBOutlet var authorProfile: UITextView!
    @IBOutlet var contentsName: UILabel!
    @IBOutlet var contentsDetail: UITextView!
    @IBOutlet var relatedTag: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setDataContents()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    func setDataContents() {
        
        
        if let tempAuthorPicture : String = nowText["picture"] as? String {
            authorPicture.image = UIImage(named: tempAuthorPicture)
        }
        if let tempAuthorName : String = nowText["author"] as? String {
            authorName.text = tempAuthorName
        }
        if let tempAuthorProfile : String = nowText["profile"] as? String {
            authorProfile.text = tempAuthorProfile
        }
        if let tempTitle : String = nowText["title"] as? String {
            contentsName.text = tempTitle
        }
        if let tempContentsDetail : String = nowText["detail"] as? String {
            contentsDetail.text = tempContentsDetail
        }
        if let tempType : String = nowText["type"] as? String {
            relatedTag.text = "#" + tempType
        }
        if let tempGenre : String = nowText["genre"] as? String {
            relatedTag.text = relatedTag.text + "     " + "#" + tempGenre
        }
    }
    
}



