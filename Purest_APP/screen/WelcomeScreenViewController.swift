import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class WelcomeScreenViewController: UIViewController, UITextFieldDelegate {
    private let presentingIndicatorTypes = {
          return NVActivityIndicatorType.allCases.filter { $0 != .blank }
      }()
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()

    private let animatedWallpaper: UIImageView = {
        let imageView = UIImageView()
        // Assuming you have a sequence of images named "wallpaper1", "wallpaper2", ..., "wallpaperN"
        let imageNames = ["12", "ball","plane", "ball"]
        let images = imageNames.compactMap { UIImage(named: $0) }
        imageView.animationImages = images
        imageView.animationDuration = 10.0 // Duration of the entire animation
        imageView.startAnimating()
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private let logoPurest: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "purest.png") // Replace "logo" with your image name
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Sign up", for: .normal)
        button.backgroundColor = .systemGreen
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(signupButtons), for: .touchUpInside)
        return button
    }()
    
    private let signupButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Log in", for: .normal)
        button.setTitleColor(.black, for: .normal)
        if #available(iOS 13.0, *) {
            button.backgroundColor = .systemGray6
        } else {
            // Fallback on earlier versions
        }
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(loginButtons), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 13.0, *) {
            view.backgroundColor = .systemGray2
        } else {
            // Fallback on earlier versions
        }
        setupViews()
        setupConstraints()
        addKeyboardObservers()
    }
    
    private func setupViews() {
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add wallpaper background view
        view.insertSubview(animatedWallpaper, at: 0)
        
        // Add UI elements to content view
        contentView.addSubview(logoPurest)
        contentView.addSubview(loginButton)
        contentView.addSubview(signupButton)
    }
    
    private func setupConstraints() {
        animatedWallpaper.snp.makeConstraints { make in
            make.edges.equalTo(view)
        }
        
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        logoPurest.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(40)
            make.centerX.equalTo(contentView)
            make.width.equalTo(180)  // Adjust size as needed
            make.height.equalTo(180) // Adjust size as needed
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(logoPurest.snp.bottom).offset(20)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
        }
        
        signupButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.leading.equalTo(loginButton)
            make.trailing.equalTo(loginButton)
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
        }
    }
    
    @objc private func signupButtons() {
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
            make.centerX.equalTo(view.safeAreaLayoutGuide).offset(0)
        }
        loading.startAnimating()
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            loading.stopAnimating()
            let wallpaperVC = SignUpViewController()
            wallpaperVC.modalPresentationStyle = .fullScreen
            self.present(wallpaperVC, animated: true)
        }
    }
    
    @objc private func loginButtons() {
        let createAccountVC = LoginWallpaperViewController()
        createAccountVC.modalPresentationStyle = .fullScreen
        present(createAccountVC, animated: true)
    }
    
    private func addKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc private func keyboardWillShow(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        let keyboardHeight = keyboardFrame.height
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = keyboardHeight
            self.scrollView.scrollIndicatorInsets.bottom = keyboardHeight
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.contentView.frame.height + keyboardHeight)
        }
    }
    
    @objc private func keyboardWillHide(_ notification: Notification) {
        guard let userInfo = notification.userInfo,
              let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else {
            return
        }
        
        UIView.animate(withDuration: duration) {
            self.scrollView.contentInset.bottom = 0
            self.scrollView.scrollIndicatorInsets.bottom = 0
            self.scrollView.contentSize = CGSize(width: self.scrollView.frame.width, height: self.contentView.frame.height)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()  // Dismiss the keyboard
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}
