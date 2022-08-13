import Foundation
import UIKit
import WebKit
import StoreKit

class HelpViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var subView: UIView!
    
    var webView:WKWebView!
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: subView.bounds, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        subView.addSubview(webView)
    
    }
    
  
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.automaticallyAdjustsScrollViewInsets = false
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
       

    }
    


}


