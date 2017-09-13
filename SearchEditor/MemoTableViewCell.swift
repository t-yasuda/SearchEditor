//
//  MemoTableViewCell.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/12.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class MemoTableViewCell: UITableViewCell {
    
    @IBOutlet var memoImageView: UIImageView!
    
    @IBOutlet var memoUpdatedDateTimeLabel: UILabel!
    
    @IBOutlet var memoUrlLabel :UILabel!
    
    @IBOutlet var memoSummaryLabel :UILabel!
    
    @IBOutlet var deleteMemoButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /* -----
     メモを削除する
     ----- */
    @IBAction func deleteMemo(sender: UIButton){
         //今見ているメモが配列の何番目なのか確認
         let ud = UserDefaults.standard
         
         if ud.array(forKey: "memoArray") != nil {
            //保存していたメモの配列
            var savedMemoArray = ud.array(forKey: "memoArray") as! [Dictionary<String, String>]
            //押されたrowの削除
            savedMemoArray.remove(at: sender.tag)
            //保存し直す
            ud.set(savedMemoArray, forKey: "memoArray")
            ud.synchronize()
            
            memoUpdatedDateTimeLabel.textColor = UIColor.red
            memoUrlLabel.textColor = UIColor.red
            memoSummaryLabel.textColor = UIColor.red
            deleteMemoButton.removeFromSuperview()
        }
    }
}
