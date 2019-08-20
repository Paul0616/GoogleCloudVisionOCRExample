//
//  ImageViewController.swift
//  GoogleCloudVisionOCRExample
//
//  Created by Paul Oprea on 20/08/2019.
//  Copyright © 2019 Paul Oprea. All rights reserved.
//

import UIKit

class ImageViewController: UIViewController {

    var image: UIImage!
    var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let resizedImage = resize(image: image, to: view.frame.size) else {
            fatalError("Error resizing image")
        }
        let imageView = UIImageView(frame: view.frame)
        imageView.image = image
        view.addSubview(imageView)
        setupCloseButton()
        setupActivityIndicator()
        
        detectBoundingBoxes(for: resizedImage)
    }
    

    private func resize(image: UIImage, to targetSize: CGSize) -> UIImage? {
        let size = image.size
        
        let widthRatio  = targetSize.width  / size.width
        let heightRatio = targetSize.height / size.height
        
        // Figure out what our orientation is, and use that to form the rectangle.
        var newSize: CGSize
        if(widthRatio > heightRatio) {
            newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
        } else {
            newSize = CGSize(width: size.width * widthRatio,  height: size.height * widthRatio)
        }
        
        let rect = CGRect(x: 0, y: 0, width: newSize.width, height: newSize.height + 1)
        
        UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
        image.draw(in: rect)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return newImage
    }
    
    private func detectBoundingBoxes(for image: UIImage) {
        GoogleCloudOCR().detect(from: image) { ocrResult in
            self.activityIndicator.stopAnimating()
            guard let ocrResult = ocrResult else {
                fatalError("Did not recognize any text in this image")
            }
            print("Found \(ocrResult.annotations.count) bounding box annotations in the image!")
        }
    }
    
    private func setupActivityIndicator() {
        activityIndicator = UIActivityIndicatorView(style: .whiteLarge)
        view.addSubview(activityIndicator)
        activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        activityIndicator.startAnimating()
    }
    
    private func setupCloseButton() {
        let closeButton = UIButton()
        view.addSubview(closeButton)
        
        // Stylistic features.
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(UIColor.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 32)
        
        // Add a target function when the button is tapped.
        closeButton.addTarget(self, action: #selector(closeAction), for: .touchDown)
        
        // Constrain the button to be positioned in the top left corner (with some offset).
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        closeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        closeButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
    }
    
    @objc private func closeAction() {
        dismiss(animated: false, completion: nil)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
