//
//  postUser.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/27.
//設計図

import UIKit

class User: NSObject {
    
    var objectId: String
        var userName: String
        var displayName: String?
        var introduction: String?

        init(objectId: String, userName: String) {
            //この画面に値を代入する初期関数
            self.objectId = objectId
            self.userName = userName
        }

    
    
}
