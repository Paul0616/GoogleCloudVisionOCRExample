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
    @IBOutlet weak var topLeftDot: UIView!
    @IBOutlet weak var topRightCircle: UIView!
    @IBOutlet weak var topRightDot: UIView!
    @IBOutlet weak var bottomLeftCircle: UIView!
    @IBOutlet weak var bottomLeftDot: UIView!
    @IBOutlet weak var bottomRightCircle: UIView!
    @IBOutlet weak var bottomRightDot: UIView!
    var captureSession: AVCaptureSession!
    var videoPreviewLayer: AVCaptureVideoPreviewLayer!
    var tapRecognizer: UITapGestureRecognizer! // NEW
    var capturePhotoOutput: AVCapturePhotoOutput!
    var readyImage: UIImage!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupTapRecognizer()
        setupPhotoOutput()
        
        let initialRect = CGRect(x: view.bounds.width/4, y: view.bounds.height/2-view.bounds.width/4, width: view.bounds.width/2, height: view.bounds.width/2)
        
        let cropPath = CGPath(rect: initialRect, transform: nil)
        let shape = CAShapeLayer()
        shape.lineWidth = 1
        shape.strokeColor = UIColor.white.cgColor
        shape.fillColor = UIColor.clear.cgColor
        shape.path = cropPath
        shape.name = "cropPath"
        view.layer.addSublayer(shape)
        
        topLeftDot.layer.cornerRadius = 5
        topLeftCircle.tag = 51
        topLeftCircle.translatesAutoresizingMaskIntoConstraints = false
        topLeftCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: initialRect.minX - topLeftCircle.frame.width/2).isActive = true
        topLeftCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: initialRect.minY - topLeftCircle.frame.height/2).isActive = true
        addPanGesture(view: topLeftCircle)
        view.bringSubviewToFront(topLeftCircle)
        
        topRightDot.layer.cornerRadius = 5
        topRightCircle.tag = 52
        topRightCircle.translatesAutoresizingMaskIntoConstraints = false
        topRightCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: initialRect.maxX - topRightCircle.frame.width/2).isActive = true
        topRightCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: initialRect.minY - topRightCircle.frame.height/2).isActive = true
        addPanGesture(view: topRightCircle)
        view.bringSubviewToFront(topRightCircle)
        
        bottomLeftDot.layer.cornerRadius = 5
        bottomLeftCircle.tag = 53
        bottomLeftCircle.translatesAutoresizingMaskIntoConstraints = false
        bottomLeftCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: initialRect.minX - bottomLeftCircle.frame.width/2).isActive = true
        bottomLeftCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: initialRect.maxY - bottomLeftCircle.frame.height/2).isActive = true
        addPanGesture(view: bottomLeftCircle)
        view.bringSubviewToFront(bottomLeftCircle)
        
        bottomRightDot.layer.cornerRadius = 5
        bottomRightCircle.tag = 54
        bottomRightCircle.translatesAutoresizingMaskIntoConstraints = false
        bottomRightCircle.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: initialRect.maxX - bottomRightCircle.frame.width/2).isActive = true
        bottomRightCircle.topAnchor.constraint(equalTo: view.topAnchor, constant: initialRect.maxY - bottomRightCircle.frame.height/2).isActive = true
        addPanGesture(view: bottomRightCircle)
        view.bringSubviewToFront(bottomRightCircle)
        
        
        
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
        videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        videoPreviewLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        videoPreviewLayer.frame = view.layer.bounds
        view.layer.addSublayer(videoPreviewLayer)
        
        
        let cropPath = CGPath(rect: CGRect(x: view.bounds.width/4, y: view.bounds.height/2-view.bounds.width/4, width: view.bounds.width/2, height: view.bounds.width/2), transform: nil)
        let maskLayer = CAShapeLayer()
        maskLayer.frame = view.bounds
        maskLayer.backgroundColor = UIColor(red: 0.3, green: 0.3, blue: 0.3, alpha: 0.5).cgColor
        maskLayer.path = cropPath
        videoPreviewLayer.mask = maskLayer

        
    }
    
    func addPanGesture(view: UIView){
        let pan = UIPanGestureRecognizer(target: self, action: #selector(handlePan(sender:)))
        view.addGestureRecognizer(pan)
    }
    private func setupTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handlePan(sender: UIPanGestureRecognizer){
        let node = sender.view!
        switch sender.state {
        case .began, .changed:
            moveViewWithPan(view: node, sender: sender)
        default:
            break
        }
    }
    
    func moveViewWithPan(view: UIView, sender: UIPanGestureRecognizer){
        let translation = sender.translation(in: view)
        view.center = CGPoint(x: view.center.x + translation.x, y: view.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: view)
        
        
        switch view.tag {
        case 51:
            topRightCircle.center = CGPoint(x: topRightCircle.center.x, y: view.center.y + translation.y)
            bottomLeftCircle.center = CGPoint(x: view.center.x + translation.x, y: bottomLeftCircle.center.y)
        case 52:
            topLeftCircle.center = CGPoint(x: topLeftCircle.center.x, y: view.center.y + translation.y)
            bottomRightCircle.center = CGPoint(x: view.center.x + translation.x, y: bottomRightCircle.center.y)
        case 53:
            bottomRightCircle.center = CGPoint(x: bottomRightCircle.center.x, y: view.center.y + translation.y)
            topLeftCircle.center = CGPoint(x: view.center.x + translation.x, y: topLeftCircle.center.y)
        case 54:
            bottomLeftCircle.center = CGPoint(x: bottomLeftCircle.center.x, y: view.center.y + translation.y)
            topRightCircle.center = CGPoint(x: view.center.x + translation.x, y: topRightCircle.center.y)
        default:
            break
        }
       let croppingRect = CGRect(x: topLeftCircle.center.x, y: topLeftCircle.center.y, width: topRightCircle.center.x - bottomLeftCircle.center.x, height: bottomLeftCircle.center.y - topLeftCircle.center.y)
       let cropPath = CGPath(rect: croppingRect, transform: nil)
        if let sublayers = self.view.layer.sublayers {
            for layer in sublayers {
                if layer.name == "cropPath" {
                    let shape = layer as! CAShapeLayer
                    shape.path = cropPath
                }
            }
        }
        
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            //capturePhoto()
        }
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

