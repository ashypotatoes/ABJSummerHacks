//
//  WebviewViewController.swift
//  webscraping
//
//  Created by Aarish  Brohi on 6/17/20.
//  Copyright © 2020 Aarish Brohi. All rights reserved.
//

import UIKit
import WebKit
import MessageUI
import Social

class WebviewViewController: UIViewController, WKNavigationDelegate {

    
    @IBOutlet weak var webView: WKWebView!
    var url: String?
    
    @IBAction func returnNews(_ sender: Any) {
        self.dismiss(animated: true , completion: nil)
        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    
    override func loadView() {
        super.loadView()
        webView.navigationDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        webView.load(URLRequest(url: URL(string: url!)!))
        webView.allowsBackForwardNavigationGestures = true
    }
    
    // share button
    @IBAction func shareButton(_ sender: Any) {
        let activityVC = UIActivityViewController(activityItems: [url!], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        
        self.present(activityVC, animated: true, completion: nil)
    }
    
}
