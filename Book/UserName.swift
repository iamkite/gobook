
//
//  UserName.swift
//  Book
//
//  Created by Juwon Lee on 8/24/19.
//  Copyright © 2019 Korea University. All rights reserved.
//

import UIKit

class UserName: NSObject, Codable {
    var userName: String = "처음 뵙겠습니다"
    
    init(userName: String) {
        self.userName = userName
    }
}
