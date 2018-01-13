//
//  ViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 26.12.2017.
//  Copyright © 2017 Knut Erik Borgen. All rights reserved.
//

import UIKit

class GameViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.layoutIfNeeded()
        
        // Do any additional setup after loading the view, typically from a nib.
        NotificationCenter.default.addObserver(self, selector: #selector(self.goToMenu(notification:)), name: Notification.Name("goToMenu"), object: nil)
        
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

