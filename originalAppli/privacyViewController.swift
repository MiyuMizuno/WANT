//
//  privacyViewController.swift
//  originalAppli
//
//  Created by 水野未悠 on 2021/03/18.
//

import UIKit

class privacyViewController: UIViewController {
    
    @IBOutlet var consentButton: UIButton!
    @IBOutlet var nextButton: UIBarButtonItem!

    private let checkedImage = UIImage(systemName: "checkmark.square.fill")
      private let uncheckedImage = UIImage(systemName: "app")
      override func viewDidLoad() {
        super.viewDidLoad()
        nextButton.isEnabled = false
        self.consentButton.setImage(uncheckedImage, for: .normal)
        self.consentButton.setImage(checkedImage, for: .selected)
        confirmContent()
      }
      @IBAction func Next() {
        self.dismiss(animated: true, completion: nil)
      }
      @IBAction func consentButtonDidTap(_ sender: Any) {
        self.consentButton.isSelected = !self.consentButton.isSelected
        confirmContent()
      }
      func confirmContent() {
        if self.consentButton.isSelected {
          nextButton.isEnabled = true
        } else {
          nextButton.isEnabled = false
        }
      }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
