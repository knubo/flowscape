import Foundation
import UIKit
import WebKit
import PersonalizedAdConsent

class HelpViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var buyOrPrivacyButton: UIButton!
    
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
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
    }
    
    func buyApp() {
        
    }
    
    @IBAction func privacyOrBuyGame(_ sender: Any) {
        
        guard let privacyUrl = URL(string: "https://www.reddit.com/r/FlowMaze/comments/8oj6ik/flowmaze_privacy_policy/"),
            let form = PACConsentForm(applicationPrivacyPolicyURL: privacyUrl) else {
                print("incorrect privacy URL.")
                return
        }
        form.shouldOfferPersonalizedAds = true
        form.shouldOfferNonPersonalizedAds = true
        form.shouldOfferAdFree = true
        
        
        form.load {(_ error: Error?) -> Void in
            print("Load complete.")
            if let error = error {
                // Handle error.
                print("Error loading form: \(error.localizedDescription)")
            } else {
                
                form.present(from: self) { (error, userPrefersAdFree) in
                    if let error = error {
                        print("Error")
                        // Handle error.
                    } else if userPrefersAdFree {
                        self.buyApp()
                        // User prefers to use a paid version of the app.
                    } else {
                        // Check the user's consent choice.
                        
                      
                    }
                }
            }
        }
    }
    
}


