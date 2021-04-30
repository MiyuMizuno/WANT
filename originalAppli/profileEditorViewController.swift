//
//  profileEditorViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/04.
//rootViewControllerのIDがRootNavigationController

import UIKit
import NCMB
import NYXImagesKit

//カメラを使うためにプロトコル宣言(UIImagePickerControllerDelegate,UINavigationControllerDelegate)
class profileEditorViewController: UIViewController ,UIImagePickerControllerDelegate,UINavigationControllerDelegate,UITextViewDelegate{
    
    @IBOutlet var profileImageVIew: UIImageView!
    @IBOutlet var imageEditorButtom: UIButton!
    @IBOutlet var nameTextField: UITextField!
    @IBOutlet var userNameTextField: UITextField!
    @IBOutlet var brandTextView: UITextView!
    @IBOutlet var introductionTextView: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //【プレイスフォルダ】
        let introductiontextView = UITextView()
        introductiontextView.placeholder = "こんにちは！"
        introductiontextView.placeholderColor = UIColor.lightGray
        //introductiontextView.attributedPlaceholder = NSAttributedString //(optional)
        
        //【プロフィール編集画面でも設定中のプロフィール画像を表示】
        //画像を円形に
        profileImageVIew.layer.cornerRadius = profileImageVIew.bounds.width / 2.0
        profileImageVIew.layer.masksToBounds = true
        
        //textView
        introductionTextView.delegate = self
        brandTextView.delegate = self
        
        //枠線
        introductionTextView.layer.borderColor = UIColor.gray.cgColor
        introductionTextView.layer.borderWidth = 1.0
        
