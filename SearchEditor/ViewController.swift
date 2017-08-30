//
//  ViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/08/23.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding


class ViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var avoidingView: UIView!
    @IBOutlet var queryField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        queryField.delegate = self
                
        KeyboardAvoiding.avoidingView = self.avoidingView
        
    }
    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.queryField {
            KeyboardAvoiding.avoidingView = self.avoidingView
        }
        return true
    }
    
    //return keyが押されたときに呼ばれるデリゲートメソッド
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.queryField.becomeFirstResponder()
        
        //次の画面に行く
        self.performSegue(withIdentifier: "toSearch", sender: nil)
        return true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //キーボード
        queryField.returnKeyType = UIReturnKeyType.search
        queryField.becomeFirstResponder()
    }
    
    //次の画面に値を渡すときに使う関数（メソッド）
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //次の画面のオブジェクトを取得
        let searchViewController = segue.destination as! SearchViewController
        
        //次の画面の変数にこの画面の変数を入れている
        searchViewController.passedQuery = queryField.text
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

}

