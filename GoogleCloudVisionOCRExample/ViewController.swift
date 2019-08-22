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
        print(view.bounds.width)
        print(view.bounds.height)
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

    }
    
    
    private func setupTapRecognizer() {
        tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        tapRecognizer?.numberOfTapsRequired = 1
        tapRecognizer?.numberOfTouchesRequired = 1
        view.addGestureRecognizer(tapRecognizer!)
    }
    
    @objc func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            capturePhoto()
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

