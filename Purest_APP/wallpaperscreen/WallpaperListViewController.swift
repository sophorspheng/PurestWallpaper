import UIKit
import SnapKit
import CoreData
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
import CHTCollectionViewWaterfallLayout
struct FormData: Codable {
    let id: Int
    let name: String
    let image: String // Assuming the image URL is a string
}

protocol WallpaperListViewControllerDelegate: AnyObject {
    func didUploadWallpaper()
}

class WallpaperListViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UICollectionViewDelegate,UISearchBarDelegate {
    
    var collectionView: UICollectionView!
    var wallpapers: [Wallpapers] = []
    private var isFetching = false
    private let refreshControl = UIRefreshControl()
    var currentPage = 0
    let itemsPerPage = 4 // Number of items to fetch per page
    var imageUrls: [String] = []
    private let searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Search Wallpapers"
        //        searchBar.barTintColor = .white
        
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.textColor = .black
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            searchBar.searchTextField.backgroundColor = .red
        } else {
            // Fallback on earlier versions
        }
        searchBar.isHidden = true
        return searchBar
    }()
    
    var formDataList: [FormData] = []
    var filteredFormDataList: [FormData] = []
    var isSearching = false
    
    //    private var formDataList: [FormData] = []
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    
    private let homeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        //        button.backgroundColor = UIColor(white: 0, alpha: 0.7) // Semi-transparent background
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "house"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttontouchDown), for: .touchDown)
        return button
    }()
    
    private let closesearchButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.isHidden = true
        button.addTarget(self, action: #selector(closesearchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        //        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "magnifyingglass.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let commentButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        //        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "arrow.clockwise"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(homeButtonTapped), for: .touchUpInside)
        button.addTarget(self, action: #selector(buttontouchDown), for: .touchDown)
        return button
    }()
    
    private let userButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        //        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 4
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "person"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(usersButton), for: .touchUpInside)
        return button
    }()
    
    private let addButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .white
        button.backgroundColor = UIColor(white: 0, alpha: 0.7)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 40
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowOpacity = 0.5
        button.layer.shadowRadius = 6
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "plus.circle"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.setTitleShadowColor(.white, for: .normal)
        button.layer.bounds = .zero
        button.addTarget(self, action: #selector(addButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let Bar: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 15
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemGray3
        } else {
            // Fallback on earlier versions
        }
        return button
    }()
    
    var filteredWallpapers: [Wallpapers] = []
    //    var isSearching = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Wallpapers"
        
        //        view.backgroundColor = .black
        setupCollectionView()
        setupUI()
        setupUI2()
        fetchWallpapers()
        
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .blue : .red
        collectionView.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
        collectionView.refreshControl = refreshControl
        // Register for theme change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
        self.collectionView.reloadData()
        // Add observer
        NotificationCenter.default.addObserver(self, selector: #selector(handleWallpaperAdded), name: NSNotification.Name("WallpaperAdded"), object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(reloadCollectionView), name: .reloadCollectionView, object: nil)
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(handleLongPress))
        collectionView.addGestureRecognizer(longPressRecognizer)
        
        // Add long-press gesture recognizer
        searchBar.delegate = self
        
        
    }
    func didUploadWallpaper() {
        // Refresh the collection view or data source
        fetchWallpapers() // or however you refresh your data
    }
    
    @objc private func refreshData() {
        fetchWallpapers()
    }
    
    @objc func reloadCollectionView() {
        collectionView.reloadData()
    }
    @objc func handleLongPress(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            let point = gesture.location(in: collectionView)
            if let indexPath = collectionView.indexPathForItem(at: point) {
                let selectedWallpaper = formDataList[indexPath.item]
                let alert = UIAlertController(title: "Delete Wallpaper", message: "Are you sure you want to delete this wallpaper?", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
                alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { _ in
                    self.deleteWallpaper(at: indexPath, wallpaperId: selectedWallpaper.id)
                }))
                present(alert, animated: true, completion: nil)
            }
        }
    }
    func deleteWallpaper(at indexPath: IndexPath, wallpaperId: Int) {
        guard let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/delete/\(wallpaperId)") else {
            print("Invalid URL")
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        
        // Add the JWT token to the Authorization header
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        } else {
            print("No auth token found")
            return
        }
        
        let task = URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error deleting wallpaper: \(error.localizedDescription)")
                return
            }
            
            if let httpResponse = response as? HTTPURLResponse {
                DispatchQueue.main.async {
                    if httpResponse.statusCode == 403 {
                        // Show alert if user is not an admin
                        let alert = UIAlertController(title: "Unauthorized", message: "You can't delete this image", preferredStyle: .alert)
                        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(alert, animated: true, completion: nil)
                    } else if httpResponse.statusCode == 200 {
                        // Remove from local data source and update UI if deletion was successful
                        self?.formDataList.remove(at: indexPath.item)
                        self?.collectionView.deleteItems(at: [indexPath])
                        
                        // Show success alert if user is an admin
                        let successAlert = UIAlertController(title: "Success", message: "You have been deleted successfully", preferredStyle: .alert)
                        successAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                        self?.present(successAlert, animated: true, completion: nil)
                    } else {
                        print("Unexpected status code: \(httpResponse.statusCode)")
                    }
                }
            }
        }
        task.resume()
    }
    
    
    
    
    @objc private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        collectionView.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
    }
    
    
    func setupUI2() {
        view.addSubview(searchBar)
        searchBar.returnKeyType = .default
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(0)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(0)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-0)
            make.height.equalTo(50)
        }
    }
    
    func setupUI() {
        view.addSubview(Bar)
        Bar.translatesAutoresizingMaskIntoConstraints = false
        Bar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide.snp.bottom).offset(-40)
            make.leading.equalTo(view.safeAreaLayoutGuide).offset(35)
            make.trailing.equalTo(view.safeAreaLayoutGuide).offset(-35)
            make.height.equalTo(50)
        }
        
        view.addSubview(addButton)
        addButton.translatesAutoresizingMaskIntoConstraints = false
        addButton.snp.makeConstraints { make in
            make.top.equalTo(Bar.snp.bottom).offset(-40)
            make.centerX.equalTo(Bar)
        }
        
        Bar.addSubview(searchButton)
        searchButton.translatesAutoresizingMaskIntoConstraints = false
        searchButton.snp.makeConstraints { make in
            make.top.equalTo(Bar.snp.bottom).offset(-40)
            make.trailing.equalTo(addButton).offset(-60)
        }
        
        Bar.addSubview(homeButton)
        homeButton.translatesAutoresizingMaskIntoConstraints = false
        homeButton.snp.makeConstraints { make in
            make.top.equalTo(Bar.snp.bottom).offset(-40)
            make.leading.equalTo(searchButton).offset(-60)
        }
        
        Bar.addSubview(commentButton)
        commentButton.translatesAutoresizingMaskIntoConstraints = false
        commentButton.snp.makeConstraints { make in
            make.top.equalTo(Bar.snp.bottom).offset(-40)
            make.trailing.equalTo(addButton).offset(60)
        }
        
        Bar.addSubview(userButton)
        userButton.translatesAutoresizingMaskIntoConstraints = false
        userButton.snp.makeConstraints { make in
            make.top.equalTo(Bar.snp.bottom).offset(-40)
            make.trailing.equalTo(commentButton).offset(60)
        }
    }
    
    func setupCollectionView() {
        
        view.endEditing(true)
        let layout = UICollectionViewFlowLayout()
        layout.itemSize = CGSize(width: (view.frame.width / 2) - 2.5, height: (view.frame.width / 1) - 2.5) // Adjusted size
        layout.minimumLineSpacing = 5 // Reduced line spacing
        layout.minimumInteritemSpacing = 5 // Reduced inter-item spacing
        
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.register(WallpaperCell.self, forCellWithReuseIdentifier: "WallpaperCell")
        
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
    }
    
    func fetchWallpapers() {
        guard let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/data") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            
            guard let data = data else {
                print("No data received")
                return
            }
            
            do {
                let formDataList = try JSONDecoder().decode([FormData].self, from: data)
                DispatchQueue.main.async {
                    self?.formDataList = formDataList
                    self?.collectionView.reloadData()
                    self?.refreshControl.endRefreshing() // End refreshing
                }
            } catch {
                print("Error decoding JSON: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    self?.refreshControl.endRefreshing() // End refreshing even if there's an error
                }
            }
        }.resume()
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return isSearching ? filteredFormDataList.count : formDataList.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "WallpaperCell", for: indexPath)
        cell.contentView.subviews.forEach { $0.removeFromSuperview() }
        
        let data = isSearching ? filteredFormDataList[indexPath.item] : formDataList[indexPath.item]
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
                } // Placeholder image for invalid URL
            }
        }
        
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let selectedData: FormData
        if isSearching {
            selectedData = filteredFormDataList[indexPath.item]
        } else {
            selectedData = formDataList[indexPath.item]
        }
        
        let detailVC = WallpaperDetailViewController()
        detailVC.formData = selectedData
        detailVC.modalPresentationStyle = .fullScreen
        present(detailVC, animated: true)
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, columnCountFor section: Int) -> Int {
        return 2
    }
    
    func loading() {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
            make.centerX.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        loading.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            loading.stopAnimating()
        }
    }
    
    @objc private func closesearchButtonTapped() {
        searchBar.isHidden = true
        isSearching = false
        closesearchButton.isHidden = true
        collectionView.reloadData()
        loading()
    }
    
    @objc private func searchButtonTapped() {
        searchBar.isHidden.toggle()
        if searchBar.isHidden {
            isSearching = false
            searchBar.text = ""
            collectionView.reloadData()
            searchBar.resignFirstResponder() // Hide the keyboard
            closesearchButton.isHidden = true
        } else {
            searchBar.becomeFirstResponder()
            closesearchButton.isHidden = false
        }
    }
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder() // Hide the keyboard
        searchBar.isHidden = true
        isSearching = false
        collectionView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            isSearching = false
            filteredFormDataList.removeAll()
        } else {
            isSearching = true
            filteredFormDataList = formDataList.filter { $0.name.lowercased().contains(searchText.lowercased()) }
        }
        collectionView.reloadData()
        
        // Optionally, you can hide the keyboard when the search text is empty
        if searchText.isEmpty {
            searchBar.resignFirstResponder()
        }
    }
    
    @objc private func usersButton() {
        let logoutVC = LogoutViewController()
        logoutVC.modalPresentationStyle = .fullScreen
        present(logoutVC, animated: true)
        //        self.navigationController?.pushViewController(logoutVC, animated: true)
    }
    
    @objc private func addButtonTapped() {
        self.addButton.tintColor = .white
        let addWallpaperVC = AddWallpaperViewController()
        addWallpaperVC.modalPresentationStyle = .fullScreen
        
        present(addWallpaperVC, animated: true)
        //        self.navigationController?.pushViewController(addWallpaperVC, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            self.addButton.tintColor = .gray
        }
    }
    
    @objc private func homeButtonTapped() {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
            make.centerX.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        loading.startAnimating()
        collectionView.isHidden = true
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 3) {
            loading.stopAnimating()
            self.homeButton.tintColor = .white
            self.fetchWallpapers()
            self.collectionView.isHidden = false
        }
        print("Click")
    }
    
    @objc private func buttontouchDown() {
        homeButton.tintColor = .gray
        searchBar.isHidden = true
    }
    
    @objc func navigateToAddWallpaper() {
        let addWallpaperVC = AddWallpaperViewController()
        navigationController?.pushViewController(addWallpaperVC, animated: true)
    }
    
    @objc func handleWallpaperAdded() {
        fetchWallpapers()
    }
    
    
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
        NotificationCenter.default.removeObserver(self, name: .reloadCollectionView, object: nil)
    }
}


extension Notification.Name {
    static let reloadCollectionView = Notification.Name("reloadCollectionView")
}
