import UIKit
import SnapKit
import TOCropViewController
import CoreImage
class WallpaperDetailViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,TOCropViewControllerDelegate, ColorEditViewControllerDelegate {
    let customTransitioningDelegate = CustomTransitioningDelegate()
    var imageUrls: [String] = [] // Array to hold image URLs
    private var images: [UIImage] = [] // Array to hold images
    var imageForPresentedVC: UIImage?
    var wallpaper: Wallpaper?
    var formData: FormData?
    var formDataList: [FormData] = []
    var filteredFormDataList: [FormData] = []
    let scrollView = UIScrollView()
    let containerView = UIView()
    var presentedVC: PresentedViewController?
    let contentView = UIView()
    
    
    
    
    var image: UIImage?
    
    var editedImage: UIImage?
    
    let imageView = UIImageView()
    let downloadButton = UIButton()
    let shareButton = UIButton()
    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .red
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemGray5
        } else {
            // Fallback on earlier versions
        }
        button.layer.cornerRadius = 15
        button.backgroundColor = UIColor(white: 0, alpha: 0.7) // Semi-transparent background
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "chevron.backward"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        return button
    }()
    private let optionButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .red
        //        button.backgroundColor = .white
        button.layer.cornerRadius = 5
        button.backgroundColor = UIColor(white: 0, alpha: 0.7) // Semi-transparent background
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "line.horizontal.3"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(optionButtonTapped), for: .touchUpInside)
        return button
    }()
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textAlignment = .center
        return label
    }()
    
    
    private var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .clear
        collectionView.register(WallpaperCell.self, forCellWithReuseIdentifier: "WallpaperCell")
        
        return collectionView
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupScrollView()
        setupBackground()
        setupImageView()
        setupNameLabel()
        setupCloseButton()
        setupDownloadButton()
        setupShareButton()
        setupCollectionView()
        collectionView.dataSource = self
        collectionView.delegate = self
        fetchWallpapers()
        
        
        
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        nameLabel.textColor = ThemeManager.shared.currentTheme == .dark ? .white : .black
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateImageVisibility(_:)), name: .imageVisibilityChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
        
        if let data = formData {
            nameLabel.text = "Wallpaper: \(data.name)"
            if let imageUrl = URL(string: data.image) {
                URLSession.shared.dataTask(with: imageUrl) { [weak self] data, response, error in
                    guard let self = self else { return }
                    if let data = data, let image = UIImage(data: data) {
                        DispatchQueue.main.async {
                            self.imageView.image = image
                            self.updateImageConstraints(for: image)
                        }
                    } else {
                        print("Error loading image: \(error?.localizedDescription ?? "Unknown error")")
                    }
                }.resume()
            }
        }
    }
    
    
    
    private func setupCollectionView() {
        //        view.addSubview(collectionView)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width / 2) - 2.5, height: (view.frame.width / 1) - 2.5) // Adjusted size
        layout.minimumLineSpacing = 5 // Reduced line spacing
        layout.minimumInteritemSpacing = 5 // Reduced inter-item spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WallpaperCell.self, forCellWithReuseIdentifier: "WallpaperCell")
        
        
        //          collectionView.snp.makeConstraints { make in
        //              make.edges.equalToSuperview()
        //          }
        //
        contentView.addSubview(collectionView)
        collectionView.backgroundColor = .red
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.snp.makeConstraints { make in
            make.top.equalTo(downloadButton.snp.bottom).offset(20)
            make.left.equalTo(contentView.snp.left).offset(10)
            make.right.equalTo(contentView.snp.right).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20)
            make.height.equalTo(1000)
        }
    }
    
    @objc private func updateImageVisibility(_ notification: Notification) {
        if let userInfo = notification.userInfo, let publicId = userInfo["publicId"] as? String {
            if wallpaper?.publicId == publicId {
                imageView.isHidden = true
            }
        }
    }
    @objc private func optionButtonTapped() {
        containerView.backgroundColor = .white
        containerView.layer.cornerRadius = 25
        containerView.clipsToBounds = true
        view.addSubview(containerView)
        
        containerView.snp.makeConstraints { make in
            make.bottom.equalToSuperview()
            make.left.right.equalToSuperview()
            make.height.equalToSuperview().dividedBy(3)
        }
        
        presentedVC = PresentedViewController()
        guard let presentedVC = presentedVC else { return }
        presentedVC.parentVC = self
        presentedVC.image = self.imageView.image
        presentedVC.wallpaper = wallpaper // Ensure wallpaper includes the database ID
        
        // Pass the image ID to the presented view controller
        if let imageId = wallpaper?.id {
            presentedVC.imageId = String(imageId)
        }
        
        addChild(presentedVC)
        containerView.addSubview(presentedVC.view)
        presentedVC.view.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        presentedVC.didMove(toParent: self)
        
        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
        UIView.animate(withDuration: 0.3) {
            self.containerView.transform = .identity
        }
    }
    
    
    
    
    //    @objc private func optionButtonTapped() {
    //        containerView.backgroundColor = .white
    //        containerView.layer.cornerRadius = 25
    //        containerView.clipsToBounds = true
    //        view.addSubview(containerView)
    //
    //        containerView.snp.makeConstraints { make in
    //            make.bottom.equalToSuperview()
    //            make.left.right.equalToSuperview()
    //            make.height.equalToSuperview().dividedBy(3)
    //        }
    //
    //        presentedVC = PresentedViewController()
    //        guard let presentedVC = presentedVC else { return }
    //        presentedVC.parentVC = self
    //        presentedVC.image = self.imageView.image
    //        presentedVC.wallpaper = wallpaper // Ensure wallpaper includes the database ID
    //
    //
    //
    //        addChild(presentedVC)
    //        containerView.addSubview(presentedVC.view)
    //        presentedVC.view.snp.makeConstraints { make in
    //            make.edges.equalToSuperview()
    //        }
    //        presentedVC.didMove(toParent: self)
    //
    //        containerView.transform = CGAffineTransform(translationX: 0, y: containerView.frame.height)
    //        UIView.animate(withDuration: 0.3) {
    //            self.containerView.transform = .identity
    //        }
    //    }
    
    func dismissPresentedViewController() {
        guard let presentedVC = presentedVC else { return }
        UIView.animate(withDuration: 0.3, animations: {
            self.containerView.transform = CGAffineTransform(translationX: 0, y: self.containerView.frame.height)
        }) { _ in
            presentedVC.willMove(toParent: nil)
            presentedVC.view.removeFromSuperview()
            presentedVC.removeFromParent()
            self.containerView.removeFromSuperview()
        }
    }
    
    @objc private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        nameLabel.textColor = ThemeManager.shared.currentTheme == .dark ? .blue : .black
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .imageVisibilityChanged, object: nil)
    }
    
    private func setupScrollView() {
        
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top)
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
        
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
            
        }
        
    }
    
    private func setupBackground() {
        // Add any background setup if needed
    }
    
    private func setupImageView() {
        contentView.addSubview(imageView)
        imageView.contentMode = .scaleAspectFit
        imageView.layer.cornerRadius = 10
        imageView.clipsToBounds = true
        imageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(50)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.lessThanOrEqualTo(contentView).multipliedBy(0.6)
        }
    }
    
    private func setupNameLabel() {
        contentView.addSubview(nameLabel)
        nameLabel.font   =  UIFont.boldSystemFont(ofSize: 20)
        nameLabel.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalToSuperview().offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.height.equalTo(30)
        }
    }
    
    private func setupCloseButton() {
        view.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.width.height.equalTo(30)
        }
        view.addSubview(optionButton)
        optionButton.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-20)
            make.width.height.equalTo(30)
        }
    }
    
    private func setupDownloadButton() {
        contentView.addSubview(downloadButton)
        //          downloadButton.setImage(UIImage(systemName: "arrow.down.circle.fill"), for: .normal)
        downloadButton.setTitle("Download", for: .normal)
        downloadButton.backgroundColor = .systemBlue
        downloadButton.tintColor = .white
        downloadButton.layer.cornerRadius = 25
        downloadButton.addTarget(self, action: #selector(downloadWallpaper), for: .touchUpInside)
        downloadButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-20)
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
    }
    
    private func setupShareButton() {
        contentView.addSubview(shareButton)
        //           shareButton.setImage(UIImage(systemName: "square.and.arrow.up"), for: .normal)
        shareButton.setTitle("Share", for: .normal)
        shareButton.backgroundColor = .systemGreen
        shareButton.layer.cornerRadius = 25
        shareButton.addTarget(self, action: #selector(shareWallpaper), for: .touchUpInside)
        shareButton.snp.makeConstraints { make in
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(20)
            make.height.equalTo(50)
            make.width.equalTo(120)
        }
    }
    
    private func updateImageConstraints(for image: UIImage) {
        let aspectRatio = image.size.width / image.size.height
        imageView.snp.remakeConstraints { make in
            make.top.equalTo(contentView).offset(20)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.equalTo(imageView.snp.width).dividedBy(aspectRatio)
        }
    }
    func fetchWallpapers() {
        // Check if the user is logged in by verifying the existence of the token
        guard let token = UserDefaults.standard.string(forKey: "authToken") else {
            print("User is not logged in")
            return
        }

        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/data")!
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")

        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                print("Error: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
            do {
                let formDataList = try JSONDecoder().decode([FormData].self, from: data)
                DispatchQueue.main.async {
                    self?.formDataList = formDataList
                    self?.collectionView.reloadData()
                    print("Fetched data: \(formDataList)")
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
            }
        }
        task.resume()
    }

//    func fetchWallpapers() {
//        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/data")!
//        let task = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
//            guard let data = data, error == nil else {
//                print("Error: \(error?.localizedDescription ?? "Unknown error")")
//                return
//            }
//            do {
//                let formDataList = try JSONDecoder().decode([FormData].self, from: data)
//                DispatchQueue.main.async {
//                    self?.formDataList = formDataList
//                    self?.collectionView.reloadData()
//                    print("Fetched data: \(formDataList)")
//                }
//            } catch {
//                print("Error decoding JSON: \(error.localizedDescription)")
//            }
//        }
//        task.resume()
//    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return formDataList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath)
        cell.backgroundColor = .blue // Temporary color to debug
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let data = formDataList[indexPath.item]
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        cell.contentView.addSubview(imageView)
        
        imageView.snp.makeConstraints { make in
            make.edges.equalTo(cell.contentView)
        }
        
        if let imageUrl = URL(string: data.image) {
            URLSession.shared.dataTask(with: imageUrl) { data, response, error in
                if let error = error {
                    print("Error loading image: \(error.localizedDescription)")
                    DispatchQueue.main.async {
                        if #available(iOS 13.0, *) {
                            imageView.image = UIImage(systemName: "photo")
                        } else {
                            // Fallback on earlier versions
                        } // Placeholder image
                    }
                    return
                }
                
                guard let data = data, let image = UIImage(data: data) else {
                    print("Error: Data or image conversion failed")
                    DispatchQueue.main.async {
                        if #available(iOS 13.0, *) {
                            imageView.image = UIImage(systemName: "photo")
                        } else {
                            // Fallback on earlier versions
                        } // Placeholder image
                    }
                    return
                }
                
                DispatchQueue.main.async {
                    imageView.image = image
                }
            }.resume()
        } else {
            print("Invalid URL: \(data.image)")
            DispatchQueue.main.async {
                if #available(iOS 13.0, *) {
                    imageView.image = UIImage(systemName: "photo")
                } else {
                    // Fallback on earlier versions
                } // Placeholder image
            }
        }
        
        return cell
    }
    
    
    
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedData =  formDataList[indexPath.item]
        let detailVC = WallpaperDetailViewController()
        detailVC.formData = selectedData
        detailVC.modalPresentationStyle = .fullScreen
        detailVC.reloadInputViews()
        detailVC.imageUrls = imageUrls
        present(detailVC, animated: true)
        
        
    }
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountFor section: Int) -> Int {
        return 1
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 5) / 2 // Adjust spacing as needed
        let height = (collectionView.frame.height - 100) / 2 // Adjust spacing as needed
        return CGSize(width: width, height: height) // Square cells for example
    }
    
    @objc private func closeButtonTapped() {
        let presentWallist = WallpaperListViewController()
        presentWallist.modalPresentationStyle = .custom
        presentWallist.transitioningDelegate = customTransitioningDelegate
        self.present(presentWallist, animated: true, completion: nil)
    }
    
    @objc func downloadWallpaper() {
        guard let image = imageView.image else {
            print("No image to download")
            return
        }
        
        print("Image size: \(image.size)")
        
        // Present the alert on the main thread
        DispatchQueue.main.async {
            let alertController = UIAlertController(
                title: "Download Wallpaper",
                message: "Would you like to crop and adjust the color of the image before downloading?",
                preferredStyle: .alert
            )
            
            alertController.addAction(UIAlertAction(title: "Crop & Edit", style: .default) { _ in
                let cropViewController = TOCropViewController(image: image)
                cropViewController.delegate = self
                self.present(cropViewController, animated: true, completion: nil)
            })
            
            alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    
    // TOCropViewControllerDelegate methods
    func cropViewController(_ cropViewController: TOCropViewController, didCropTo image: UIImage, with cropRect: CGRect, angle: Int) {
        cropViewController.dismiss(animated: false, completion: {
            self.presentColorEditingViewController(with: image)
        })
    }
    
    // Present the color editing view controller
    private func presentColorEditingViewController(with image: UIImage) {
        let colorEditVC = ColorEditViewController()
        colorEditVC.image = image
        colorEditVC.delegate = self
        self.present(colorEditVC, animated: true, completion: nil)
    }
    
    // Method to handle the color-edited image
    func didFinishEditingImage(_ image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    
    private func presentDownloadConfirmation() {
        let alert = UIAlertController(title: "Download", message: "Do you want to download the edited image?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Download", style: .default, handler: { [weak self] _ in
            self?.downloadImage()
        }))
        present(alert, animated: true, completion: nil)
    }
    private func downloadImage() {
        guard let imageToDownload = editedImage else {
            print("No image to download")
            return
        }
        
        UIImageWriteToSavedPhotosAlbum(imageToDownload, self, #selector(image(_:didFinishSavingWithError:contextInfo:)), nil)
    }
    
    @objc private func image(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if let error = error {
            // Handle error
            print("Error saving image: \(error.localizedDescription)")
        } else {
            // Notify success
            print("Image successfully saved!")
        }
    }
    
    
    @objc func shareWallpaper() {
        guard let image = imageView.image else {
            print("No image to share")
            return
        }
        
        let activityVC = UIActivityViewController(activityItems: [image], applicationActivities: nil)
        present(activityVC, animated: true, completion: nil)
    }
    
    // MARK: - UICollectionViewDataSource
    
    
    
}


extension WallpaperDetailViewController {
    func colorEditViewController(_ controller: ColorEditViewController, didEditImage image: UIImage) {
        // Store the edited image
        self.editedImage = image
    }
    
    func colorEditViewControllerDidFinishEditing(_ controller: ColorEditViewController) {
        // Show download confirmation
        presentDownloadConfirmation()
    }
}
