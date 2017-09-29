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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //画像の読み込み
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func save(){
        //新規登録と更新で分ける
        let order = 0
        let inputTitleText = titleTextField.text
        let inputUrlText = urlTextField.text
        
        
        /* 編集中 */
        //画像保存
        let image = UIImage(named: "amazon_logo.png")!
        let siteImageData = UIImagePNGRepresentation(image)
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let directoryName = "SearchEditor"
        let siteImageName = "test"
        let createPath = documentsPath + "/" + directoryName
        print(NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).last!)
        
        try! siteImageData?.write(to: URL(fileURLWithPath: createPath), options: [.atomic])

//        if let dir = FileManager.default.urls( for: .documentDirectory, in: .userDomainMask ).first {
//            
//            let path_file_name = dir.appendingPathComponent( siteImageName )
//            do {
//                try siteImageData?.write( to: path_file_name, options: [.atomic] )
//                
//            } catch {                
//                print("error")
//            }
//        }
        

        let siteData = [
            "order": String(order),
            "title": inputTitleText!,
            "url": inputUrlText!,
            "iconName": "goo_logo.pmg"
        ]
        
        //ユーザーデフォルトの領域を確保
        let ud = UserDefaults.standard
        
        //ユーザーデフォルトに一つでも保存されている値があったら
        if ud.array(forKey: "sitesArray") != nil{
            //OptionalからStringにダウンキャスト＆アンラップ
            var saveSitesArray = ud.array(forKey: "sitesArray") as! [Dictionary<String,String>]
            saveSitesArray.append(siteData)
            ud.set(saveSitesArray, forKey: "sitesArray")
            
            //保存
            ud.synchronize()
            
            //ユーザーデフォルトに何も保存されていない場合
        } else {
            var newSitesArray = [Dictionary<String,String>]()
            newSitesArray.append(siteData)
            ud.set(newSitesArray, forKey: "sitesArray")
            
            //保存
            ud.synchronize()
            
        }

    }
    
    
    /* ---
     画像選択
    --- */
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let selectedImage = info[UIImagePickerControllerOriginalImage] as! UIImage
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
    
    
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }


}
