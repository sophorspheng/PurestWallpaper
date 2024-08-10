import UIKit
import SnapKit



class LogoutViewController: BaseViewController {
//    static let shared = UserData2()

      var username: String?
      var isAdmin: Bool = false
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(named: "purest")
        return imageView
    }()

    private let logoutButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Log out", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Log out button"
        return button
    }()
    private let RegisterAuthButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Auth Register", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.3
        button.layer.shadowRadius = 4
        button.addTarget(self, action: #selector(RegisterAuthButtons), for: .touchUpInside)
        button.accessibilityLabel = "Register Button"
        return button
    }()

    private let closeButton: UIButton = {
        let button = UIButton(type: .system)
        button.tintColor = .red
        button.setTitleColor(.white, for: .normal)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        button.imageView?.contentMode = .scaleAspectFit
        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Close button"
        return button
    }()

    private let aboutLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 16)
        label.text = """
        Welcome to Our App!
        
        We are dedicated to providing the best user experience.
        
        For any inquiries, please contact us at purest@gmail.com. Tel: (+855) 087457842
        """
        return label
    }()

    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.textColor = .white
        label.font = .systemFont(ofSize: 18)
        label.text = "User Name"
        return label
    }()
    
    private let themeToggleButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Black Theme", for: .normal)
        button.backgroundColor = .black
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(themeToggleButtonTapped), for: .touchUpInside)
        button.accessibilityLabel = "Theme toggle button"
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        let user = UserData.shared.username
        nameLabel.text = user
        updateThemeToggleButton()
        // Fetch the user's role from UserDefaults or any other storage
         if let role = UserDefaults.standard.string(forKey: "userRole"), role == "admin" {
             RegisterAuthButton.isHidden = false
//             RegisterAuthButton.alpha = 1.0 // Fully visible
         } else {
             RegisterAuthButton.isHidden = true
//             RegisterAuthButton.alpha = 0.5 // Semi-transparent to indicate it's disabled
         }
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme1), name: .themeChanged, object: nil)
    }
    @objc private func RegisterAuthButtons(){
        let RegisterAuthButtonVC = RegisterAuthViewController()
        self.present(RegisterAuthButtonVC, animated: true)
    }
    @objc private func applyTheme() {
           view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
           // Update other UI elements if necessary
       }
    @objc private func applyTheme1() {
           view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
           // Update other UI elements if necessary
       }
    deinit {
           NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
       }
    @objc private func closeButtonTapped() {
        dismiss(animated: true)
    }

    @objc private func logoutButtonTapped() {
        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
        let confirmAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
            self.performLogout()
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(confirmAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    @objc private func themeToggleButtonTapped() {
        let newTheme: ThemeManager.Theme = ThemeManager.shared.currentTheme == .dark ? .light : .dark
        ThemeManager.shared.currentTheme = newTheme
        updateThemeToggleButton()
    }

    private func updateThemeToggleButton() {
        let currentTheme = ThemeManager.shared.currentTheme
        themeToggleButton.setTitle(currentTheme == .dark ? "White Theme" : "Black Theme", for: .normal)
        themeToggleButton.backgroundColor = currentTheme == .dark ? .white : .black
        themeToggleButton.setTitleColor(currentTheme == .dark ? .black : .white, for: .normal)
        
        aboutLabel.textColor = currentTheme == .dark ? .white : .black
        nameLabel.textColor = currentTheme == .dark ? .white  : .black
    }
    func logout() {
           UserDefaults.standard.set(false, forKey: "isUserLogged")
           UserDefaults.standard.synchronize()
       }
    private func performLogout() {
        logout()
        let loginVC = WelcomeScreenViewController()
        UIApplication.shared.windows.first?.rootViewController = loginVC
        UIApplication.shared.windows.first?.makeKeyAndVisible()
    }

    private func setupViews() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }

        contentView.addSubview(closeButton)
        closeButton.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(10)
            make.trailing.equalToSuperview().offset(-10)
            make.width.height.equalTo(30)
        }
        
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(closeButton.snp.bottom).offset(10)
            make.width.equalTo(120)
            make.height.equalTo(120)
        }

        contentView.addSubview(nameLabel)
        nameLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        contentView.addSubview(aboutLabel)
        aboutLabel.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(nameLabel.snp.bottom).offset(20)
            make.leading.equalToSuperview().offset(20)
            make.trailing.equalToSuperview().offset(-20)
        }

        contentView.addSubview(themeToggleButton)
        themeToggleButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(aboutLabel.snp.bottom).offset(30)
            make.width.equalTo(200)
            make.height.equalTo(50)
        }

        contentView.addSubview(logoutButton)
        logoutButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(themeToggleButton.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(50)
//            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
        contentView.addSubview(RegisterAuthButton)
        RegisterAuthButton.backgroundColor = .systemPurple
        RegisterAuthButton.snp.makeConstraints { make in
            make.centerX.equalToSuperview()
            make.top.equalTo(logoutButton.snp.bottom).offset(20)
            make.width.equalTo(200)
            make.height.equalTo(50)
            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
        }
    }
}



