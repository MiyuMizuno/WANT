//
//  composeViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/04.
//

import UIKit
import UITextView_Placeholder
import NYXImagesKit
import NCMB
import KRProgressHUD

//プロトコル宣言(ナビゲーション・picker・textView)
class composeViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate {
    
    //ユーザーが追加する写真に名前をつける
    let placeholderImage = UIImage(named: "photo-placeholder")
    var resizedImage: UIImage!
    
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var shareButton: UIBarButtonItem!
    @IBOutlet var userImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //ImageViewに画像を入れる
        let file = NCMBFile.file(withName: NCMBUser.current().objectId, data: nil) as! NCMBFile
        file.getDataInBackground { (data, error) in
            if error != nil {
                print(error?.localizedDescription)
            } else {
                if data != nil {
                    let image = UIImage(data: data!)
                    
                    self.userImageView.image = image
                }
                else{
                    print("nil")
                }
            }
        }
        
        //【角を丸くする】
        userImageView.layer.cornerRadius = userImageView.bounds.width / 2.0
        userImageView.layer.masksToBounds = true
        //条件を満たすとボタンが押せる＝isEnabled
        //ボタンが押せなくなる
        //cameraButton.isEnabled = false
        //alubumButton.isEnabled = false
        //【プレイスフォルダ】
        postTextView.placeholder = "ここに質問を入力しよう！！！！（例：どこに売ってありますか？）（例2：検索ワードを教えてください！）200字以内"
        postTextView.delegate = self
        
        confirmContent()
        
    }
    //
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
        resizedImage = selectedImage.scale(byFactor: 0.3)
        postImageView.image = resizedImage
        picker.dismiss(animated: true, completion: nil)
        //
        confirmContent()
    }
    
    func textViewDidChange(_ textView: UITextView) {
         confirmContent()
    }
    
    func textViewShouldEndEditing(_ textView: UITextView) -> Bool {
        //textViewキーボードを閉じる処理
        textView.resignFirstResponder()
    }
    //【カメラ起動】
    @IBAction func cameraButton() {
        if UIImagePickerController.isSourceTypeAvailable(.camera){
            let picker = UIImagePickerController()
            picker.sourceType = .camera
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }else{
            print("この機種では使用できません")
        }
    }
    //【アルバム起動】
    @IBAction func alubumButton() {
        if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
            let picker = UIImagePickerController()
            picker.sourceType = .photoLibrary
            picker.delegate = self
            self.present(picker, animated: true, completion: nil)
        }else{
            print("この機種では使用できません")
        }
    }
    //【質問を投稿する】
    @IBAction func postButton() {
        KRProgressHUD.show()
        if resizedImage != nil {
            //撮影した画像をデータ化したときに右に90度回転してしまう問題の解消
            UIGraphicsBeginImageContext(resizedImage.size)
            let rect = CGRect(x: 0, y: 0, width: resizedImage.size.width, height: resizedImage.size.height)
            resizedImage.draw(in: rect)
            resizedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            //画像のアップロード
            let data = resizedImage!.pngData()
            // ここを変更（ファイル名無いので）
            let file = NCMBFile.file(with: data) as! NCMBFile
            file.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.dismiss()
                    
                    let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        
                    })
                    alert.addAction(okAction)
                    self.present(alert, animated: true, completion: nil)
                } else {
                    // 画像アップロードが成功
                    let postObject = NCMBObject(className: "Post")
                    //テキストが入力されてない時
                    if self.postTextView.text.count == 0 {
                        print("入力されていません")
                        return
                    }
                    //テキストとユーザーをデータストアに保存するためにセット　（多分）
                    postObject?.setObject(self.postTextView.text!, forKey: "text")
                    postObject?.setObject(NCMBUser.current(), forKey: "user")
                    //画像ファイルの保存先のURLの保存するためにセット
                    let url = "https://mbaas.api.nifcloud.com/2013-09-01/applications/XegfJYKBNc5p8c6W/publicFiles/" + file.name
                    postObject?.setObject(url, forKey: "imageUrl")
                    
                    //ここまでの全部保存
                    postObject?.saveInBackground({ (error) in
                        if error != nil {
                            KRProgressHUD.showError(withMessage: error!.localizedDescription)
                        } else {
                            KRProgressHUD.dismiss()
                            self.postImageView.image = nil
                            self.postImageView.image = UIImage(named: "photo-placeholder")
                            self.postTextView.text = nil
                            self.tabBarController?.selectedIndex = 0
                        }
                    })
                }
                
                
                
            }) { (progress) in
                //保存の進捗のプリント
                print(progress)
            }
           
        }else{
            // 画像アップロードが成功
            let postObject = NCMBObject(className: "Post")
            //テキストが入力されてない時
            if self.postTextView.text.count == 0 {
                print("入力されていません")
                return
            }
            //テキストとユーザーをデータストアに保存するためにセット　（多分）
            postObject?.setObject(self.postTextView.text!, forKey: "text")
            postObject?.setObject(NCMBUser.current(), forKey: "user")
            
            //ここまでの全部保存
            postObject?.saveInBackground({ (error) in
                if error != nil {
                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                } else {
                    KRProgressHUD.dismiss()
                    self.postImageView.image = nil
                    self.postImageView.image = UIImage(named: "photo-placeholder")
                    self.postTextView.text = nil
                    self.tabBarController?.selectedIndex = 0
                }
            })
        }
        
        
    }
    
    //textViewに文字数制限
    func textViewDidChangeSelection(_ textView: UITextView) {
        let beforeStr: String = postTextView.text
        if postTextView.text.count > 200 {
            let zero = beforeStr.startIndex
            let start = beforeStr.index(zero, offsetBy: 0)
            let end = beforeStr.index(zero, offsetBy: 200)
            postTextView.text = String(beforeStr[start...end])
        }
    }
    
    //内容を確認
    //自作関数　テキストが書かれていて写真が選ばれていたらシェアするボタンを押せるようにする
    func confirmContent() {
        if postTextView.text.count > 0 {
            shareButton.isEnabled = true
        } else {
            shareButton.isEnabled = false
        }
    }
    
    @IBAction func cancel() {
        if postTextView.isFirstResponder == true {
            postTextView.resignFirstResponder()
        }
        
        let alert = UIAlertController(title: "投稿内容の破棄", message: "入力中の投稿内容を破棄しますか？", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.postTextView.text = nil
            self.postImageView.image = UIImage(named: "photo-placeholder")
            self.confirmContent()
        })
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        })
        alert.addAction(okAction)
        alert.addAction(cancelAction)
        self.present(alert, animated: true, completion: nil)
    }
    
}
//41行目　 let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
//138行目　shareButton.isEnabled = true　条件を満たした時押せるボタン
//91~93行目　わからない

