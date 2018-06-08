import Foundation
import UIKit
import WebKit
import PersonalizedAdConsent
import StoreKit

class HelpViewController: UIViewController, WKUIDelegate {
    
    @IBOutlet weak var subView: UIView!
    @IBOutlet weak var buyOrPrivacyButton: UIButton!
    @IBOutlet weak var restorePurchaseButton: UIButton!
    
    var webView:WKWebView!
    
    static let productId = "FlowMaze No Adds"
    static let store = IAPHelper(productIds: [productId])
    
    override func loadView() {
        super.loadView()
        webView = WKWebView(frame: subView.bounds, configuration: WKWebViewConfiguration())
        webView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        webView.uiDelegate = self
        subView.addSubview(webView)
        
        if(HelpViewController.gamePurchased()) {
            buyOrPrivacyButton.isHidden = true
            restorePurchaseButton.isHidden = true
        }
    }
    
    static func gamePurchased() -> Bool {
        return UserDefaults.standard.bool(forKey:HelpViewController.productId)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.automaticallyAdjustsScrollViewInsets = false
        
        
        let url = Bundle.main.url(forResource: "index", withExtension: "html")!
        webView.loadFileURL(url, allowingReadAccessTo: url)
        let request = URLRequest(url: url)
        webView.load(request)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.thankYouForPurchase(notification:)), name: Notification.Name(IAPHelper.IAPHelperPurchaseNotification), object: nil)

    }
    
    func buyApp() {
        HelpViewController.store.requestProducts {success, products in
            if success {
                if(products == nil || products?.count == 0) {
                    let refreshAlert = UIAlertController(title: "Product not ready", message: "Sorry - game can not be purchased right now.", preferredStyle: UIAlertControllerStyle.alert)
                    
                    refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
                        
                    }))
                    
                    self.present(refreshAlert, animated: true, completion: nil)
                    return
                }
                let product = products![0]

                HelpViewController.store.buyProduct(product)
            }
        }
    }
    
    @IBAction func restorePurchase(_ sender: Any) {
        HelpViewController.store.restorePurchases()
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
    
    @objc func thankYouForPurchase(notification: Notification) {
        let refreshAlert = UIAlertController(title: "Add removal activated", message: "Thank you for your support!", preferredStyle: UIAlertControllerStyle.alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
}


