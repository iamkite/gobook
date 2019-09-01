//
//  Constants.swift
//  Book
//
//  Created by Juwon Lee on 8/26/19.
//  Copyright © 2019 Korea University. All rights reserved.
// 이거 없어도 되나?

import Foundation

struct Font {
    enum Family: String {
        
        case nanumSquare = "NanumSquare"
        case nanumBarunpen = "NanumBarunpen"
        case nanumPenScript = "Nanum Pen Script"
    }
    
    static func fontNamesFor(family: Family) -> [String] {
        switch family {
        case .nanumSquare: return ["NanumSquareR"]
        case .nanumBarunpen: return ["NanumBarunpen"]
        case .nanumPenScript: return ["NanumPen"]
        }
    }
}
//
//struct Fonts {
//    static let NanumBarunpen = "NanumBarunpen"
//    static let NanumSquareR = "NanumSquareR"
//    static let NanumPen = "NanumPen"
//}