//import UIKit
//import SnapKit
//
//class LogoutViewController: UIViewController {
//    private let scrollView: UIScrollView = {
//        let scrollView = UIScrollView()
//        scrollView.translatesAutoresizingMaskIntoConstraints = false
//        return scrollView
//    }()
//    
//    private let contentView: UIView = {
//        let view = UIView()
//        view.translatesAutoresizingMaskIntoConstraints = false
//        return view
//    }()
//    
//    private let logoImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.contentMode = .scaleAspectFit
//        imageView.image = UIImage(named: "purest") // Make sure you have a logo image in your assets with this name
//        return imageView
//    }()
//
//    private let logoutButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.setTitle("Log out", for: .normal)
//        button.backgroundColor = .systemRed
//        button.setTitleColor(.white, for: .normal)
//        button.titleLabel?.font = .boldSystemFont(ofSize: 18)
//        button.layer.cornerRadius = 10
//        button.layer.shadowColor = UIColor.black.cgColor
//        button.layer.shadowOffset = CGSize(width: 0, height: 2)
//        button.layer.shadowOpacity = 0.3
//        button.layer.shadowRadius = 4
//        button.addTarget(self, action: #selector(logoutButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    private let closeButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.tintColor = .red
//        button.setTitleColor(.white, for: .normal)
//        button.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
//        button.imageView?.contentMode = .scaleAspectFit
//        button.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
//        return button
//    }()
//
//    private let aboutLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.numberOfLines = 0
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 16)
//        label.text = """
//        Welcome to Our App!
//        
//        We are dedicated to providing the best user experience.
//        
//        For any inquiries, please contact us at purest@gmail.com. Tel: (+855) 087457842
//        """
//        return label
//    }()
//
//    private let nameLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.textAlignment = .center
//        label.textColor = .white
//        label.font = .systemFont(ofSize: 18)
//        label.text = "User Name" // Default text, you can set this dynamically later
//        return label
//    }()
//    
//   
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        self.view.backgroundColor = .darkGray
//        setupViews()
//        let user = UserData.shared.username
//        nameLabel.text = user
//    }
//
//    @objc private func closeButtonTapped() {
//        dismiss(animated: true)
//    }
//
//    @objc private func logoutButtonTapped() {
//        let alert = UIAlertController(title: "Confirm Logout", message: "Are you sure you want to log out?", preferredStyle: .alert)
//        let confirmAction = UIAlertAction(title: "Log Out", style: .destructive) { _ in
//            self.performLogout()
//        }
//        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//        
//        alert.addAction(confirmAction)
//        alert.addAction(cancelAction)
//        
//        present(alert, animated: true, completion: nil)
//    }
//
//    @objc private func shareButtonTapped(_ sender: UIButton) {
//        let appURLs: [Int: URL] = [
//            1000 + "Facebook".hashValue: URL(string: "https://www.facebook.com/sharer/sharer.php?u=https://www.example.com")!,
//            1000 + "Instagram".hashValue: URL(string: "https://www.instagram.com")!,
//            1000 + "Telegram".hashValue: URL(string: "https://t.me/share/url?url=https://www.example.com")!,
//            1000 + "Messenger".hashValue: URL(string: "fb-messenger://share/?link=https://www.example.com")!,
//            1000 + "TikTok".hashValue: URL(string: "https://www.tiktok.com/")!,
//            1000 + "Twitter".hashValue: URL(string: "https://twitter.com/intent/tweet?url=https://www.example.com")!
//        ]
//        
//        if let url = appURLs[sender.tag], UIApplication.shared.canOpenURL(url) {
//            UIApplication.shared.open(url)
//        } else {
//            // Fallback if URL cannot be opened
//            let alert = UIAlertController(title: "Error", message: "Unable to open the selected app.", preferredStyle: .alert)
//            alert.addAction(UIAlertAction(title: "OK", style: .default))
//            present(alert, animated: true)
//        }
//    }
//
//    private func performLogout() {
//        let vc = WelcomeScreenViewController()
//        vc.modalPresentationStyle = .fullScreen
//        present(vc, animated: true)
//    }
//
//    private func setupViews() {
//        view.addSubview(scrollView)
//        scrollView.snp.makeConstraints { make in
//            make.edges.equalTo(view.safeAreaLayoutGuide)
//        }
//
//        scrollView.addSubview(contentView)
//        contentView.snp.makeConstraints { make in
//            make.edges.equalTo(scrollView)
//            make.width.equalTo(scrollView) // This ensures the content view width is equal to the scroll view width
//        }
//
//       
//
//        contentView.addSubview(closeButton)
//        closeButton.snp.makeConstraints { make in
//            make.top.equalTo(contentView.snp.top).offset(10)
//            make.trailing.equalToSuperview().offset(-10)
//            make.width.height.equalTo(30)
//        }
//        contentView.addSubview(logoImageView)
//        logoImageView.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(closeButton.snp.bottom).offset(10)
//            make.width.equalTo(120)
//            make.height.equalTo(120)
//        }
//
//        contentView.addSubview(nameLabel)
//        nameLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(logoImageView.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//
//        contentView.addSubview(aboutLabel)
//        aboutLabel.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(nameLabel.snp.bottom).offset(20)
//            make.leading.equalToSuperview().offset(20)
//            make.trailing.equalToSuperview().offset(-20)
//        }
//
//       
//
//        
//
//        contentView.addSubview(logoutButton)
//        logoutButton.snp.makeConstraints { make in
//            make.centerX.equalToSuperview()
//            make.top.equalTo(aboutLabel.snp.bottom).offset(30)
//            make.width.equalTo(200)
//            make.height.equalTo(50)
//            make.bottom.equalTo(contentView.snp.bottom).offset(-30)
//        }
//    }
//}
