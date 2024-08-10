import UIKit
import SnapKit


class PresentedViewController: UIViewController, UIViewControllerTransitioningDelegate {
    
    
    weak var parentVC: WallpaperDetailViewController?
       var image: UIImage?
       var imageId: String? // Add this property

    
    
    
    
    var wallpaper: Wallpaper?
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        return imageView
    }()
    
    private let labelOptionText: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.text = "Options"
        return label
    }()
    
    private let reportText: UITextField = {
        let button = UITextField()
        button.borderStyle =  .roundedRect
        button.textAlignment = .center
        button.layer.cornerRadius = 8
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Close", for: .normal)
        button.setTitleColor(.red, for: .normal)
        button.backgroundColor = .white
        button.layer.cornerRadius = 15
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    private let downloadButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Download", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    private let sendButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Send>", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.backgroundColor = .blue
        button.layer.cornerRadius = 12
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray2
        } else {
            // Fallback on earlier versions
        }
        setupScrollView()
        setupImageView()
        setupLabelOptionText()
        setupHideButton()
        setupDownloadButton()
        setupCloseButton()
        setupreportbutton()
        
        // Set the custom transition delegate
        transitioningDelegate = self
        modalPresentationStyle = .custom
        
        // Set the target actions for buttons
        downloadButton.addTarget(self, action: #selector(downloadTapped), for: .touchUpInside)
        
        // Set the image if available
        if let image = image {
            imageView.image = image
        }
        // Handle the imageId similarly
               if let imageId = imageId {
                   // Use imageId as needed in your view controller
                   print("Received imageId: \(imageId)")
               }
        
    }
    
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView) // Ensure contentView's width matches scrollView's width
        }
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(200) // Set a fixed height or adjust as needed
        }
    }
    
    private func setupLabelOptionText() {
        contentView.addSubview(labelOptionText)
        labelOptionText.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
        }
    }
    
    private func setupHideButton() {
        contentView.addSubview(reportText)
        reportText.snp.makeConstraints { make in
            make.top.equalTo(labelOptionText.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-80)
            make.height.equalTo(40)
            
        }
    }
    private func setupreportbutton(){
        contentView.addSubview(sendButton)
        sendButton.addTarget(self, action: #selector(sendReport), for: .touchUpInside)
        sendButton.snp.makeConstraints { make in
            make.top.equalTo(labelOptionText.snp.bottom).offset(10)
            make.leading.equalTo(reportText.snp.trailing).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
            make.height.equalTo(40)
        }
    }
    
    private func setupDownloadButton() {
        contentView.addSubview(downloadButton)
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(reportText.snp.bottom).offset(10)
            make.leading.equalTo(contentView).offset(20)
        }
    }
    
    private func setupCloseButton() {
        contentView.addSubview(closeButton)
        closeButton.addTarget(self, action: #selector(dismissSelf), for: .touchUpInside)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(downloadButton.snp.bottom).offset(20)
            make.centerX.equalTo(contentView)
            make.height.equalTo(40)
            make.width.equalTo(70)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
    
    @objc private func sendReport() {
        guard let imageId = wallpaper?.id, let reportText = reportText.text, !reportText.isEmpty else {
            print("No report text entered or no image ID")
            DispatchQueue.main.async {
                self.presentErrorAlert(message: "Please enter report text and ensure image ID is available.")
            }
            return
        }

        let url = URL(string: "https://nodeapi-backend.vercel.app/api/users/reports")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["imageId": imageId, "reportText": reportText]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error reporting image: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self.presentErrorAlert(message: "Failed to report the image. Please try again.")
                }
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 201 else {
                print("Unexpected response: \(String(describing: response))")
                DispatchQueue.main.async {
                    self.presentErrorAlert(message: "Unexpected server response.")
                }
                return
            }

            DispatchQueue.main.async {
                let ac = UIAlertController(
                    title: "Reported!",
                    message: "The image has been successfully reported.",
                    preferredStyle: .alert
                )
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
            }
        }
        task.resume()
    }



    // Helper method to present error alerts
    private func presentErrorAlert(message: String) {
        let ac = UIAlertController(
            title: "Error",
            message: message,
            preferredStyle: .alert
        )
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        self.present(ac, animated: true)
    }


  

    @objc private func hideTapped() {
        guard let wallpaper = wallpaper else {
            print("No wallpaper data available")
            return
        }
        deleteImageFromServer(publicId: wallpaper.publicId)
    }
    
    private func deleteImageFromServer(publicId: String) {
        guard let url = URL(string: "https://nodeapi-backend.vercel.app/delete/\(publicId)") else {
            print("Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error deleting image: \(error.localizedDescription)")
                return
            }

            guard let response = response as? HTTPURLResponse, response.statusCode == 200 else {
                print("Unexpected response")
                return
            }

            DispatchQueue.main.async {
                let ac = UIAlertController(
                    title: "Deleted!",
                    message: "The image has been successfully deleted.",
                    preferredStyle: .alert
                )
                ac.addAction(UIAlertAction(title: "OK", style: .default))
                self.present(ac, animated: true)
                self.dismiss(animated: true, completion: nil)
            }
        }
        task.resume()
    }
    
    @objc private func downloadTapped() {
        guard let image = self.image else {
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
    
    @objc private func dismissSelf() {
        print("Dismiss self called in PresentedViewController")
        parentVC?.dismissPresentedViewController()
    }


    @objc func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        let ac = UIAlertController(title: error == nil ? "Saved!" : "Save error",
                                   message: error?.localizedDescription ?? "Your wallpaper has been saved to your photos.",
                                   preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}

extension Notification.Name {
    static let imageVisibilityChanged = Notification.Name("imageVisibilityChanged")
}
