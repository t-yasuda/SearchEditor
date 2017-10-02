//
//  EditSitesViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/27.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class EditSitesViewController: UIViewController, UICollectionViewDataSource, SiteCollectionViewCellDelegate, UICollectionViewDelegate {
    
    @IBOutlet var siteCollectionView: UICollectionView!
        
    var siteDatas = [Dictionary<String,String>]()
    
    var selectedRow = 0

    //データの呼び出し
    func loadSite(){
        let ud = UserDefaults.standard
        if ud.array(forKey: "siteArray") != nil {
            //nilでないときだけ、Dictionaryとして取り出せる
            siteDatas = ud.array(forKey: "siteArray") as! [Dictionary<String,String>]
            siteDatas.append(["title": "サイトを新規登録する", "url": ""])
        } else {
            siteDatas = [
                ["title": "サイトを新規登録する", "url": ""],
            ]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ・ソースメソッドをこのファイル内で処理する
        siteCollectionView.dataSource = self
        
        //デリゲートメソッドをselfに任せる
        siteCollectionView.delegate = self

        //カスタムセルの場合：カスタムセルの登録
        let nib = UINib(nibName: "SiteCollectionViewCell", bundle: Bundle.main)
        siteCollectionView.register(nib, forCellWithReuseIdentifier: "SiteCell")
        loadSite()
    }
    
    //1.CollectionViewに表示するデータの個数
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return siteDatas.count
    }
    
    //2. CollectionViewに表示するデータの内容を決める
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "SiteCell", for: indexPath) as! SiteCollectionViewCell

        /*---
         アイコン画像読み込み
         ---*/
        if siteDatas[indexPath.row].index(forKey: "iconPath") != nil {
            if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                let loadFileName = siteDatas[indexPath.row]["iconPath"]
                let loadFilePath = directory.appendingPathComponent(loadFileName!)
                let image = UIImage(contentsOfFile: loadFilePath.path)
                cell.siteImageView.image = image
            }
        }
        cell.siteLabel.text = siteDatas[indexPath.row]["title"]!
        
        return cell
    }

    /* -----
     次の画面に値を渡すときに使う関数（メソッド）
     ----- */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //新規登録時
        if segue.identifier == "toAddSite" {
            //次の画面のオブジェクトを取得
            let editSiteDetailViewController = segue.destination as! EditSiteDetailViewController
            
        } else if segue.identifier == "toEditSite" {
            
            //次の画面の変数にこの画面の変数を入れている
            //editSiteDetailViewController.passedId = siteDatas[selectedRow]["id"]
            
        }
    }
    
    /* -----
     セルが選択されたときに呼ばれるデリゲートメソッド
     ----- */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        let selectedUrl = siteDatas[indexPath.row]["url"]
        if selectedUrl != nil {
            selectedRow = indexPath.row
            performSegue(withIdentifier: "toAddSite", sender: self)
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }
    
    func didTapDelegate(){
        
    }

}
