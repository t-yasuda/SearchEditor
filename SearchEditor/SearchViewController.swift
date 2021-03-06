//
//  SearchViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/08/24.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class SearchViewController: UIViewController, UITextFieldDelegate, UIWebViewDelegate {
    //エディタ
    @IBOutlet var avoidingView: UIView!
    @IBOutlet var editorField: UITextView!
    @IBOutlet var saveButton: UIButton!
    @IBOutlet var updateButton: UIButton!

    //webView
    @IBOutlet weak var webView: UIWebView!
    
    @IBOutlet var progressView: UIProgressView!
    var hasFinishedLoading = false
    var progressParam: Float = 0
    
    //メモから渡されたURLとメモ
    var passedUrlFromMemo: String!
    var passedMemo: String!
    var passedIndexPathRow: Int!
    
    //トップ画面から渡された検索クエリ
    var passedQuery: String!
    
    var passedSite: String!
    
    var indexPathRow: Int!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        indexPathRow = passedIndexPathRow
        
        /* -----
         Web読み込み
        ----- */
        var search_url: String!
        
        if passedUrlFromMemo != nil {
            //メモから渡されたURLがある場合はそちらを開く
            showEditorField()
            editorField.text = passedMemo
            search_url = passedUrlFromMemo.removingPercentEncoding
            
            updateButton.isHidden = false
            
        } else {
            //トップ画面から検索クエリを渡された場合は検索を行う
            hideEditorField()
            
            if passedSite != nil {
                if passedSite.contains("[QUERY]") {
                    let search_url_splitted = passedSite.components(separatedBy: "[QUERY]")
                    search_url = search_url_splitted[0]+passedQuery+search_url_splitted[1]
                } else {
                    search_url = "https://search.goo.ne.jp/web.jsp?MT="+passedQuery+"&IE=UTF-8&OE=UTF-8"
                }
            } else {
                search_url = "https://search.goo.ne.jp/web.jsp?MT="+passedQuery+"&IE=UTF-8&OE=UTF-8"
            }
            
            updateButton.isHidden = true
            
        }
        
        search_url = search_url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        let requestURL = NSURL(string: search_url)
        let request = NSURLRequest(url: requestURL! as URL)
        webView.loadRequest(request as URLRequest)

        KeyboardAvoiding.avoidingView = self.avoidingView
        
        webView.delegate = self
    }
    
    deinit {
        webView.stopLoading()
        webView.delegate = nil
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
    
    /*---
     プログレスバー
     ---*/
    func updateProgressView() {
        if progressParam == 1 {
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.progressView.isHidden = true
            })
            
        } else {
            if hasFinishedLoading {
                progressParam = 1.0
            } else {
                if progressParam > 0.9 {
                    progressParam += 0.00001
                } else if progressParam > 0.8 {
                    progressParam += 0.0001
                } else {
                    progressParam += 0.001
                }
            }
            progressView.setProgress(progressParam, animated: true)
            
            let dispatchTime: DispatchTime = DispatchTime.now() + Double(Int64(0.008 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
            DispatchQueue.main.asyncAfter(deadline: dispatchTime, execute: {
                self.updateProgressView()
            })
        }
    }
    
    func webViewDidStartLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        hasFinishedLoading = false
        updateProgressView()
    }
    
    func webViewDidFinishLoad(_ webView: UIWebView) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hasFinishedLoading = true
        updateProgressView()
    }
    
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        UIApplication.shared.isNetworkActivityIndicatorVisible = false
        self.hasFinishedLoading = true
        updateProgressView()

    }
    
    
    /* -----
     キーボード
     ----- */
    @IBAction func hideEditorField(){
        avoidingView.isHidden = true
        editorField.resignFirstResponder()
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
    func generateThumbnail(image :UIImage) ->UIImage {
        let navigationBarHeight = UINavigationController().navigationBar.frame.size.height
        let statusBarHeight     = UIApplication.shared.statusBarFrame.size.height
        let ignoredHeight       = (statusBarHeight + navigationBarHeight) * 2 //TODO: なぜ？
        
        let screenshot       = image.cgImage
        let screenshotWidth  = Int(screenshot!.width)
        
        let rect  = CGRect.init(x: 0, y: ignoredHeight, width: CGFloat(screenshotWidth), height: CGFloat(screenshotWidth))
        let cropped = image.cgImage!.cropping(to: rect)
        let croppedImage = UIImage(cgImage: cropped!)
        
        UIGraphicsBeginImageContext(CGSize.init(width: CGFloat(160), height: CGFloat(160)))
        croppedImage.draw(in: CGRect.init(x: 0, y: 0, width: CGFloat(160), height: CGFloat(160)))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage!
        
    }
    
    @IBAction func saveMemo(){
        //メモ入力フィールドを引っ込める
        hideEditorField()
        
        /*---
         キャプチャ保存
         ---*/
        let layer = UIApplication.shared.keyWindow?.layer
        let scale = UIScreen.main.scale
        UIGraphicsBeginImageContextWithOptions((layer?.frame.size)!, false, scale);
        
        layer?.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext();
        
        let screenshotResized = generateThumbnail(image:screenshot!)
        
        let screenshotData = UIImagePNGRepresentation(screenshotResized)
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "Memos"
        let siteImageName = String(NSDate().timeIntervalSince1970) + ".png"
        let saveFileName = directoryName + "/" + siteImageName
        
        //保存先表示
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        
        //なければディレクトリMemos作成
        do {
            try FileManager.default.createDirectory(atPath: documentDirectoryPath + "/" + directoryName, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        
        //画像を保存する
        if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let saveFilePath = directory.appendingPathComponent(saveFileName)
            
            do {
                try screenshotData?.write(to: saveFilePath, options: [.atomic])
            } catch {
                print(error)
            }
        }
        
        /*---
         メモ本文保存
        ---*/
        let date = Date()
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd(E) HH:mm:ss"
        let now = formatter.string(from: date)

        let url = webView.stringByEvaluatingJavaScript(from: "document.URL")!
        let title = webView.stringByEvaluatingJavaScript(from: "document.title")!
        
        let inputText = editorField.text
        
        let memoData = [
            "thumbnailPath": saveFileName,
            "updatedDateTime": now,
            "url": url,
            "title": title,
            "summary": inputText!,
        ]
        
        //ユーザーデフォルトの領域を確保
        let ud = UserDefaults.standard
        
        //ユーザーデフォルトに一つでも保存されている値があったら
        if ud.array(forKey: "memoArray") != nil{
            //OptionalからStringにダウンキャスト＆アンラップ
            var saveMemoArray = ud.array(forKey: "memoArray") as! [Dictionary<String,String>]
            saveMemoArray.insert(memoData, at: 0)
            ud.set(saveMemoArray, forKey: "memoArray")
            
            //保存
            ud.synchronize()

        //ユーザーデフォルトに何も保存されていない場合
        } else {
            var newMemoArray = [Dictionary<String,String>]()
            newMemoArray.insert(memoData, at: 0)
            ud.set(newMemoArray, forKey: "memoArray")
            
            //保存
            ud.synchronize()
            
        }
        
        //IndexPathRowを最新にする
        indexPathRow = 0
        
        showAlertSave()
        updateButton.isHidden = false

    }
    
    
    /* -----
     メモを削除する
     ----- */
    @IBAction func deleteMemo(){
        //今見ているメモが配列の何番目なのか確認
        let ud = UserDefaults.standard
        
        if ud.array(forKey: "memoArray") != nil {
            //保存していたメモの配列
            var savedMemoArray = ud.array(forKey: "memoArray") as! [Dictionary<String, String>]

            //キャプチャも削除
            if savedMemoArray[indexPathRow].index(forKey: "thumbnailPath") != nil {
                if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                    let savedFileName = savedMemoArray[indexPathRow]["thumbnailPath"]
                    let savedFilePath = directory.appendingPathComponent(savedFileName!).path
                    do {
                        try FileManager.default.removeItem(atPath: savedFilePath)
                    } catch {
                        print(error)
                    }
                }
            }

            //押されたrowの削除
            savedMemoArray.remove(at: indexPathRow)
            
            //保存し直す
            ud.set(savedMemoArray, forKey: "memoArray")
            ud.synchronize()
        }

    }
    
    /* -----
     メモを更新する
     ----- */
    @IBAction func updateMemo(){
        //新規作成後、既存メモを削除する
        let tmpIndexPathRow = indexPathRow
        saveMemo()
        indexPathRow = tmpIndexPathRow! + 1
        deleteMemo()
        
        //IndexPathRowを最新にする
        indexPathRow = 0
        
        showAlertUpdate()
    }

    /* ---
     safariで開く
     --- */
    @IBAction func openInSafari(){
        let url = URL(string:webView.stringByEvaluatingJavaScript(from: "document.URL")!)
        
        if( UIApplication.shared.canOpenURL(url!) ) {
            UIApplication.shared.open(url!)
        }
    }
    
    /* ---
     アラート
    --- */
    @IBAction func showAlertSave(){
        //アラートの表示
        let alert = UIAlertController(title: "保存成功", message: "メモが保存されました", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //OKボタンを押したときのアクション
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func showAlertUpdate(){
        //アラートの表示
        let alert = UIAlertController(title: "更新成功", message: "メモが更新されました", preferredStyle: UIAlertControllerStyle.alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            //OKボタンを押したときのアクション
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(okAction)
        
        
        self.present(alert, animated: true, completion: nil)
    }

    
    /* -----
     戻る
    ----- */
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
}


