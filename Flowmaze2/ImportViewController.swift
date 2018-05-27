//
//  ImportViewController.swift
//  Flowmaze2
//
//  Created by Knut Erik Borgen on 27.05.2018.
//  Copyright © 2018 Knut Erik Borgen. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import MobileCoreServices

class ImportViewController: UIViewController {

    @IBOutlet var messageLabel:UILabel!
    @IBOutlet var backButton:UIButton!

    var captureSession = AVCaptureSession()
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var qrCodeFrameView:UIView?
    
    private let supportedCodeTypes = [AVMetadataObject.ObjectType.qr]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // Get the back-facing camera for capturing videos
        let deviceDiscoverySession = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInDualCamera], mediaType: AVMediaType.video, position: .back)
        
        guard let captureDevice = deviceDiscoverySession.devices.first else {
            messageLabel.text = "Failed to get the camera device"
            return
        }
        
        do {
            // Get an instance of the AVCaptureDeviceInput class using the previous device object.
            let input = try AVCaptureDeviceInput(device: captureDevice)
            
            // Set the input device on the capture session.
            captureSession.addInput(input)
            
            // Initialize a AVCaptureMetadataOutput object and set it as the output device to the capture session.
            let captureMetadataOutput = AVCaptureMetadataOutput()
            captureSession.addOutput(captureMetadataOutput)
            
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            captureMetadataOutput.metadataObjectTypes = supportedCodeTypes
            //            captureMetadataOutput.metadataObjectTypes = [AVMetadataObject.ObjectType.qr]
            
        } catch {
            // If any error occurs, simply print it out and don't continue any more.
            print(error)
            return
        }
        
        // Initialize the video preview layer and add it as a sublayer to the viewPreview view's layer.
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer?.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer!)
        
        // Start video capture.
        captureSession.startRunning()
        
        // Move the message label and top bar to the front
        view.bringSubview(toFront: messageLabel)
        view.bringSubview(toFront: backButton)
        
        // Initialize QR Code Frame to highlight the QR code
        qrCodeFrameView = UIView()
        
        if let qrCodeFrameView = qrCodeFrameView {
            qrCodeFrameView.layer.borderColor = UIColor.green.cgColor
            qrCodeFrameView.layer.borderWidth = 2
            view.addSubview(qrCodeFrameView)
            view.bringSubview(toFront: qrCodeFrameView)
        }

    }
    
  
}


extension ImportViewController: AVCaptureMetadataOutputObjectsDelegate {
    
    func parseJson(json:[String:Any]) {
        
        let pixel_width = json["pw"]
        let pixel_height = json["ph"]
        let board_size_x = json["bx"] is String ? (json["bx"] as! String) : String((json["bx"] as! Int))
        let board_size_y = json["by"] is String ? (json["by"] as! String) : String((json["by"] as! Int))
        let endTick = Int(json["tk"] as! String)!
        
        let level:String = json["ll"] as! String
        let whenDate = json["wn"] as! String
        let actions = json["ms"] as! String
        // let checksum = json["cs"]
        let name = json["sn"] as! String
        
        
        let defaults = UserDefaults(suiteName: "group.flowmaze.knubo.no")!
        
        let myBoardSizeX = defaults.string(forKey:"board_size_x")
        let myBoardSizeY = defaults.string(forKey:"board_size_y")
        
        
        if(myBoardSizeX == nil) {
            messageLabel
                .text = "Play one round before importing score"
            return
        }
        
        if(board_size_x != myBoardSizeX || board_size_y != myBoardSizeY) {
            messageLabel.text = "Game played on other device type than yours"
            return
        }
        
        
        //VERIFY CHECKSUM ??
        
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
            messageLabel.text = "Higher score already registered"
            return
        }
        
        defaults.set(endTick, forKey: level + "_tick_"+name)
        defaults.set(whenDate, forKey:level+"_when_"+name)
        defaults.set(actions, forKey:level+"moves_"+name)
        
        
        defaults.set(pixel_width, forKey: level+"_pixel_width_"+name)
        defaults.set(pixel_height, forKey: level+"_pixel_height_"+name)
        defaults.set(board_size_x, forKey: level+"_board_size_x_"+name)
        defaults.set(board_size_y, forKey: level+"_board_size_y_"+name)
        
        messageLabel.text = "Score imported"
        
        
    }
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects.count == 0 {
            qrCodeFrameView?.frame = CGRect.zero
            messageLabel.text = "No QR code is detected"
            return
        }
        
        // Get the metadata object.
        let metadataObj = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        
        if supportedCodeTypes.contains(metadataObj.type) {
            // If the found metadata is equal to the QR code metadata (or barcode) then update the status label's text and set the bounds
            let barCodeObject = videoPreviewLayer?.transformedMetadataObject(for: metadataObj)
            qrCodeFrameView?.frame = barCodeObject!.bounds
            
            if metadataObj.stringValue != nil {
        //        launchApp(decodedURL: metadataObj.stringValue!)
                messageLabel.text = "QR code found"22
            }
            
            if let data = metadataObj.stringValue!.data(using: String.Encoding.utf8) {
                do {
                    let json = try JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String:Any]
                    
                    if(json == nil) {
                        messageLabel.text = "Failed to read data"
                    } else {
                        parseJson(json:json!);
                    }
                } catch {
                    messageLabel.text = "JSON Parse error:" + metadataObj.stringValue!
                    
                }

            }
        }
        
    }
    
    
}


