//
//  EditSitesViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/27.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class EditSitesViewController: UIViewController, UICollectionViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, SiteCollectionViewCellDelegate, UICollectionViewDelegate {
    
    @IBOutlet var siteCollectionView: UICollectionView!
        
    var siteDatas = [Dictionary<String,String>]()
    var selectedRow: Int!
    var selectedSiteData: Dictionary<String, Any>!
    
    var selectedBackgroundImage: UIImage!
    
    /*---
     背景画像読み込み
     ---*/
    func loadBackground(){
        if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let loadFilePath = directory.appendingPathComponent("Settings/background.png")
            let image = UIImage(contentsOfFile: loadFilePath.path)
            if image != nil{
                self.view.backgroundColor = UIColor(patternImage: image!)
            } else {
                self.view.backgroundColor = UIColor.white
            }
        }
    }

    //データの呼び出し
    func loadSite(){
        let ud = UserDefaults.standard
        if ud.array(forKey: "siteArray") != nil {
            //nilでないときだけ、Dictionaryとして取り出せる
            siteDatas = ud.array(forKey: "siteArray") as! [Dictionary<String,String>]
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //長押しジェスチャ
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(EditSitesViewController.pressCell(sender:)))
        longPressGesture.minimumPressDuration = 0.5
        self.view.addGestureRecognizer(longPressGesture)
        
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
    
    
    //3. ドラッグ&ドロップ終了後
    func collectionView(_ collectionView: UICollectionView, moveItemAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let tempSiteData = siteDatas.remove(at: sourceIndexPath.item)
        siteDatas.insert(tempSiteData, at: destinationIndexPath.item)
    }
    

    /* -----
     次の画面に値を渡すときに使う関数（メソッド）
     ----- */
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //新規登録時
        if segue.identifier == "toEditSite" {
            //次の画面のオブジェクトを取得
            let editSiteDetailViewController = segue.destination as! EditSiteDetailViewController

            //次の画面の変数にこの画面の変数を入れている
            editSiteDetailViewController.passedRow = selectedRow
            editSiteDetailViewController.passedSiteData = selectedSiteData
            
        } 
    }
    
    /* -----
     セルが選択されたときに呼ばれるデリゲートメソッド
     ----- */
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        selectedRow = indexPath.row
        selectedSiteData = siteDatas[indexPath.row]
        performSegue(withIdentifier: "toEditSite", sender: self)
    }
    
    
    /* -----
     サイト追加
     ----- */
    @IBAction func addSite(){
        performSegue(withIdentifier: "toEditSite", sender: self)
    }
    
    /* -----
     サイト並び替え完了
     ----- */
    @IBAction func updateOrder(){
        //ユーザーデフォルトの領域を確保
        let ud = UserDefaults.standard
        
        //ユーザーデフォルトに一つでも保存されている値があったら
        if ud.array(forKey: "siteArray") != nil{
            ud.set(siteDatas, forKey: "siteArray")
            
            //保存
            ud.synchronize()
            back()
        }
    }
    
    
    func didTapDelegate(){
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBackground()
        
        selectedSiteData = nil
        
        //データの呼び出し
        loadSite()
        siteCollectionView.reloadData()
    }
    
    /* ---
     長押し
    --- */
    @IBAction func pressCell(sender: UILongPressGestureRecognizer) {
        /* ---
        if(sender.state == UIGestureRecognizerState.began) {
            print("長押し開始")
        } else if (sender.state == UIGestureRecognizerState.ended) {
            print("長押し終了")
        }
        ---*/
    
        switch(sender.state) {
        
        case UIGestureRecognizerState.began:
            guard let selectedIndexPath = siteCollectionView.indexPathForItem(at: sender.location(in: siteCollectionView)) else {
                break
            }
            siteCollectionView.beginInteractiveMovementForItem(at: selectedIndexPath)
            
        case UIGestureRecognizerState.changed:
            siteCollectionView.updateInteractiveMovementTargetPosition(sender.location(in: sender.view!))
            
        case UIGestureRecognizerState.ended:
            siteCollectionView.endInteractiveMovement()
            
        default:
            siteCollectionView.cancelInteractiveMovement()
        }
    }
    
    @IBAction func deleteBackground(){
        if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let savedFileName = "Settings/background.png"
            let savedFilePath = directory.appendingPathComponent(savedFileName).path
            do {
                try FileManager.default.removeItem(atPath: savedFilePath)
            } catch {
                print(error)
            }
        }
        
        self.view.backgroundColor = UIColor.white
    }
    
    /* ---
     画像選択部分
     --- */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedBackgroundImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        self.dismiss(animated: true, completion: nil)
                
        if selectedBackgroundImage != nil {
        /* ---
         画像の保存
         --- */
        let backgroundImageData = UIImagePNGRepresentation(selectedBackgroundImage!)
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "Settings"
        let backgroundImageName = "background.png"
        let saveFileName = directoryName + "/" + backgroundImageName
        
        //保存先表示
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        
        //なければディレクトリSettings作成
        do {
            try FileManager.default.createDirectory(atPath: documentDirectoryPath + "/" + directoryName, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        
        //画像を保存する
        if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let saveFilePath = directory.appendingPathComponent(saveFileName)
            
            do {
                try backgroundImageData?.write(to: saveFilePath, options: [.atomic])
            } catch {
                print(error)
            }
        }
        
        //TODO 背景変更
        self.view.backgroundColor = UIColor(patternImage: selectedBackgroundImage)
        
        }
        
    }
    
    @IBAction func selectBackgroundImage(){
        let actionController = UIAlertController(title: "画像の選択", message: "選択して下さい", preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "カメラ", style: .default) { (action) in
            //カメラ起動
            if UIImagePickerController.isSourceTypeAvailable(.camera) {
                let picker = UIImagePickerController()
                picker.sourceType = .camera
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではカメラが使用出来ません。")
            }
        }
        let albumAction = UIAlertAction(title: "フォトライブラリ", style: .default) { (action) in
            //アルバム起動
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary) {
                let picker = UIImagePickerController()
                picker.sourceType = .photoLibrary
                picker.delegate = self
                self.present(picker, animated: true, completion: nil)
            } else {
                print("この機種ではフォトライブラリが使用出来ません。")
            }
        }
        let clearAction = UIAlertAction(title: "画像をクリア", style: .default) { (action) in
            self.deleteBackground()
        }
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(clearAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
        
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }


}

