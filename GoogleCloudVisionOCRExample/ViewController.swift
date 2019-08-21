//
//  ViewController.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Paul Oprea on 20/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit
import AVFoundation

class ViewController: UIViewController {

    @IBOutlet weak var topLeftCircle: UIView!
    var captureSession: AVCaptureSession!
    var tapRecognizer: UITapGestureRecognizer! // NEW
    var capturePhotoOutput: AVCapturePhotoOutput!
    var readyImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupTapRecognizer()
        setupPhotoOutput()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        captureSession.startRunning()
    }

    override func viewWillDisappear(_ animated: Bool) {
        captureSession.stopRunning()
    }

    private func setupCamera() {
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        var input: AVCaptureDeviceInput
        do {
            input = try AVCaptureDeviceInput(device: captureDevice!)
        } catch {
            fatalError("Error configuring capture device: \(error)");
        }
        captureSession = AVCaptureSession()
        captureSession.addInput(input)
        
        // Setup the preview view.
        let videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
//        let backgroundLayer = CALayer()
//        backgroundLayer.frame = CGRect(x: 0, y: 0, width: view.bounds.width, height: view.bounds.height)
//        backgroundLayer.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).cgColor
//        view.layer.addSublayer(backgroundLayer)
        topLeftCircle.layer.cornerRadius = 5
        view.bringSubviewToFront(topLeftCircle)
        
        let cropPath = CGPath(rect: CGRect(x: view.bounds.width/4, y: view.bounds.height/2-view.bounds.width/4, width: view.bounds.width/2, height: view.bounds.width/2), transform: nil)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).cgColor
        maskLayer.path = cropPath
        view.layer.mask = maskLayer
//        let cropLayer = CALayer()
//        cropLayer.frame = CGRect(x: view.bounds.width/4, y: view.bounds.height/2-view.bounds.width/4, width: view.bounds.width/2, height: view.bounds.width/2)
//        cropLayer.backgroundColor = UIColor.clear.cgColor
//        cropLayer.name = "crop"
       // view.layer.mask = cropLayer
        //view.bounds.height/2-view.bounds.width/2
        //view.layer.addSublayer(cropLayer)
        
    }
    
    private func setupTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
//        if sender.state == .ended {
//            capturePhoto()
//        }
//        if let sublayers = view.layer.sublayers {
//
//            for layer in sublayers {
//                if layer.name == "crop" {
//                    let oldPosition = layer.position
//                    layer.position = CGPoint(x: oldPosition.x+20, y: oldPosition.y-20)
//                }
//            }
//        }
        
        let cropPath = CGPath(rect: CGRect(x: view.bounds.width/3, y: view.bounds.height/2-view.bounds.width/3, width: view.bounds.width/3, height: view.bounds.width/3), transform: nil)
        let ma: CAShapeLayer = view.layer.mask as! CAShapeLayer
        ma.path = cropPath
        
        //view.layer.mask?.position = CGPoint(x: oldPosition!.x+40, y: oldPosition!.y-40)
        //view.layer.mask?.frame = view.bounds
    }
    
    private func setupPhotoOutput() {
        capturePhotoOutput = AVCapturePhotoOutput()
        capturePhotoOutput.isHighResolutionCaptureEnabled = true
        captureSession.addOutput(capturePhotoOutput!)
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        if let imageViewController = segue.destination as? ImageViewController {
            imageViewController.image = readyImage
        }
    }
}
extension ViewController : AVCapturePhotoCaptureDelegate {
    private func capturePhoto() {
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.isHighResolutionPhotoEnabled = true
        photoSettings.flashMode = .auto
        capturePhotoOutput?.capturePhoto(with: photoSettings, delegate: self)
    }
    
    func photoOutput(_ output: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photo: AVCapturePhoto,
                     error: Error?) {
        guard error == nil else {
            fatalError("Failed to capture photo: \(String(describing: error))")
        }
        guard let imageData = photo.fileDataRepresentation() else {
            fatalError("Failed to convert pixel buffer")
        }
        guard let image = UIImage(data: imageData) else {
            fatalError("Failed to convert image data to UIImage")
        }
        readyImage = image
        performSegue(withIdentifier: "ShowImageSegue", sender: self)
    }
    
    
}