        //【NCMを使う処理】
        //【編集時にも設定中の情報を表示】
        //【７日間ログインしていないユーザーに対しての例外処理】ifを使う
        //もしユーザーが見つかった場合は表示
        if let user = NCMBUser.current(){
            nameTextField.text = user.object(forKey: "displayName") as? String
            userNameTextField.text = user.object(forKey: "userName") as? String
            brandTextView.text = user.object(forKey: "brandTextView") as? String
            introductionTextView.text = user.object(forKey: "introduction") as? String
            
            //プロフィール画像の取得
            let file = NCMBFile.file(withName: user.objectId, data: nil) as! NCMBFile
            //プロフィール画像の読み込み
            file.getDataInBackground { (data, error) in
                //もしエラーが出たら、表示
                if error != nil {
                    //エラーをアラート表示
                    let errorAlert = UIAlertController(title: "画像を取得できません", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                    })
                    errorAlert.addAction(okAction)
                    self.dismiss(animated: true, completion: nil)
                }else{
                    //データがある場合
                    if data != nil {
                        //データをimageに入れる
                        let image = UIImage(data: data!)
                        self.profileImageVIew.image = image
                    }
                }
            }
        }else{
            //ユーザーが見つからなかった場合はログイン画面へ移動
            let storyboad = UIStoryboard(name: "signIn", bundle: Bundle.main)
            let rootViewController = storyboad.instantiateViewController(identifier: "RootNavigationController")
            UIApplication.shared.keyWindow?.rootViewController = rootViewController
            //保持
            let ud = UserDefaults.standard
            ud.set(true, forKey: "isLogin")
            ud.synchronize()
        }
    }
    
    //textViewに文字数制限
    func textViewDidChange(_ textView: UITextView) {
        let beforeStr: String = introductionTextView.text
        if introductionTextView.text.count > 50 {
            let zero = beforeStr.startIndex
            let start = beforeStr.index(zero, offsetBy: 0)
            let end = beforeStr.index(zero, offsetBy: 50)
            introductionTextView.text = String(beforeStr[start...end])
        }
        func textViewDidChange(_ textView: UITextView) {
            let beforeStr: String = brandTextView.text
            if brandTextView.text.count > 50 {
                let zero = beforeStr.startIndex
                let start = beforeStr.index(zero, offsetBy: 0)
                let end = beforeStr.index(zero, offsetBy: 50)
                brandTextView.text = String(beforeStr[start...end])
            }
    }
    }
    
    //【ログアウトのためのアクションシート】


    @IBAction func logoutButton(){
        let logoutAlertcontroller = UIAlertController(title: "メニュー", message: "メニューを選択して下さい", preferredStyle: .actionSheet)
        let logoutAction = UIAlertAction(title: "ログアウト", style: .default) { (action) in
            NCMBUser.logOutInBackground(
                { (error) in
                    //もしエラーが出たら…
                    if error != nil{
                        //エラーをアラート表示
                        // let errorAlert = UIAlertController(title: "ログアウトできません", message: error!.localizedDescription, preferredStyle: .alert)
                        // let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in <#code#>
                        // })
                        // errorAlert.addAction(okAction)
                        // self.dismiss(animated: true, completion: nil)
                        
                        //エラーが出なかったら…
                    }else{
                        //ログアウト成功⇨ログイン画面(RootNavigationController)へ移動
                        let storyboad = UIStoryboard(name: "signIn", bundle: Bundle.main)
                        let rootViewController = storyboad.instantiateViewController(withIdentifier: "RootNavigationController")
                        UIApplication.shared.keyWindow?.rootViewController = rootViewController
                        //ログイン状態の保持（退会ではないから）
                        let ud = UserDefaults.standard
                        ud.set(true, forKey: "isLogin")
                        ud.synchronize()
                    }
                } )
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            //キャンセルした時、アラートの画面を消す
            logoutAlertcontroller.dismiss(animated: true, completion: nil)
        }
        //アラートを表示
        logoutAlertcontroller.addAction(logoutAction)
        logoutAlertcontroller.addAction(cancelAction)
        self.present(logoutAlertcontroller, animated: true, completion: nil)
    }
    //退会
    @IBAction func deleatButton(){
        let storyboad = UIStoryboard(name: "Main", bundle: Bundle.main)
        let deleatViewController = storyboad.instantiateViewController(withIdentifier: "deleat")
        //UIApplication.shared.keyWindow?.deleatViewController = deleatViewController
        
    }
    
    //【プロフィール画像の表示】
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        //取り出す
        let selectedImage = info[.originalImage] as! UIImage
        //表示する（に移動）
        
        //アップロードできる画像のサイズに制限があるから、ファイルをリサイズする
        //リサイズのためのライブラリNYXImagesKitを入れる(元のサイズの×0.3)
        let risaizeImage = selectedImage.scale(byFactor: 0.3)
        
        //pickerを閉じる
        picker.dismiss(animated: true, completion: nil)
        
        //画像のアップロード
        let data = risaizeImage!.pngData()
        //画像ファイル名をユーザーと結びつける(wituName:ユーザーのオブジェクトID,data)
        let file = NCMBFile.file(withName: NCMBUser.current()?.objectId, data: data) as! NCMBFile
        file.saveInBackground { (error) in
            //保存に失敗した場合、アラート
            if error != nil {
                //エラーをアラート表示
                let alert = UIAlertController(title: "画像アップロードエラー", message: error!.localizedDescription, preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default,handler: { (action) in
                })
                alert.addAction(okAction)
                self.present(alert, animated: true, completion: nil)
            }else{
                //アップロード成功、画像を表示
                self.profileImageVIew.image = selectedImage
            }
        } progressBlock: { (progress) in
            print(progress)
        }
    }
    
    
    
    //【プロフィール画像の編集アラート】
    @IBAction func selectImage() {
        let selectImageActionController = UIAlertController(title: "メニュー", message: "メニューを選択して下さい", preferredStyle: .actionSheet)
        //選択肢(カメラ)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            //シュミレーターでは使えない。クラッシュを防ぐためif文でカメラが使える場合とそうでない場合で分ける
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                print("使用できません")
            }
        }
        //選択肢(アルバム)
        let alubumAction = UIAlertAction(title: "アルバム", style: .default) { (action) in
            //アルバムを開く
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            }else{
                print("使用できません")
            }
            //photoLiblaryを使用する際、プライバシー同意をしなければならない。ファイルInfo.plistから!
        }
        //選択肢(キャンセル)
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            //キャンセル()
            selectImageActionController.dismiss(animated: true, completion: nil)
        }
        selectImageActionController.addAction(cameraAction)
        selectImageActionController.addAction(alubumAction)
        selectImageActionController.addAction(cancelAction)
        self.present(selectImageActionController, animated: true, completion: nil)
    }
    
    //完了ボタンを押すと編集した内容とユーザーが結び付き（NCMBに保存され）、アップロードする
    
    
    @IBAction func saveUserInfo() {
        if let user = NCMBUser.current(){
            user.setObject(nameTextField.text, forKey: "displayName")
            user.setObject(userNameTextField.text, forKey: "userName")
            user.setObject(brandTextView.text, forKey: "brand")
            user.setObject(introductionTextView.text, forKey: "introduction")
            user.saveInBackground { (error) in
                if error != nil {
                    //エラー原因：print(error)がいらない
                    let errorAlert = UIAlertController(title: "保存できません", message: error!.localizedDescription, preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                        //
                        self.dismiss(animated: true, completion: nil)
                    })
                    errorAlert.addAction(okAction)
                    self.present(errorAlert, animated: true, completion: nil)
                    
                }else{
                    //
                    self.navigationController?.popViewController(animated: true)
                }
            }
            
            
        }
    }
}

//124

