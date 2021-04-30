//
//  postTableViewCell.swift
//  originalAppli
//
//  Created by 水野未悠 on 2020/12/04.
//

import UIKit

//共通化　postTableViewCellDelegate とプロトコル宣言したところでは下の関数を使ってもいいという宣言
//
    protocol postTableViewCellDelegate {
        func didTapMenuButton(tableViewCell: UITableViewCell, button: UIButton)
        func didTapCommentsButton(tableViewCell: UITableViewCell, button: UIButton)
    }
    
    
    

class postTableViewCell: UITableViewCell {
    var delegate: postTableViewCellDelegate?

    
    //addCommentButton 「コメントを追加ボタン」
    //hukidasiButtun 「吹き出しアイコンボタン」
    //commentButoon　「コメントを表示」
    
    @IBOutlet var UsernameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var postTextView: UITextView!
    @IBOutlet var postImageView: UIImageView!
    @IBOutlet var addCommentTextView: UITextView!
    @IBOutlet var addCommentButton: UIButton!
    @IBOutlet var fukidasiButton: UIButton!
    @IBOutlet var commentButton: UIButton!
    @IBOutlet var CountLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    
    //セルができると同時に処理される
        override func awakeFromNib() {
            super.awakeFromNib()
    //
            //【角を丸く】
                    profileImageView.layer.cornerRadius = profileImageView.bounds.width / 2.0
                    profileImageView.layer.masksToBounds = true
}
    
    
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        // Configure the view for the selected state
   
        }
    
    
    @IBAction func openMenu(button: UIButton) {
               self.delegate?.didTapMenuButton(tableViewCell: self, button: button)
        
        }
    @IBAction func showComments(button: UIButton) {
                self.delegate?.didTapCommentsButton(tableViewCell: self, button: button)
    }
    
    
}
