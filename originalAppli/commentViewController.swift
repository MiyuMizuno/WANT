//
//  commentViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2021/01/01.
//

import UIKit
import NCMB
import Kingfisher
import KRProgressHUD

class CommentViewController: UIViewController, UITableViewDataSource,UITableViewDelegate, UITextViewDelegate {
    //どの投稿のコメントボタンを押したか　前の画面から取得
    var postId: String!
    var user: User!
    
    var comment = [comments]()
    
    @IBOutlet var commentTableView: UITableView!
    @IBOutlet var commentTextView: UITextView!
    @IBOutlet var shareButton: UIButton!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        
        commentTableView.dataSource = self
        
        commentTextView.delegate = self
        
        commentTableView.tableFooterView = UIView()
        //コメントが長文の時、セルの高さを調節。
        //コード＋オートレイアウト（どんな端末が来ても綺麗にパーツが配置されるように制約をすること）を組む
        commentTableView.estimatedRowHeight = 188
        commentTableView.rowHeight = 188
        
        //枠線
        commentTextView.layer.borderColor = UIColor.gray.cgColor
        commentTextView.layer.borderWidth = 1.0
        
        loadComments()
       // confirmContent()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //tableViewのCellの数をコメントの数にする
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return comment.count
    }
    
    //Cellの内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!
        let userImageView = cell.viewWithTag(1) as! UIImageView
        let userNameLabel = cell.viewWithTag(2) as! UILabel
        let commentLabel = cell.viewWithTag(3) as! UILabel
        // let createDateLabel = cell.viewWithTag(4) as! UILabel
        
        // ユーザー画像を丸く
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        
        let user = comment[indexPath.row].user
        let userImagePath = user.objectId
        let file = NCMBFile.file(withName: userImagePath, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    
                    userImageView.image = image
                }
                else{
                    print("nil")
                }
            }
        }
     //   userImageView.kf.setImage(with: URL(string: userImagePath))
        userNameLabel.text = user.displayName
        commentLabel.text = comment[indexPath.row].text
        
       
        //プロフィール画像の取得
//        let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
//        //プロフィール画像の読み込み
//        file.getDataInBackground { (data, error) in
//            //もしエラーが出たら、表示
//            if error != nil {
//                //エラーをアラート表示
//                let errorAlert = UIAlertController(title: "画像を取得できません", message: error!.localizedDescription, preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
//                })
//                errorAlert.addAction(okAction)
//                self.dismiss(animated: true, completion: nil)
//            }else{
//                //データがある場合
//                if data != nil {
//                    //データをimageに入れる
//                    let image = UIImage(data: data!)
//                    self.profileImageVIew.image = image
//                }
//            }
//        }
        
        
        return cell
    }
    
    //自作関数　テキストが書かれていて写真が選ばれていたらシェアするボタンを押せるようにする
    func confirmContent() {
        if commentTextView.text.count > 0 {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    func textViewDidChange(_ textView: UITextView) {
         confirmContent()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //textViewキーボードを閉じる処理
        textView.resignFirstResponder()
    }
    //コメントを読み込むための関数
    func loadComments() {
        //Commentモデルの読み込み
        comment = [comments]()
        //選択された投稿のコメントをIdで検索して読み込む
        let query = NCMBQuery(className: "Comment")
        query?.whereKey("postId", equalTo: postId)
        //コメントした人のユーザー情報を読み込む
        query?.includeKey("user")
        //findObjectsでデータを拾ってくる
        //InBackground⇨している間に他の処理もできる
        //データがあればresultと言う変数に、なければerrorに入る
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
               
            } else {
                for commentObject in result as! [NCMBObject] {
                    // コメントをしたユーザーの情報を取得してユーザーモデルにセット
                    let user = commentObject.object(forKey: "user") as! NCMBUser
                    let userModel = User(objectId: user.objectId, userName: user.userName)
                    userModel.displayName = user.object(forKey: "displayName") as? String
                    
                    // コメントの文字を取得
                    let text = commentObject.object(forKey: "text") as! String
                    
                    // Commentクラスに格納
                    let comment = comments(postId: self.postId, user: userModel, text: text, createDate: commentObject.createDate)
                    self.comment.append(comment)
                    
                    // テーブルをリロード
                    self.commentTableView.reloadData()
                }
                
            }
        })
    }
    
    //コメントの追加
    @IBAction func addComment() {
        
        //コメントをニフクラに保存
        let object = NCMBObject(className: "Comment")
        object?.setObject(self.postId, forKey: "postId")
        object?.setObject(NCMBUser.current(), forKey: "user")
        object?.setObject(commentTextView.text, forKey: "text")
        //自分だったら
        if user.objectId != NCMBUser.current()?.objectId {
            object?.setObject(false, forKey: "self")
        }else{
            object?.setObject(true, forKey: "self")
        }
        print(object)
        object?.saveInBackground({ (error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            } else {
               
                KRProgressHUD.dismiss()
                //更新
                self.loadComments()
            }
        })
        
        
    }
    
    
    
}


//？ コメントをしたユーザーの情報を取得してユーザーモデルにセット
//let user = commentObject.object(forKey: "user") as! NCMBUser
//let userModel = User(objectId: user.objectId, userName: user.userName)
//userModel.displayName = user.object(forKey: "displayName") as? String
