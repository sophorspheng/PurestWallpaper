//
//  ImageCropViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/7/24.
//

import UIKit

class ImageCropViewController: UIViewController {
    var image: UIImage?
    var onCropComplete: ((UIImage) -> Void)?
    
    private let imageView = UIImageView()
    private let cropButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViews()
    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        // Setup image view
        imageView.image = image
        imageView.contentMode = .scaleAspectFit
        view.addSubview(imageView)
        imageView.frame = view.bounds.insetBy(dx: 20, dy: 20)
        
        // Setup crop button
        cropButton.setTitle("Crop & Download", for: .normal)
        cropButton.addTarget(self, action: #selector(cropImage), for: .touchUpInside)
        view.addSubview(cropButton)
        cropButton.frame = CGRect(x: 20, y: view.bounds.height - 60, width: view.bounds.width - 40, height: 40)
        
        // Setup cancel button
        cancelButton.setTitle("Cancel", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancel), for: .touchUpInside)
        view.addSubview(cancelButton)
        cancelButton.frame = CGRect(x: 20, y: view.bounds.height - 110, width: view.bounds.width - 40, height: 40)
    }
    
    @objc private func cropImage() {
        // Implement cropping logic here
        // For simplicity, we'll just return the original image
        guard let image = image else { return }
        onCropComplete?(image)
        dismiss(animated: true, completion: nil)
    }
    
    @objc private func cancel() {
        dismiss(animated: true, completion: nil)
    }
}
