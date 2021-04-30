//
//  comments.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/29.
//

import UIKit

class comments: NSObject {

 //: User
    //コメントをモデル化する
    var postId: String
    var user: User
       var text: String
       var createDate: Date

       init(postId: String, user: User, text: String, createDate: Date) {
           self.postId = postId
           self.user = user
           self.text = text
           self.createDate = createDate
       }
    
}
