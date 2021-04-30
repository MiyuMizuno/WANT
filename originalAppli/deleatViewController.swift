//
//  deleatViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/04.
//

import UIKit
import NCMB
import Kingfisher
import SwiftDate
import KRProgressHUD

class deleatViewController: UIViewController {
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    //退会ボタンを押すとログイン画面に切り替え
    @IBAction func deleatButton(){
        //メアドとパスワードの確認
        if (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0{
            NCMBUser.logInWithMailAddress(inBackground: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    self.errorLabel.text = "メールアドレスかパスワードが間違っています"
                }else{
                    //合っている時
                    let deleatAlert = UIAlertController(title: "退会", message: "本当に退化しますか？退会した場合、このアカウントを再度ご利用頂くことができません", preferredStyle: .alert)
                    let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
                        if let user = NCMBUser.current() {
                            user.setObject(false, forKey: "active")
                            user.saveInBackground { (error) in
                                if error != nil{
                                    KRProgressHUD.showError(withMessage: error!.localizedDescription)
                                }else{
                                    let storyboad = UIStoryboard(name: "signIn", bundle: Bundle.main)
                                    let rootViewController = storyboad.instantiateViewController(withIdentifier: "RootNavigationController")
                                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                                    
                                    //保持
                                    let ud = UserDefaults.standard
                                    ud.set(false, forKey: "isLogin")
                                    ud.synchronize()
                                }
                            }
                        }else{
                            let storyboad = UIStoryboard(name: "sinIn", bundle: Bundle.main)
                            let rootViewController = storyboad.instantiateViewController(withIdentifier: "RootNavigationController")
                            UIApplication.shared.keyWindow?.rootViewController = rootViewController
                            //保持
                            let ud = UserDefaults.standard
                            ud.set(false, forKey: "isLogin")
                            ud.synchronize()
                        }
                        
                        
                        
                        
                    }
                    let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
                        deleatAlert.dismiss(animated: true, completion: nil)
                        
                    }
                    deleatAlert.addAction(okAction)
                    deleatAlert.addAction(cancelAction)
                    self.present(deleatAlert, animated: true, completion: nil)
                }
                
            }
        }
    }
}
