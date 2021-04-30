//
//  signUpViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/11/28.
//

import UIKit
import NCMB

class signUpViewController: UIViewController, UITextFieldDelegate {
    
    
    @IBOutlet var roundButton: UIButton!
    @IBOutlet var emailTextField: UITextField!
    @IBOutlet var confirmTextField: UITextField!
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()

        roundButton.layer.cornerRadius = 45.0
        
        emailTextField.delegate = self
        confirmTextField.delegate = self
        
        errorLabel.text = ""
    }
    
   
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    //メールアドレスログイン
       @IBAction func signUp() {
           if  emailTextField.text == confirmTextField.text && (emailTextField.text?.count)! > 0{
               NCMBUser.requestAuthenticationMail(emailTextField.text, error: nil)
            self.performSegue(withIdentifier: "mail", sender: nil)
           } else {
               errorLabel.text = "メールアドレスが正しくありません"
           }
       }
    

}
