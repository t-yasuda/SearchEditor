//
//  SearchViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/08/24.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class SearchViewController: UIViewController, UITextFieldDelegate {
    //エディタ
    @IBOutlet var avoidingView: UIView!
    @IBOutlet var editorField: UITextView!

    @IBOutlet weak var webView: UIWebView!
    //メモから渡されたURLとメモ
    var passedUrlFromMemo: String!
    var passedMemo: String!
    
    //トップ画面から渡された検索クエリ
    var passedQuery: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        /* -----
         Web読み込み
        ----- */
        var search_url: String!
        
        if passedUrlFromMemo != nil {
            //メモから渡されたURLがある場合はそちらを開く
            showEditorField()
            editorField.text = passedMemo
            search_url = passedUrlFromMemo
        } else {
            //トップ画面から検索クエリを渡された場合は検索を行う
            hideEditorField()
            search_url = "https://search.goo.ne.jp/web.jsp?MT="+passedQuery+"&IE=UTF-8&OE=UTF-8"
        }
        
        search_url = search_url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        let requestURL = NSURL(string: search_url)
        let request = NSURLRequest(url: requestURL! as URL)
        webView.loadRequest(request as URLRequest)

        KeyboardAvoiding.avoidingView = self.avoidingView
    }

    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.editorField {
            KeyboardAvoiding.avoidingView = self.avoidingView
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == self.editorField {
            self.editorField.becomeFirstResponder()
        }
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /* -----
     キーボード
     ----- */
    @IBAction func hideEditorField(){
        avoidingView.isHidden = true
    }
    
    @IBAction func showEditorField(){
        avoidingView.isHidden = false
        editorField.becomeFirstResponder()
    }
    
    /* -----
     ブラウザの進む・戻る
    ----- */
    @IBAction func goBack(){
        self.webView.goBack()
    }
    
    @IBAction func goForward(){
        self.webView.goForward()
    }
    
    /* -----
     メモを保存する
    ----- */
    @IBAction func saveMemo(){
        let image = "noimage.jpg"

        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd(E) HH:mm:ss"
        let now = formatter.string(from: date)

        let url = webView.stringByEvaluatingJavaScript(from: "document.URL")!
        
        let inputText = editorField.text
        
        let memoData = [
            "image": image,
            "updatedDateTime": now,
            "url": url,
            "summary": inputText!,
        ]
        
        //ユーザーデフォルトの領域を確保
        let ud = UserDefaults.standard
        
        //ユーザーデフォルトに一つでも保存されている値があったら
        if ud.array(forKey: "memoArray") != nil{
            //OptionalからStringにダウンキャスト＆アンラップ
            var saveMemoArray = ud.array(forKey: "memoArray") as! [Dictionary<String,String>]
            saveMemoArray.append(memoData)
            ud.set(saveMemoArray, forKey: "memoArray")
            
        //ユーザーデフォルトに何も保存されていない場合
        } else {
            var newMemoArray = [Dictionary<String,String>]()
            newMemoArray.append(memoData)
            ud.set(newMemoArray, forKey: "memoArray")
        }
        
        //保存
        ud.synchronize()
    }
    
    /* -----
     戻る
    ----- */
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
