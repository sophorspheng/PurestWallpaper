import UIKit
import SnapKit
import CoreData
import CropViewController
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended



class AddWallpaperViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CropViewControllerDelegate, UITextFieldDelegate {
    var loadingIndicator: NVActivityIndicatorView?
    let scrollView = UIScrollView()
    weak var delegate: WallpaperListViewControllerDelegate?
    let contentView = UIView()
    var wallpaper: Wallpaper?
    var nameTextField = UITextField()
    var imageView = UIImageView()
    let addButton = UIButton()
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .gray
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

    override func viewDidLoad() {
        super.viewDidLoad()
//        view.backgroundColor = .systemGray3
        
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
               
               // Register for theme change notifications
               NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
        setupScrollView()
        setupContentView()
        setupViews()
        setupTextField()
    }
    @objc private func applyTheme() {
           view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
           // Update other UI elements if necessary
       }
       
       deinit {
           NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
       }
    private func setupScrollView() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        scrollView.keyboardDismissMode = .onDrag
    }
    
    private func setupContentView() {
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView)
        }
    }
    
    func setupViews() {
        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.safeAreaLayoutGuide).offset(10)
            make.trailing.equalTo(contentView.safeAreaLayoutGuide).offset(-10)
        }

        nameTextField.placeholder = "Wallpaper Name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.layer.borderWidth = 1
        nameTextField.layer.cornerRadius = 5
        nameTextField.textAlignment = .center
        nameTextField.font = .boldSystemFont(ofSize: 20)
        nameTextField.font = UIFont(name: "Arial", size: 20)
        contentView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(closeButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(40)
        }

        imageView.contentMode = .scaleAspectFit
        imageView.isUserInteractionEnabled = true
        imageView.backgroundColor = .lightGray
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(selectImage))
        imageView.addGestureRecognizer(tapGesture)
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(200)
        }

        addButton.setTitle("Save", for: .normal)
        addButton.backgroundColor = .systemGreen
        addButton.layer.cornerRadius = 15
        addButton.addTarget(self, action: #selector(addWallpaper), for: .touchUpInside)
        contentView.addSubview(addButton)
        addButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.bottom.equalTo(contentView.safeAreaLayoutGuide).offset(-20) // Ensure contentView size is adjusted
        }
    }

    private func setupTextField() {
        nameTextField.delegate = self
    }

    @objc private func closeButtonTapped() {
        NotificationCenter.default.post(name: .reloadCollectionView, object: nil)
        self.delegate?.didUploadWallpaper()
          
        dismiss(animated: true)
    }

    @objc func selectImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .photoLibrary
        present(picker, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[.originalImage] as? UIImage {
            let cropViewController = CropViewController(image: image)
            cropViewController.delegate = self
            picker.dismiss(animated: true) {
                self.present(cropViewController, animated: true, completion: nil)
            }
        } else {
            picker.dismiss(animated: true, completion: nil)
        }
    }

    func cropViewController(_ cropViewController: CropViewController, didCropToImage image: UIImage, withRect cropRect: CGRect, angle: Int) {
        imageView.image = image
        cropViewController.dismiss(animated: true, completion: nil)
    }
    func loading(_ start: Bool) {
        if start {
            if loadingIndicator == nil {
                loadingIndicator = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
                loadingIndicator?.translatesAutoresizingMaskIntoConstraints = false
                guard let loadingIndicator = loadingIndicator else { return }
                view.addSubview(loadingIndicator)
                loadingIndicator.snp.makeConstraints { make in
                    make.width.height.equalTo(80)
                    make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
                    make.centerX.equalTo(view.safeAreaLayoutGuide).offset(0)
                }
            }
            loadingIndicator?.startAnimating()
        } else {
            loadingIndicator?.stopAnimating()
            loadingIndicator?.removeFromSuperview()
            loadingIndicator = nil
        }
    }
    @objc private func addWallpaper() {
        // Check if the user is logged in
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            // User is not logged in, show an alert
            let alert = UIAlertController(title: "Login Required", message: "Please log in to upload a wallpaper.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            return
        }

        // Proceed with the upload process if the user is logged in
        guard let name = nameTextField.text, !name.isEmpty,
              let image = imageView.image,
              let imageData = image.jpegData(compressionQuality: 0.7) else {
            let alert = UIAlertController(title: "Error", message: "Please enter a name and select an image.", preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            present(alert, animated: true, completion: nil)
            loading(false) // Stop loading indicator
            return
        }

        // Disable the submit button to prevent multiple submissions
        addButton.isEnabled = false
        loading(true) // Start loading indicator

        // Create the request
        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/upload")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        // Set the authorization header with the token
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        // Set up the multipart form data
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        let uniqueFilename = "image_\(UUID().uuidString).jpg"

        // Append the image data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(uniqueFilename)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: images/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n".data(using: .utf8)!)

        // Append the name data
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        body.append("\(name)\r\n".data(using: .utf8)!)

        // End the body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        request.httpBody = body

        // Debugging: Print the request body to check the format
        if let bodyString = String(data: body, encoding: .utf8) {
            print("Request body: \(bodyString)")
        }

        // Send the request
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                // Re-enable the submit button
                self.addButton.isEnabled = true
                // Stop loading indicator
                self.loading(false)
                
                if let error = error {
                    print("Error: \(error.localizedDescription)")
                    // Show error alert
                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                    return
                }

                if let httpResponse = response as? HTTPURLResponse {
                    if httpResponse.statusCode == 200 {
                        // Successfully submitted
                        let alert = UIAlertController(title: "Success", message: "Wallpaper uploaded successfully.", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
                            // Notify the delegate to refresh the collection view
                            self.delegate?.didUploadWallpaper()
                            
                            // Dismiss the view controller
                            self.dismiss(animated: true, completion: nil)
                        }))
                        self.present(alert, animated: true, completion: nil)
                    } else {
                        // Handle server error
                        let alert = UIAlertController(title: "Error", message: "Failed to submit the form. Status code: \(httpResponse.statusCode)", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                }
            }
        }
        task.resume()
    }


