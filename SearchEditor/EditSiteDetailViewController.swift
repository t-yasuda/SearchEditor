//
//  EditSiteDetailViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/27.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class EditSiteDetailViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet var siteImageView: UIImageView!
    @IBOutlet var titleTextField: UITextField!
    @IBOutlet var urlTextField: UITextField!
    
    @IBOutlet var deleteButton: UIButton!
    
    
    //渡された変数
    var passedRow: Int!
    var passedSiteData: Dictionary<String, Any>!
    
    var selectedImage = UIImage(named: "noimage.png")
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //新規登録と更新で分ける
        if passedSiteData != nil{
            //更新の場合フォームを埋める

            /*--- アイコン画像読み込み ---*/
            if passedSiteData["iconPath"] != nil {
                if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                    let loadFileName = passedSiteData["iconPath"]
                    let loadFilePath = directory.appendingPathComponent(loadFileName! as! String)
                    let image = UIImage(contentsOfFile: loadFilePath.path)
                    siteImageView.image = image
                    selectedImage = image
                }
            }
            titleTextField.text = passedSiteData["title"] as? String
            urlTextField.text = passedSiteData["url"] as? String
            
            deleteButton.isEnabled = true
            
        } else {
            //新規の場合は削除ボタンを消す
            deleteButton.isEnabled = false
        }
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    @IBAction func createSite(){
        //フォームに入力された値
        let order = 0
        let inputTitleText = titleTextField.text
        let inputUrlText = urlTextField.text
        
        /* ---
         アイコン画像の保存
         --- */
        let siteImageData = UIImagePNGRepresentation(selectedImage!)
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "Sites"
        let siteImageName = String(NSDate().timeIntervalSince1970) + ".png"
        let saveFileName = directoryName + "/" + siteImageName
        
        //保存先表示
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        
        //なければディレクトリSites作成
        do {
            try FileManager.default.createDirectory(atPath: documentDirectoryPath + "/" + directoryName, withIntermediateDirectories: false, attributes: nil)
        } catch {
            print(error)
        }
        
        //画像を保存する
        if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
            let saveFilePath = directory.appendingPathComponent(saveFileName)
            
            do {
                try siteImageData?.write(to: saveFilePath, options: [.atomic])
            } catch {
                print(error)
            }
        }
        
        /* ---
         サイト情報の保存
         --- */
        let siteData = [
            "order": String(order),
            "title": inputTitleText!,
            "url": inputUrlText!,
            "iconPath": saveFileName
        ]
        
        //ユーザーデフォルトの領域を確保
        let ud = UserDefaults.standard
        
        //ユーザーデフォルトに一つでも保存されている値があったら
        if ud.array(forKey: "siteArray") != nil{
            //OptionalからStringにダウンキャスト＆アンラップ
            var saveSitesArray = ud.array(forKey: "siteArray") as! [Dictionary<String,String>]
            saveSitesArray.append(siteData)
            ud.set(saveSitesArray, forKey: "siteArray")
            
            //保存
            ud.synchronize()
            
            //ユーザーデフォルトに何も保存されていない場合
        } else {
            var newSitesArray = [Dictionary<String,String>]()
            newSitesArray.append(siteData)
            ud.set(newSitesArray, forKey: "siteArray")
            
            //保存
            ud.synchronize()
        }
    }
    
    @IBAction func deleteSite(){
        //TODO: アラート
        let ud = UserDefaults.standard
        
        if ud.array(forKey: "siteArray") != nil {
            //保存していたメモの配列
            var savedSiteArray = ud.array(forKey: "siteArray") as! [Dictionary<String, String>]
            
            //アイコンも削除
            if savedSiteArray[passedRow].index(forKey: "iconPath") != nil {
                if let directory = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
                    let savedFileName = savedSiteArray[passedRow]["iconPath"]
                    let savedFilePath = directory.appendingPathComponent(savedFileName!).path
                    do {
                        try FileManager.default.removeItem(atPath: savedFilePath)
                    } catch {
                        print(error)
                    }
                }
            }
            
            //押されたrowの削除
            savedSiteArray.remove(at: passedRow)
            //保存し直す
            ud.set(savedSiteArray, forKey: "siteArray")
            ud.synchronize()

        }
        back()
    }
    
    
    @IBAction func save(){
        //新規登録と更新で分ける
        if passedSiteData != nil{
            createSite()
            deleteSite()
            back()
        } else {
            createSite()
            back()
        }
    }
    
    
    /* ---
     画像選択部分
    --- */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        siteImageView.image = selectedImage
        
        picker.dismiss(animated: true, completion: nil)
        
    }
    
    @IBAction func selectImage(){
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
        let cancelAction = UIAlertAction(title: "キャンセル", style: .cancel) { (action) in
            actionController.dismiss(animated: true, completion: nil)
        }
        actionController.addAction(cameraAction)
        actionController.addAction(albumAction)
        actionController.addAction(cancelAction)
        self.present(actionController, animated: true, completion: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadBackground()
    }
    
    
    @IBAction func back(){
        self.navigationController?.popViewController(animated: true)
    }


}
