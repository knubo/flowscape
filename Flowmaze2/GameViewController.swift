//
//  ViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 26.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import UIKit
import GoogleMobileAds

class GameViewController: UIViewController, GADInterstitialDelegate {
    var interstitial: GADInterstitial!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMenu(notification:)), name: Notification.Name("goToMenu"), object: nil)
        
            NotificationCenter.default.addObserver(self, selector: #selector(self.showAdd(notification:)), name: Notification.Name("showAdd"), object: nil)
        
        loadAdd();
    }
    
    func loadAdd() {
        interstitial = GADInterstitial(adUnitID: "ca-app-pub-3940256099942544/4411468910")
        let request = GADRequest()
        interstitial.delegate = self
        interstitial.load(request)
    }
    
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        loadAdd()
    }
    
    @objc func showAdd(notification: Notification) {
        if interstitial.isReady {
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
    


    

}

