//
//  ViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/11/27.
//セルのID ”Cell”

import UIKit
import NCMB
import Kingfisher
import SwiftDate
import KRProgressHUD

//プロトコル宣言
class ViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, postTableViewCellDelegate {
    
    //postModelの型に入っている情報＝selectedPost
    var selectedPost: postModel?
    //タイムラインの読み込み
    //○投稿内容postsの配列を作る
    var posts = [postModel]()
    
    //ブロックした投稿の配列
    var blockingUserIDs = [String]()
    
    //通報した投稿を入れる配列
    var reportIdArray = [String]()
    //storyBoadにおいたtableViewを宣言
    @IBOutlet var postTableView: UITableView!
    
    //最初の一回だけ呼ばれるviewDidLoad
    override func viewDidLoad() {
        super.viewDidLoad()

        //○変数postにNCMBから読み込んだものを追加
        //アプリを開いたときにアカウントが取得できるか確認
       if NCMBUser.current() == nil {
            //NCMBUser.current()が取得できなかったとき
            //ストーリーボードの取得
            let storyboard = UIStoryboard(name: "signIn", bundle: Bundle.main)
            //ID"RootNavigationController"の画面を作成
            let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            
            //ログアウトしたという情報をユーザーデフォルトに上書きする
            let ud = UserDefaults.standard
            ud.set(false, forKey: "isLogin")
            ud.synchronize()
        }
        
        
        
        //プロトコル宣言の相手
        postTableView.dataSource = self
        postTableView.delegate = self
        
        //カスタムセルの取得
        let nib = UINib(nibName: "postTableViewCell", bundle: Bundle.main)
        postTableView.register(nib, forCellReuseIdentifier: "postCell")
        
        //呼び出し
        setRefreshControl()
        
        //余分な線を消す
        postTableView.tableFooterView = UIView()
        //セルの高さ
        postTableView.rowHeight = 440
        
        // 引っ張って更新
        setRefreshControl()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        getBlockingUser()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //どの投稿を選択したかの情報をCommentViewController.swiftに送る
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toComments" {
            //viewControllerにcommentViewControllerの存在を宣言（destination=目的）
            let commentViewController = segue.destination as! CommentViewController
            //送る内容(objectId)
            commentViewController.postId = selectedPost?.objectId
            commentViewController.user = selectedPost?.user
        }
    }
    
    
    //○生成するセルの数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return posts.count
    }
    
    
    //○セルに入れる内容
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        //登録したnibに入っているカスタムセルを取得
        let cell = tableView.dequeueReusableCell(withIdentifier: "postCell") as! postTableViewCell
        cell.delegate = self
        cell.tag = indexPath.row
        
        //投稿者のユーザー情報を取り出す
        let user = posts[indexPath.row].user
        //userNameLabelにdisplayNameを出す
        cell.UsernameLabel.text = user.displayName
        //ユーザー画像を取得して表示する
        let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    
                    cell.profileImageView.image = image
                }
                else{
                    print("nil")
                }
            }
        }
        //    cell.userImageView.kf.setImage(with: URL(string: userImageUrl), placeholder: UIImage(named: "placeholder.jpg"), options: nil, progressBlock: nil, completionHandler: nil)
        //コメントを取得して表示する
       // cell.addCommentTextView.text = posts[indexPath.row].text
        
        //投稿画像を取得して表示
        if let imageUrl = posts[indexPath.row].imageUrl {
            cell.postImageView.kf.setImage(with: URL(string: imageUrl))
                    print(imageUrl)
        }else{
            cell.postImageView.image = nil
        }
        
        
        //投稿文の表示
        cell.postTextView.text = posts[indexPath.row].text
        // Likeの数
        //cell.likeCountLabel.text = "\(posts[indexPath.row].likeCount)件"
        
        // タイムスタンプ(投稿日時) (※フォーマットのためにSwiftDateライブラリをimport)
        cell.timeLabel.text = posts[indexPath.row].createDate.toString()
        //cell.timestampLabel.text = posts[indexPath.row].createDate.string()
        
        return cell
    }
    
    
    // 選択状態の解除
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // 選択状態の解除
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
//【メニューボタン】
    //・・・（メニュー）ボタンを押したときに呼ばれる関数　どのセルが押されたか、どのボタンが押されたかを引数として引っ張ってくる
    //投稿の削除・通報
    func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton) {
        //アクションシートのアラートを作る
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //投稿の削除ボタン
        let deleteAction = UIAlertAction(title: "削除する", style: .destructive) { (action) in
            KRProgressHUD.show()
            //投稿のデータを取得
            let query = NCMBQuery(className: "Post")
            query?.getObjectInBackground(withId: self.posts[tableViewCell.tag].objectId, block: { (post, error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    // 取得した投稿オブジェクトを削除
                    post?.deleteInBackground({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            // 再読込
                            self.loadTimeline()
                            KRProgressHUD.dismiss()
                        }
                    })
                }
            })
        }
        //通報ボタン
        let reportAction = UIAlertAction(title: "報告する", style: .destructive) { (action) in
            let object = NCMBObject(className: "Report")
            object?.setObject(self.posts[tableViewCell.tag].objectId, forKey: "reportID")
            object?.setObject(NCMBUser.current(), forKey: "reportUser")
            object?.saveInBackground({ (error) in
                                    if error != nil {
                                        KRProgressHUD.showError(withMessage: "エラーです")
                                    } else {
                                        //tableView.deselectRow(at: indexPath, animated: true)
                                    }
                                })
            KRProgressHUD.showSuccess(withMessage: "報告を受け付けました。ありがとうございます")
            
        }
        //ブロック
        let blockAction = UIAlertAction(title: "このユーザーをブロックする", style: .default) { (action) in
            let object = NCMBObject(className: "Block")
            object?.setObject(self.posts[tableViewCell.tag].user.objectId, forKey: "blockedUser")
            object?.setObject(NCMBUser.current(), forKey: "blockingUser")
            object?.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: "エラーが発生しました")
                }else{
                    KRProgressHUD.showSuccess(withMessage: "ブロックを受け付けました。")
                }
            })
        }
        
        //キャンセルボタン
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            alertController.dismiss(animated: true, completion: nil)
        }
        
        //自分の投稿には削除ボタン、他人の投稿には報告ボタンを出す
        //選択肢ているcellのアカウント＝ログインしているアカウントの時　（＝自分）
        if posts[tableViewCell.tag].user.objectId == NCMBUser.current().objectId {
            // 自分の投稿なので、削除ボタンを出す
            alertController.addAction(deleteAction)
        } else {
            // 他人の投稿なので、報告ボタンを出す
            alertController.addAction(reportAction)
            alertController.addAction(blockAction)
        }
        
        //ボタンの追加と表示
        alertController.addAction(cancelAction)
        self.present(alertController, animated: true, completion: nil)
    }
    
    //blockしてる人の情報を自分のとこに読み込む
    func getBlockingUser() {
        let query = NCMBQuery(className: "Block")
        query?.includeKey("blockingUser")
        query?.whereKey("blockingUser", equalTo: NCMBUser.current())
        query?.findObjectsInBackground({ (results, error) in
            if error != nil {
                KRProgressHUD.showError(withMessage: "エラーが発生しました")
            }else{
                self.blockingUserIDs.removeAll()
                for blockInfo in results as! [NCMBObject]{
                    let blockedUserID = blockInfo.object(forKey: "blockedUser") as! String
                    //let blockedUserID = blockedUser.objectId
                    self.blockingUserIDs.append(blockedUserID)
                }
                self.getreportId()
            }
        })
    }

    func getreportId() {

            let query = NCMBQuery(className: "Report")

            //includeKeyでBlockの子クラスである会員情報を持ってきている
            query?.includeKey("reportUser")
            query?.whereKey("reportUser", equalTo: NCMBUser.current())
            query?.findObjectsInBackground({ (result, error) in
                if error != nil {
                    //エラーの処理
                } else {
                    //ブロックされたユーザーのIDが含まれる + removeall()は初期化していて、データの重複を防いでいる
                    self.reportIdArray.removeAll()
                    for reportObject in result as! [NCMBObject] {
                        //この部分で①の配列にブロックユーザー情報が格納
    self.reportIdArray.append(reportObject.object(forKey: "reportID") as! String)

                    }

                }
            })
            loadTimeline()
        }

    //コメントした人のユーザー情報を読み込む
    //query?.includeKey("user")
    
    
