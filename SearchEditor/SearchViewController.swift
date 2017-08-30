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

    @IBOutlet var avoidingView: UIView!
    @IBOutlet var editorField: UITextView!

    @IBOutlet weak var webView: UIWebView!
    var passedQuery: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        hideEditorField()
        
        //Web読み込み
        var search_url:String = "https://search.goo.ne.jp/web.jsp?MT="+passedQuery+"&IE=UTF-8&OE=UTF-8"
        
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
    
    
    @IBAction func hideEditorField(){
        avoidingView.isHidden = true
    }
    
    @IBAction func showEditorField(){
        avoidingView.isHidden = false
        editorField.becomeFirstResponder()
    }
    
    @IBAction func goBack(){
        self.webView.goBack()
    }
    
    @IBAction func goForward(){
        self.webView.goForward()
    }
    
}
