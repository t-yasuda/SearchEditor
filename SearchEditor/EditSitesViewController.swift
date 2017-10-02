//
//  EditSitesViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/27.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class EditSitesViewController: UIViewController, UICollectionViewDataSource, SiteCollectionViewCellDelegate {
    
    @IBOutlet var siteCollectionView: UICollectionView!
        
    var siteDatas = [Dictionary<String,String>]()

    //データの呼び出し
    func loadSite(){
        let ud = UserDefaults.standard
        if ud.array(forKey: "SiteArray") != nil {
            //nilでないときだけ、Dictionaryとして取り出せる
            siteDatas = ud.array(forKey: "SiteArray") as! [Dictionary<String,String>]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ・ソースメソッドをこのファイル内で処理する
        siteCollectionView.dataSource = self
        
        //デリゲートメソッドをselfに任せる
        siteCollectionView.delegate = self as? UICollectionViewDelegate

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
        
        cell.siteImageView.image = UIImage(named: siteDatas[indexPath.row]["icon"]!)
        cell.siteLabel.text = siteDatas[indexPath.row]["name"]!
        
        return cell
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
