//
//  ShareViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 18.01.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import UIKit

class ShareViewController: UIViewController {
    @IBOutlet weak var qrCodeImage: UIImageView!
    @IBOutlet weak var logoImage: UIImageView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var shareButton: UIButton!

    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet weak var nameLabel: UITextField!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var tickLabel: UILabel!

    var activeField: UITextField?
    
    override func viewDidLayoutSubviews() {
        let str = HighScores.sharedInstance.getQRCode(level: HighScoreDetailsViewController.score!.level)
        let q = QRCode(str)
        
        levelLabel.text = "Level: "+String(HighScoreDetailsViewController.score!.level)
        tickLabel.text = "Tick: "+String(HighScoreDetailsViewController.score!.endTick)
        
        qrCodeImage.image = q?.image
        
        nameLabel.text = HighScores.sharedInstance.getMyName()
        
        logoImage.image = UIImage(named: "Flowmaze.png")!
        
        registerForKeyboardNotifications()
        
        scrollView.contentSize = CGSize(width:400, height:Int(scrollView.bounds.height * 1.5))
    }
    
    @IBAction func textField(_ sender: AnyObject) {
        let value = nameLabel.text!
        
        HighScores.sharedInstance.setMyName(name: value)
        self.view.endEditing(true);
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        deregisterFromKeyboardNotifications()
    }

    //MARK: Actions
    
    @IBAction func back(_ sender: Any) {
        dismiss(animated: true) {
        }
    }

    @IBAction func share(_ sender: Any) {
        updateImageAndShareName()
        
        self.scrollView.setContentOffset(.zero, animated: true)
        
        self.backButton.isHidden = true
        self.shareButton.isHidden = true
        
        let bounds = UIScreen.main.bounds
        let renderer = UIGraphicsImageRenderer(bounds: bounds)
        let img = renderer.image { _ in
            self.view.drawHierarchy(in: bounds, afterScreenUpdates: true)
        }
        let activityViewController = UIActivityViewController(activityItems: [img], applicationActivities: nil)
        self.present(activityViewController, animated: true, completion: nil)
        
        backButton.isHidden = false
        shareButton.isHidden = false

    }
    func updateImageAndShareName() {
        HighScores.sharedInstance.setMyName(name: nameLabel.text!)

        let str = HighScores.sharedInstance.getQRCode(level: HighScoreDetailsViewController.score!.level)
        let q = QRCode(str)
        qrCodeImage.image = q?.image

    }
    func registerForKeyboardNotifications() {
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    func deregisterFromKeyboardNotifications() {
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification) {
        //Need to calculate keyboard exact size due to Apple suggestions
        self.scrollView.isScrollEnabled = true
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize!.height, right: 0.0)
        
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
        
        var aRect : CGRect = self.view.frame
        aRect.size.height -= keyboardSize!.height
        
        if (!aRect.contains(nameLabel.frame.origin)) {
            self.scrollView.scrollRectToVisible(nameLabel.frame, animated: true)
        }
        
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification) {
        //Once keyboard disappears, restore original positions
        let info = notification.userInfo!
        let keyboardSize = (info[UIResponder.keyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let contentInsets : UIEdgeInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: -keyboardSize!.height, right: 0.0)
        self.scrollView.contentInset = contentInsets
        self.scrollView.scrollIndicatorInsets = contentInsets
//        self.view.endEditing(true)
       // self.scrollView.isScrollEnabled = false
    }
}
