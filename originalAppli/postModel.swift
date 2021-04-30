//
//  postModel.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/27.
//

import UIKit

class postModel: NSObject {
    
    //！？がないものは必ず値が入る→/初期化initと同時に引数に値を入れる
    //!?には初期化時に値を入れないように init(objectId: String, user: String, imageUrl: String, text: String, createDate: Date)に入れない
    
    var objectId: String
    var user: User
    var imageUrl: String?
    var text: String
    var createDate: Date
    //var isLiked: Bool?
//エラーCannot find type 'Comment' in scope　⇨ コメントクラスを作る
//[]の中はcomments.Swift 
    var comments: [comments]?
    //var likeCount: Int = 0
    
//初期化initと同時に引数に値を入れる事ができる(初期化時に値が入る)
//この画面(タイムライン)のオブジェクトに値を渡してあげる初期化関数
    init(objectId: String, user: User, imageUrl: String?, text: String, createDate: Date) {
            self.objectId = objectId
            self.user = user
            self.imageUrl = imageUrl
            self.text = text
            self.createDate = createDate
        }
}
