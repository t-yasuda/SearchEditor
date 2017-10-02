//
//  ViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/08/23.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit
import IHKeyboardAvoiding

class ViewController: UIViewController, UITextFieldDelegate, UICollectionViewDataSource, SiteCollectionViewCellDelegate, UICollectionViewDelegate {

    @IBOutlet var siteCollectionView: UICollectionView!
    @IBOutlet var avoidingView: UIView!
    @IBOutlet var queryField: UITextField!
    
    var selectedRow = 0
        
    /* ---
     登録サイト
    --- */
    var siteDatas = [Dictionary<String,String>]()

    //データの呼び出し
    func loadSite(){
        let ud = UserDefaults.standard
        if ud.array(forKey: "SiteArray") != nil {
            //nilでないときだけ、Dictionaryとして取り出せる
            siteDatas = ud.array(forKey: "SiteArray") as! [Dictionary<String,String>]
        } else {
            siteDatas = [
                ["icon": "goo_logo.png", "name": "goo", "url": "https://search.goo.ne.jp/web.jsp?MT=[QUERY]&IE=UTF-8&OE=UTF-8"],
                ["icon": "amazon_logo.png", "name": "amazon", "url": "https://www.amazon.co.jp/gp/search?ie=UTF8&keywords=[QUERY]"],
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //背景画像指定
        //self.view.backgroundColor = UIColor(patternImage: UIImage(named:"background.jpg")!)
        
        //データ・ソースメソッドをこのファイル内で処理する
        siteCollectionView.dataSource = self
        
        //デリゲートメソッドをselfに任せる
        siteCollectionView.delegate = self
        
        //カスタムセルの場合：カスタムセルの登録
        let nib = UINib(nibName: "SiteCollectionViewCell", bundle: Bundle.main)
        siteCollectionView.register(nib, forCellWithReuseIdentifier: "SiteCell")
        
        //データ読み込み
        loadSite()
        
        queryField.delegate = self
        KeyboardAvoiding.avoidingView = self.avoidingView
        
    }
    
    //1.CollectionViewに表示するデータの個数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return siteDatas.count
    }
    
    //2. CollectionViewに表示するデータの内容を決める
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteCell", for: indexPath) as! SiteCollectionViewCell
        
        cell.siteImageView.image = UIImage(named: siteDatas[indexPath.row]["icon"]!)
        cell.siteLabel.text = siteDatas[indexPath.row]["name"]!
        
        return cell
    }

    
    public func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if textField == self.queryField {
            KeyboardAvoiding.avoidingView = self.avoidingView
        }
        return true
    }
    
    /* -----
     return keyが押されたときに呼ばれるデリゲートメソッド
    ----- */
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
    
    /* -----
     次の画面に値を渡すときに使う関数（メソッド）
    ----- */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //デフォルト
        if segue.identifier == "toSearch" {
            //次の画面のオブジェクトを取得
            let searchViewController = segue.destination as! SearchViewController
        
            //次の画面の変数にこの画面の変数を入れている
            searchViewController.passedQuery = queryField.text
         
        //サイト選択時
        } else if segue.identifier == "toSearchWithSiteUrl"{
            //次の画面のオブジェクトを取得
            let searchViewController = segue.destination as! SearchViewController

            //次の画面の変数にこの画面の変数を入れている
            searchViewController.passedQuery = queryField.text
            searchViewController.passedSite = siteDatas[selectedRow]["url"]            
        }
    }
    
    /* -----
     セルが選択されたときに呼ばれるデリゲートメソッド
     ----- */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedUrl = siteDatas[indexPath.row]["url"]
        if selectedUrl != nil {
            selectedRow = indexPath.row
            performSegue(withIdentifier: "toSearchWithSiteUrl", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func didTapDelegate(){
    }


}