//【コメントボタン】
    func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton) {
        // 選ばれた投稿を一時的に格納（自分がタップした投稿を覚えておくコード）
        selectedPost = posts[tableViewCell.tag]
        
        // 遷移させる(このとき、prepareForSegue関数で値を渡す)コメント一覧に移動
        self.performSegue(withIdentifier: "toComments", sender: nil)
    }
    
    //【ロード】タイムライン(投稿)の読み込み
    func loadTimeline() {
        //PostクラスのNCMBからデータをもらってくる（NCMBQuery）
        let query = NCMBQuery(className: "Post")
        
        //Userの情報を取ってくる
        query?.includeKey("user")
        //順番を決める（降順）createDate⇨投稿された順
        query?.order(byDescending: "createDate")
        
        //findObjectsでデータを拾ってくる
        //InBackground⇨している間に他の処理もできる
        //データがあればresultと言う変数に、なければerrorに入る
        query?.findObjectsInBackground({ (result, error) in
            if error != nil {
                //エラーをその国の言葉(localizeDescription)で表示
                KRProgressHUD.showError(withMessage: error!.localizedDescription)
            }else{
                //【result（データ）をpods配列の中に代入】
                //appendすると同じ内容が重複して表示され得てしまうため、読み込んだときに初期化してあげる
                self.posts = [postModel]()
                
                //【for~in~文⇨一つ一つで回す】つまりNCMBObjectを一個一個取り出している。
                //取得したresult[Any]を[NCMBObject]にダウンキャストしてpostObjectに１つずつ入れ、下の処理を行う
                //resultはAny?型なのでNCMBObject配列にダウンキャスト
                for postObject in result as! [NCMBObject] {
                    
                    //【ここからUserの情報を取ってきて、     Userモデル(User.swift)に格納してあげ、さらにpostモデルに格納し、appendでposts配列に格納】
                    
                    //ユーザー情報をUserクラスにセット
                    let user = postObject.object(forKey: "user") as! NCMBUser
                    
                    //退会済みのaを表示
                    if user.object(forKey: "active") as? Bool != false {
                        //投稿したユーザー情報を”Userモデル”にまとめる
                        let userModel = User(objectId: user.objectId, userName: user.userName)
                        userModel.displayName = user.object(forKey: "displayName") as? String
                        // 投稿の情報を取得
                        let imageUrl = postObject.object(forKey: "imageUrl") as? String
                        let text = postObject.object(forKey: "text") as! String
                        
                        // 2つのデータ(投稿情報と誰が投稿したか?)を合わせてPostクラスにセット
                        let post = postModel(objectId: postObject.objectId, user: userModel, imageUrl: imageUrl, text: text, createDate: postObject.createDate)
                        
                        // 配列に加える
                        //ブロックした投稿のIDを保存から　それ以外を表示
                        
                        if self.blockingUserIDs.firstIndex(of: post.user.objectId) == nil && self.reportIdArray.firstIndex(of: post.objectId) == nil{
                        //配列にくわえる
                        self.posts.append(post)
                        }
                    }
                }
                // 投稿のデータが揃ったらTableViewをリロード
                self.postTableView.reloadData()
            }
        })
        
    }
   
    
    //引っ張ってタイムライン更新
    func setRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(reloadTimeline(refreshControl:)), for: .valueChanged)
        postTableView.addSubview(refreshControl)
    }
    
    
    
   
    
    
    @objc func reloadTimeline(refreshControl: UIRefreshControl) {
        refreshControl.beginRefreshing()
        self.getBlockingUser()
        // 更新が早すぎるので2秒遅延させる
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            refreshControl.endRefreshing()
        }
    }
    
    
    
    
    
    //func loadFollowingUsers() {
    
    
    
    //
    //
    //
    //posts[indexPath.row].imageUrlのindexPath.rowとは
    
    //?
//    let query = NCMBQuery(className: "Block")
//    query?.includeKey("blockingUser")
//    query?.whereKey("blockingUser", equalTo: NCMBUser.current())
//    query?.findObjectsInBackground({ (results, error) in
//    self.blockingUserIDs.removeAll()
//    for blockInfo in results as! [NCMBObject]{
//        let blockedUser = blockInfo.object(forKey: "blockedUser") as! NCMBUser
//        let blockedUserID = blockedUser.objectId
//        self.blockingUserIDs.append((blockedUserID)!)
    
    
}

//90
