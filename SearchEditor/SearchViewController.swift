//
//  SearchViewController.swift
//  SearchEditor
//
//  Created by nttr on 2017/08/24.
//  Copyright © 2017年 nttr. All rights reserved.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet weak var webView: UIWebView!
    var passedQuery: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        var search_url:String = "https://search.goo.ne.jp/web.jsp?MT="+passedQuery+"&IE=UTF-8&OE=UTF-8"
        
        search_url = search_url.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlQueryAllowed)!

        let requestURL = NSURL(string: search_url)
        let request = NSURLRequest(url: requestURL! as URL)
        webView.loadRequest(request as URLRequest)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
}
