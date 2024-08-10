import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
class LoginViewController: UIViewController, UITextFieldDelegate {
    private let presentingIndicatorTypes = {
          return NVActivityIndicatorType.allCases.filter { $0 != .blank }
      }()
    // UI Elements
    private let scrollView = UIScrollView()
    private let contentView = UIView()
   
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo.png") // Replace "logo" with your image name
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email or Phone"
        textField.borderStyle = .roundedRect
        textField.autocapitalizationType = .none
        return textField
    }()
    
    private let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private lazy var togglePasswordButton: UIButton = {
        let button = UIButton(type: .custom)
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "eye.fill"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            button.setImage(UIImage(systemName: "eye.slash.fill"), for: .selected)
        } else {
            // Fallback on earlier versions
        }
        button.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        return button
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let createAccountButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Create New Account", for: .normal)
        button.setTitleColor(.systemBlue, for: .normal)
        button.addTarget(self, action: #selector(createAccountButtonTapped), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupViews()
        setupConstraints()
        addKeyboardObservers()
        setupTextFieldDelegates()

    }
    
    private func setupViews() {
        view.backgroundColor = .white
        
        
        // Add scroll view and content view
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Add UI elements to content view
        contentView.addSubview(logoImageView)
        contentView.addSubview(emailTextField)
        contentView.addSubview(passwordTextField)
        contentView.addSubview(togglePasswordButton)
        contentView.addSubview(loginButton)
        contentView.addSubview(createAccountButton)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalTo(scrollView)
            make.width.equalTo(scrollView)
        }
        
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView).offset(40)
            make.centerX.equalTo(contentView)
            make.width.equalTo(180)  // Adjust size as needed
            make.height.equalTo(180) // Adjust size as needed
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(40)
            make.leading.equalTo(contentView).offset(20)
            make.trailing.equalTo(contentView).offset(-20)
            make.height.equalTo(40)
        }
        
        togglePasswordButton.snp.makeConstraints { make in
            make.centerY.equalTo(passwordTextField)
            make.trailing.equalTo(passwordTextField).offset(-10)
            make.width.height.equalTo(24)
        }
        
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField)
            make.height.equalTo(40)
        }
        
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.leading.equalTo(emailTextField)
            make.trailing.equalTo(emailTextField)
            make.height.equalTo(50)
        }
        
        createAccountButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.centerX.equalTo(contentView)
            make.bottom.equalTo(contentView).offset(-20)
        }
    }
    
    private func setupTextFieldDelegates() {
        emailTextField.delegate = self
        passwordTextField.delegate = self
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        togglePasswordButton.isSelected = !passwordTextField.isSecureTextEntry
    }
    
    @objc private func loginButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty,
                     let password = passwordTextField.text, !password.isEmpty else {
                   showAlert(title: "Message", message: "Please enter both email and password.")
                   return
               }

               let url = URL(string: "http://localhost:8080/login")!
               var request = URLRequest(url: url)
               request.httpMethod = "POST"
               request.setValue("application/json", forHTTPHeaderField: "Content-Type")

               let body = ["email": email, "password": password]
               request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

               let task = URLSession.shared.dataTask(with: request) { data, response, error in
                   DispatchQueue.main.async {
                       if let error = error {
                           self.showAlert(title: "Message", message: error.localizedDescription)
                           return
                       }

                       guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                           self.showAlert(title: "Error", message: "Invalid response from server")
                           return
                       }

                       do {
                           let responseJSON = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                           let message = responseJSON?["message"] as? String ?? "An error occurred."

                           switch httpResponse.statusCode {
                           case 200:
 
                                       self.loading()
                           case 400:
                               self.showAlert(title: "Message", message: "Bad Request: \(message)")
                           case 401:
                               self.showAlert(title: "Login Failed", message: message)
                           case 404:
                               self.showAlert(title: "Message", message: message)
                           case 500:
                               self.showAlert(title: "Message", message: "Server error: \(message)")
                           default:
                               self.showAlert(title: "Message", message: "Unexpected error occurred")
                           }
                       } catch {
                           self.showAlert(title: "Message", message: "Failed to parse response")
                       }
                   }
               }
               task.resume()
           }

           private func showAlert(title: String, message: String) {
               let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
               present(alertController, animated: true, completion: nil)
           }

           private func showAlertWithAction(title: String, message: String, actionTitle: String, actionHandler: @escaping (UIAlertAction) -> Void) {
               let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
               alertController.addAction(UIAlertAction(title: actionTitle, style: .default, handler: actionHandler))
               present(alertController, animated: true, completion: nil)
         
    }
    func loading(){
        let  loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
               loading.translatesAutoresizingMaskIntoConstraints = false

                view.addSubview(loading)
               loading.snp.makeConstraints { make in
                   make.width.height.equalTo(80)
                   make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
                   make.centerX.equalTo(view.safeAreaLayoutGuide).offset(0)
                   
               }
        loading.startAnimating()
               DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4){
                   loading.stopAnimating()
                   let user = self.emailTextField.text ?? ""
                   let nav = ViewFromBNViewController()
                   let tabBaritem =  UITabBarController()
                   let home = UINavigationController(rootViewController: nav)
                   if #available(iOS 13.0, *) {
                       home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
                   } else {
                       // Fallback on earlier versions
                   }
       
       
                   let Privacy = UINavigationController(rootViewController: SettingViewController())
                   if #available(iOS 13.0, *) {
                       Privacy.tabBarItem = UITabBarItem(title: "Privacy", image: UIImage(systemName: "lock.icloud.fill"), tag: 0)
                   } else {
                       // Fallback on earlier versions
                   }
       
                   if #available(iOS 13.0, *) {
                       var appearance = UINavigationBarAppearance()
                   } else {
                       // Fallback on earlier versions
                   }
       
//                   tabBaritem.setViewControllers([home,Privacy], animated: true)
//                   appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.red]
//       
//                   home.navigationBar.standardAppearance = appearance
//       
//                   Privacy.navigationBar.standardAppearance = appearance
//       
//                   home.navigationBar.barTintColor = UIColor.red
//                   home.navigationBar.scrollEdgeAppearance = appearance
//                   home.navigationBar.compactAppearance = appearance
//                   home.navigationBar.tintColor = .red
//                   tabBaritem.modalPresentationStyle = .fullScreen
//                   UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
//                   UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemPink], for: .selected)
//       
//                   UserData.shared.username = user
//       
//                   self.present(tabBaritem, animated: true)
       
       
               }
    }
    @objc private func createAccountButtonTapped() {
        let createAccountVC = CreateAccountViewController()
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
