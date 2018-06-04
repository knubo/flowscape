//
//  ViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 26.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import UIKit
import GoogleMobileAds
import PersonalizedAdConsent

class GameViewController: UIViewController, GADInterstitialDelegate {
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMenu(notification:)), name: Notification.Name("goToMenu"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.showAdd(notification:)), name: Notification.Name("showAdd"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.prepareAdd(notification:)), name: Notification.Name("prepareAdd"), object: nil)

        loadAdd();
    }
    
    @objc func prepareAdd(notification: Notification) {
        if(PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown) {
            showConcentForm()
            return
        }
        
        loadAdd()
    }
    
    func loadAdd() {
        if(PACConsentInformation.sharedInstance.consentStatus == PACConsentStatus.unknown) {
            return
        }
        
        if(interstitial != nil && !interstitial.hasBeenUsed) {
            return
        }
        
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910") // TEST
       // interstitial = GADInterstitial(adUnitID: "ca-app-pub-3752721631578562/9094657594") // PROD
        let request = GADRequest()
        
        let status =
            PACConsentInformation.sharedInstance.consentStatus
        
        if(status == PACConsentStatus.nonPersonalized) {
            let extras = GADExtras()
            extras.additionalParameters = ["npa": "1"]
            request.register(extras)
        }
        
        interstitial.delegate = self
        interstitial.load(request)
    }
    
    /// Add completed.
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        loadAdd()
    }
    
    /// Tells the delegate an ad request succeeded.
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("interstitialDidReceiveAd")
    }
    
    /// Tells the delegate an ad request failed.
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("interstitial:didFailToReceiveAdWithError: \(error.localizedDescription)")
    }
    
    /// Tells the delegate that an interstitial will be presented.
    func interstitialWillPresentScreen(_ ad: GADInterstitial) {
        print("interstitialWillPresentScreen")
    }
    
    /// Tells the delegate the interstitial is to be animated off the screen.
    func interstitialWillDismissScreen(_ ad: GADInterstitial) {
        print("interstitialWillDismissScreen")
    }
    
    
    /// Tells the delegate that a user click will open another app
    /// (such as the App Store), backgrounding the current app.
    func interstitialWillLeaveApplication(_ ad: GADInterstitial) {
        print("interstitialWillLeaveApplication")
    }
    
    @objc func showAdd(notification: Notification) {
        if interstitial != nil && interstitial.isReady {
            interstitial.present(fromRootViewController: self)
        } else  {
            print("Ad wasn't ready")
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        NotificationCenter.default.post(name: Notification.Name("initGameboard"), object: nil)

    }
    
    @objc func goToMenu(notification: Notification) {
        
        performSegue(withIdentifier: "backToMenu", sender:self)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func buyApp() {
        
    }
    
    func showConcentForm() {
        
        if(PACConsentInformation.sharedInstance.consentStatus != PACConsentStatus.unknown) {
            return
        }
        
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
                       
                        self.loadAdd()
                    }
                }
            }
        }
    }
    

    

}

