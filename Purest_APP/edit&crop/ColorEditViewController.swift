//
//  ColorEditViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/7/24.
//

import UIKit
import CoreImage

protocol ColorEditViewControllerDelegate: AnyObject {
    func colorEditViewController(_ controller: ColorEditViewController, didEditImage image: UIImage)
    func colorEditViewControllerDidFinishEditing(_ controller: ColorEditViewController)
}

class ColorEditViewController: UIViewController {

    var image: UIImage?
    weak var delegate: ColorEditViewControllerDelegate?

    private var context = CIContext()
    private var originalImage: UIImage?

    private let imageView = UIImageView()
    private let brightnessSlider = UISlider()
    private let contrastSlider = UISlider()
    private let applyButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupImage()
    }

    private func setupUI() {
        view.backgroundColor = .white
        view.addSubview(imageView)
        view.addSubview(brightnessSlider)
        view.addSubview(contrastSlider)
        view.addSubview(applyButton)

        imageView.contentMode = .scaleAspectFit
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.left.right.equalToSuperview().inset(20)
            make.height.equalTo(view.frame.height * 0.5)
        }

        brightnessSlider.minimumValue = -1
        brightnessSlider.maximumValue = 1
        brightnessSlider.value = 0
        brightnessSlider.addTarget(self, action: #selector(adjustImage), for: .valueChanged)
        brightnessSlider.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        contrastSlider.minimumValue = 0.5
        contrastSlider.maximumValue = 1.5
        contrastSlider.value = 1
        contrastSlider.addTarget(self, action: #selector(adjustImage), for: .valueChanged)
        contrastSlider.snp.makeConstraints { make in
            make.top.equalTo(brightnessSlider.snp.bottom).offset(20)
            make.left.right.equalToSuperview().inset(20)
        }

        applyButton.setTitle("Apply", for: .normal)
        applyButton.backgroundColor = .systemBlue
        applyButton.tintColor = .white
        applyButton.layer.cornerRadius = 5
        applyButton.addTarget(self, action: #selector(applyChanges), for: .touchUpInside)
        applyButton.snp.makeConstraints { make in
            make.top.equalTo(contrastSlider.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(44)
            make.width.equalTo(100)
        }
    }

    private func setupImage() {
        if let image = image {
            imageView.image = image
            originalImage = image
        }
    }

    @objc private func adjustImage() {
        guard let image = image else { return }

        let ciImage = CIImage(image: image)
        let colorControlsFilter = CIFilter(name: "CIColorControls")!
        colorControlsFilter.setValue(ciImage, forKey: kCIInputImageKey)
        colorControlsFilter.setValue(brightnessSlider.value, forKey: kCIInputBrightnessKey)
        colorControlsFilter.setValue(contrastSlider.value, forKey: kCIInputContrastKey)

        if let outputImage = colorControlsFilter.outputImage {
            let cgImage = context.createCGImage(outputImage, from: outputImage.extent)
            imageView.image = UIImage(cgImage: cgImage!)
        }
    }
    @objc private func applyChanges() {
        guard let image = imageView.image else { return }

        // Show initial alert
        let alertController = UIAlertController(title: "Message", message: "Do you want to download?", preferredStyle: .alert)

        let applyAction = UIAlertAction(title: "Apply", style: .default) { _ in
            self.delegate?.colorEditViewController(self, didEditImage: image)
            self.delegate?.colorEditViewControllerDidFinishEditing(self)

            // Save the image to Photos
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
            
           
        }
//        self.dismiss(animated: true, completion: nil)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)

        alertController.addAction(applyAction)
        alertController.addAction(cancelAction)

        present(alertController, animated: true, completion: nil)
    }


    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let message: String
        if let error = error {
            message = "Error saving photo: \(error.localizedDescription)"
        } else {
            message = "Photo saved successfully!"
        }

        // Show confirmation alert with animation
        let confirmationAlert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        confirmationAlert.addAction(okAction)

        // Animate the presentation of the alert
        present(confirmationAlert, animated: true) {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                self.dismiss(animated: true, completion: nil)
            }
        }
    }



}
