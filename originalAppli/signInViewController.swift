//
//  signInViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/11/28.
//

import UIKit
import NCMB

class signInViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var roundButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var passwordTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!
    @IBAction func inquire() {
        let url = URL(string: "https://forms.gle/Kv9wee7d7dGYBCDt7")
        UIApplication.shared.open(url!)
      }

    override func viewDidLoad() {
        super.viewDidLoad()

        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        roundButton.layer.cornerRadius = 45.0
        
        errorLabel.text = ""
        
       // passwordTextField.isSecureTextEntry = true
        
    }
   
    
    @IBAction func signIn() {
 
        if (emailTextField.text?.count)! > 0 && (passwordTextField.text?.count)! > 0{
            NCMBUser.logInWithMailAddress(inBackground: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
                if error != nil {
                    self.errorLabel.text = "メールアドレスかパスワードが間違っています"
                } else {
                    let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
                    let rootViewController = storyboard.instantiateViewController(withIdentifier: "RootTabBarController")
                    UIApplication.shared.keyWindow?.rootViewController = rootViewController
                    
                    //保持
                    let ud = UserDefaults.standard
                    ud.set(true, forKey: "isLogin")
                    ud.synchronize()
                }
            }
        }
    }
    
}
