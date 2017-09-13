//
//  MemoViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/09/11.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class MemoViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    var memoDatas = [Dictionary<String,String>]()
    //データの呼び出し
    func loadMemo(){
        //ud読み込み
        let ud = UserDefaults.standard
        if ud.array(forKey: "memoArray") != nil {
            //nilでないときだけ、Dictionaryとして取り出せる
            memoDatas = ud.array(forKey: "memoArray") as! [Dictionary<String,String>]
            memoTableView.reloadData()
        }
        
    }
    
    //TableView
    @IBOutlet var memoTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //データ・ソースメソッドをこのファイル内で処理する
        memoTableView.dataSource = self
        
        //デリゲートメソッドをselfに任せる
        memoTableView.delegate = self
        
        //TableViewの不要な線を消す
        memoTableView.tableFooterView = UIView()
        
        //カスタムセルの場合：カスタムセルの登録
        let nib = UINib(nibName: "MemoTableViewCell", bundle: Bundle.main)
        memoTableView.register(nib, forCellReuseIdentifier: "MemoCell")
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //1. TableViewに表示するデータの個数
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return memoDatas.count
    }
    
    //2. TableViewに表示するデータの内容を決める
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MemoCell", for: indexPath as IndexPath) as! MemoTableViewCell
        
        //表示内容を決める
        cell.memoImageView.image = UIImage(named: memoDatas[indexPath.row]["image"]!)
        cell.memoUpdatedDateTimeLabel.text = memoDatas[indexPath.row]["updatedDateTime"]
        cell.memoUrlLabel.text = memoDatas[indexPath.row]["url"]
        cell.memoSummaryLabel.text = memoDatas[indexPath.row]["summary"]
        cell.deleteMemoButton.tag = indexPath.row
        
        //cellを返す
        return cell
    }
    
    //画面が表示される時
    override func viewWillAppear(_ animated: Bool) {
        //データの呼び出し
        loadMemo()
    }
    
    //セルが押された時のデリゲートメソッド
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //任意のタイミングで遷移
        self.performSegue(withIdentifier: "toEditor", sender: nil)
        
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEditor" {
            //次の画面のオブジェクトを取得
            let searchViewController = segue.destination as! SearchViewController
            
            //次の画面の変数にこの画面の変数を入れている
            let selectedIndex = memoTableView.indexPathForSelectedRow!
            searchViewController.passedUrlFromMemo = memoDatas[selectedIndex.row]["url"]
            searchViewController.passedMemo = memoDatas[selectedIndex.row]["summary"]
        }
    }
    
    @IBAction func back(){
        self.dismiss(animated: true, completion: nil)
    }

    

}