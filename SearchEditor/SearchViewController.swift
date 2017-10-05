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

    //webView
    @IBOutlet weak var webView: UIWebView!
    
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
    }
    
    @IBAction func openInSafari(){
        let url = URL(string:webView.stringByEvaluatingJavaScript(from: "document.URL")!)
        
        if( UIApplication.shared.canOpenURL(url!) ) {
            UIApplication.shared.open(url!)
        }
    }

    
    /* -----
     戻る
    ----- */
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
}
