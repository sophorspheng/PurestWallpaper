//
//  DownloadViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/4/24.
//

import UIKit
import SnapKit

class DownloadViewController: UIViewController {

    let imageView = UIImageView()
    let downloadButton = UIButton()
    var image: UIImage?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupImageView()
        setupDownloadButton()
        view.backgroundColor = .white
        
        if let image = image {
            imageView.image = image
            updateImageConstraints(for: image)
        }
    }

    private func setupImageView() {
        view.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.lessThanOrEqualTo(view).multipliedBy(0.6)
        }
    }

    private func setupDownloadButton() {
        view.addSubview(downloadButton)
        if #available(iOS 13.0, *) {
            downloadButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        downloadButton.backgroundColor = .systemBlue
        downloadButton.tintColor = .white
        downloadButton.layer.cornerRadius = 25
        downloadButton.addTarget(self, action: #selector(downloadWallpaper), for: .touchUpInside)
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalTo(80)
        }
    }

    private func updateImageConstraints(for image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        imageView.snp.remakeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(imageView.snp.width).dividedBy(aspectRatio)
        }
    }

    @objc func downloadWallpaper() {
        guard let image = imageView.image else {
            print("No image to download")
            return
        }

        let alertController = UIAlertController(
            title: "Download Wallpaper",
            message: "Are you sure you want to download this wallpaper?",
            preferredStyle: .alert
        )
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alertController.addAction(UIAlertAction(title: "Download", style: .destructive) { _ in
            UIImageWriteToSavedPhotosAlbum(image, self, #selector(self.image(_:didFinishSavingWithError:contextInfo:)), nil)
        })
        present(alertController, animated: true, completion: nil)
    }

    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let ac = UIAlertController(title: error == nil ? "Saved!" : "Save error",
                                   message: error?.localizedDescription ?? "Your wallpaper has been saved to your photos.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
