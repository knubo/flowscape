//
//  ActionViewController.swift
//  FlowMazeImport
//
//  Created by Knut Erik Borgen on 03.02.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var statusLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for an image and place it into an image view.
        // Replace this with something appropriate for the type[s] your extension supports.
        var imageFound = false
        for item in self.extensionContext!.inputItems as! [NSExtensionItem] {
            for provider in item.attachments! as! [NSItemProvider] {
                if provider.hasItemConformingToTypeIdentifier(kUTTypeImage as String) {
                    // This is an image. We'll load it, then place it in our image view.
                    weak var weakImageView = self.imageView
                    provider.loadItem(forTypeIdentifier: kUTTypeImage as String, options: nil, completionHandler: { (imageURL, error) in
                        OperationQueue.main.addOperation {
                            if let strongImageView = weakImageView {
                                if let imageURL = imageURL as? URL {
                                    strongImageView.image = UIImage(data: try! Data(contentsOf: imageURL))
                                    self.imageLoaded(image:strongImageView.image!)
                                }
                            }
                        }
                    })
                    
                    imageFound = true
                    break
                }
            }
            
            if (imageFound) {
                // We only handle one image, so stop looking for more.
                break
            }
        }
    }
    
    func imageLoaded(image:UIImage) {
        let features = detectQRCode(image)
        
        if(features?.count == 0) {
            statusLabel.text="Found no QR code"
            return
        }
        
        var decode = ""
        
        for feature in features as! [CIQRCodeFeature] {
            decode = feature.messageString!
        }
        
        if let data = decode.data(using: String.Encoding.utf8) {
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
            
                if(json == nil) {
                    statusLabel.text = "Failed to read data"
                } else {
                    parseJson(json:json!);
                }
                
            } catch {
                statusLabel.text = "JSON Parse error:"+decode
            }
        }
        
    }
    
    func detectQRCode(_ image: UIImage?) -> [CIFeature]? {
        
        if let image = image, let ciImage = CIImage.init(image: image) {
            var options: [String: Any]
            let context = CIContext()
            options = [CIDetectorAccuracy: CIDetectorAccuracyHigh]
            let qrDetector = CIDetector(ofType: CIDetectorTypeQRCode, context: context, options: options)
            if ciImage.properties.keys.contains((kCGImagePropertyOrientation as String)){
                options = [CIDetectorImageOrientation: ciImage.properties[(kCGImagePropertyOrientation as String)] ?? 1]
            } else {
                options = [CIDetectorImageOrientation: 1]
            }
            let features = qrDetector?.features(in: ciImage, options: options)
            return features
            
        }
        
        return []
            
    }

    func parseJson(json:[String:Any]) {

 
        
        let pixel_width = json["pw"]
        let pixel_height = json["ph"]
        let board_size_x = json["bx"]
        let board_size_y = json["by"]
        let endTick = Int(json["tk"] as! String)!
        
        let level:String = json["ll"] as! String
        let whenDate = json["wn"] as! String
        let actions = json["ms"] as! String
        let checksum = json["cs"]
        let name = json["sn"] as! String
        
 
        let defaults = UserDefaults(suiteName: "no.knubo.flowmaze.highscore")!
                
        //TODO VERIFY CHECKSUM
        
        var levels = defaults.stringArray(forKey:"levels") ?? [String]()
        
        if(!levels.contains(level)) {
            levels.append(level)
            defaults.set(levels, forKey:"levels")
        }
        
        var who = defaults.stringArray(forKey:level) ?? [String]()
        if(!who.contains(name)) {
            who.append(name)
            defaults.set(who, forKey:level)
        }
        
        let tick = defaults.integer(forKey: level + "_tick_"+name)
        
        if(tick != 0 && tick <= endTick) {
            statusLabel.text = "Higher score already registered"
            return
        }
        
        defaults.set(endTick, forKey: level + "_tick_"+name)
        defaults.set(whenDate, forKey:level+"_when_"+name)
        defaults.set(actions, forKey:level+"moves_"+name)
        
        
        defaults.set(pixel_width, forKey: level+"_pixel_width_"+name)
        defaults.set(pixel_height, forKey: level+"_pixel_height_"+name)
        defaults.set(board_size_x, forKey: level+"_board_size_x_"+name)
        defaults.set(board_size_y, forKey: level+"_board_size_y_"+name)
        
        statusLabel.text = "Score imported"
    }
    

    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
        // This template doesn't do anything, so we just echo the passed in items.
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }

}