//    @objc private func addWallpaper() {
//        guard let name = nameTextField.text, !name.isEmpty,
//              let image = imageView.image,
//              let imageData = image.jpegData(compressionQuality: 0.7) else {
//            let alert = UIAlertController(title: "Error", message: "Please enter a name and select an image.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//            present(alert, animated: true, completion: nil)
//            loading(false) // Stop loading indicator
//            return
//        }
//
//        // Disable the submit button to prevent multiple submissions
//        addButton.isEnabled = false
//        loading(true) // Start loading indicator
//
//        // Create the request
//        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/upload")!
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//
//        // Set up the multipart form data
//        let boundary = "Boundary-\(UUID().uuidString)"
//        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
//
//        var body = Data()
//        let uniqueFilename = "image_\(UUID().uuidString).jpg"
//
//        // Append the image data
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"images\"; filename=\"\(uniqueFilename)\"\r\n".data(using: .utf8)!)
//        body.append("Content-Type: images/jpeg\r\n\r\n".data(using: .utf8)!)
//        body.append(imageData)
//        body.append("\r\n".data(using: .utf8)!)
//
//        // Append the name data
//        body.append("--\(boundary)\r\n".data(using: .utf8)!)
//        body.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
//        body.append("\(name)\r\n".data(using: .utf8)!)
//
//        // End the body
//        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
//
//        request.httpBody = body
//
//        // Debugging: Print the request body to check the format
//        if let bodyString = String(data: body, encoding: .utf8) {
//            print("Request body: \(bodyString)")
//        }
//
//        // Send the request
//        let task = URLSession.shared.dataTask(with: request) { data, response, error in
//            DispatchQueue.main.async {
//                // Re-enable the submit button
//                self.addButton.isEnabled = true
//                // Stop loading indicator
//                self.loading(false)
//                
//                if let error = error {
//                    print("Error: \(error.localizedDescription)")
//                    // Show error alert
//                    let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
//                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                    self.present(alert, animated: true, completion: nil)
//                    return
//                }
//
//                if let httpResponse = response as? HTTPURLResponse {
//                                    if httpResponse.statusCode == 200 {
//                                        // Successfully submitted
//                                        let alert = UIAlertController(title: "Success", message: "Wallpaper uploaded successfully.", preferredStyle: .alert)
//                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in
//                                            // Notify the delegate to refresh the collection view
//                                            self.delegate?.didUploadWallpaper()
//                                            
//                                            // Dismiss the view controller
//                                            self.dismiss(animated: true, completion: nil)
//                                        }))
//                                        self.present(alert, animated: true, completion: nil)
//                                    } else {
//                                        // Handle server error
//                                        let alert = UIAlertController(title: "Error", message: "Failed to submit the form. Status code: \(httpResponse.statusCode)", preferredStyle: .alert)
//                                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
//                                        self.present(alert, animated: true, completion: nil)
//                                    }
//                                }
//                            }
//                        }
//                        task.resume()
//    }

   

    private func clearForm() {
        nameTextField.text = ""
        imageView.image = nil
    }






    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
