//
//  LoginWallpaperViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 7/30/24.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended
struct LoginRequest: Codable {
    let email: String
    let password: String
}

struct LoginResponse: Codable {
    let message: String
    let status: Int
    let data: TokenData?
    
    struct TokenData: Codable {
        let jwt: JWT
        
        struct JWT: Codable {
            let accessToken: String
            let tokenType: String
            let expiresIn: Int
            
            enum CodingKeys: String, CodingKey {
                case accessToken = "access_token"
                case tokenType = "token_type"
                case expiresIn = "expires_in"
            }
        }
    }
}


class LoginWallpaperViewController: UIViewController, UITextFieldDelegate {
    
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let loginButton = UIButton()
    private let forgotPasswordButton = UIButton()
    private let signUpButton = UIButton()
    
    private let showPasswordButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupKeyboardObservers()
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        
        // Register for theme change notifications
        NotificationCenter.default.addObserver(self, selector: #selector(applyTheme), name: .themeChanged, object: nil)
    }
    
    @objc private func applyTheme() {
        view.backgroundColor = ThemeManager.shared.currentTheme == .dark ? .black : .white
        // Update other UI elements if necessary
    }
    
    
    private func setupUI() {
        view.backgroundColor = .white
        
        // Scroll View
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        // Content View
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        // Logo
        logoImageView.image = UIImage(named: "purest")
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }
        
        // Email TextField
        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.delegate = self
        contentView.addSubview(emailTextField)
        emailTextField.keyboardType = .emailAddress
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        // Password TextField
        passwordTextField.placeholder = "Enter your password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20) // Add space for the button
            make.height.equalTo(44)
        }
        
        // Show/Hide Password Button (Inside the Password Field)
        if #available(iOS 13.0, *) {
            showPasswordButton.setImage(UIImage(systemName: "eye"), for: .normal)
        } else {
            // Fallback on earlier versions
        }
        showPasswordButton.tintColor = .gray
        showPasswordButton.addTarget(self, action: #selector(togglePasswordVisibility), for: .touchUpInside)
        showPasswordButton.frame = CGRect(x: 0, y: 0, width: 30, height: 30)
        passwordTextField.rightView = showPasswordButton
        passwordTextField.rightViewMode = .always
        
        // Forgot Password Button
        forgotPasswordButton.setTitle("Forgot your password?", for: .normal)
        forgotPasswordButton.setTitleColor(.blue, for: .normal)
        forgotPasswordButton.addTarget(self, action: #selector(forgotPasswordButtonTapped), for: .touchUpInside)
        contentView.addSubview(forgotPasswordButton)
        forgotPasswordButton.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
        }
        
        // Login Button
        loginButton.setTitle("Log In", for: .normal)
        loginButton.backgroundColor = .blue
        loginButton.setTitleColor(.white, for: .normal)
        loginButton.layer.cornerRadius = 22
        contentView.addSubview(loginButton)
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        loginButton.snp.makeConstraints { make in
            make.top.equalTo(forgotPasswordButton.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        
        // Sign Up Button
        signUpButton.setTitle("Don’t have an account? Sign up", for: .normal)
        signUpButton.setTitleColor(.blue, for: .normal)
        signUpButton.addTarget(self, action: #selector(noaccountButtonTapped), for: .touchUpInside)
        contentView.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(loginButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-20) // Ensure proper scrolling
        }
    }
    
    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func loginSuccessful() {
        UserDefaults.standard.set(true, forKey: "isUserLogged")
        UserDefaults.standard.synchronize()
        
        // Navigate to the home screen
        let homeVC = WallpaperListViewController()
        UserData.shared.username =   emailTextField.text
        let navController = UINavigationController(rootViewController: homeVC)
        UIApplication.shared.windows.first?.rootViewController = navController
        UIApplication.shared.windows.first?.makeKeyAndVisible()
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
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1){
            
            loading.stopAnimating()
            
            self.loginSuccessful()
            
            
        }
    }
    @objc private func noaccountButtonTapped(){
        let  signupVC = SignUpViewController()
        present(signupVC, animated: true)
    }
    func isEmailValid(_ email: String) -> Bool {
        return email.hasSuffix("@gmail.com")
    }
    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 8
    }
    @objc private func loginButtonTapped() {
        guard let username = emailTextField.text, !username.isEmpty
              else {
            // Show error message to the user (e.g., an alert)
            self.showAlert(title: "Error", message: "Please enter both email and password.")
            return
        }
        guard let email = emailTextField.text?.lowercased(), !email.isEmpty else {
              // Show error message
              self.showAlert(title: "Error", message: "Email cannot be empty.")
              return
          }
          
          if !isEmailValid(email) {
              // Show error message
              self.showAlert(title: "Error", message: "Email must end with @gmail.com.")
              return
          }
        
        guard let password = passwordTextField.text?.lowercased(), !password.isEmpty else {
               // Show error message
               self.showAlert(title: "Error", message: "Password cannot be empty.")
               return
           }
           
           if !isPasswordValid(password) {
               // Show error message
               self.showAlert(title: "Error", message: "Password must be at least 8 characters long.")
               return
           }
        let parameters: [String: Any] = ["email": username, "password": password]
        
        guard let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/login") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
        
        // Show loading animation
        let loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
        loading.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(loading)
        loading.snp.makeConstraints { make in
            make.width.height.equalTo(80)
            make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
            make.centerX.equalTo(view.safeAreaLayoutGuide)
        }
        loading.startAnimating()
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                loading.stopAnimating() // Stop the loading animation
                
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
                        // Successful login logic
                        if let token = responseJSON?["token"] as? String,
                           let role = responseJSON?["role"] as? String {
                            // Save the token and role (e.g., in UserDefaults)
                            UserDefaults.standard.set(token, forKey: "authToken")
                            UserDefaults.standard.set(role, forKey: "userRole")
                            UserDefaults.standard.set(true, forKey: "isUserLogged")
                            UserDefaults.standard.synchronize()
                            UserData.shared.username = username
                            
                            // Proceed to the next screen or show a success message
                            self.loginSuccessful()
                        } else {
                            self.showAlert(title: "Login Failed", message: "Unable to retrieve token or role.")
                        }
                        
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

    
//    @objc private func loginButtonTapped() {
//        
//        guard let username = emailTextField.text, !username.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            // Show error
//            return
//        }
//        
//        let parameters: [String: Any] = ["email": username, "password": password]
//        
//        guard let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/login") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//        // Show loading animation
//                    let loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)
//                    loading.translatesAutoresizingMaskIntoConstraints = false
//                    view.addSubview(loading)
//                    loading.snp.makeConstraints { make in
//                        make.width.height.equalTo(80)
//                        make.top.equalTo(view.safeAreaLayoutGuide).offset(250)
//                        make.centerX.equalTo(view.safeAreaLayoutGuide)
//                    }
//                    loading.startAnimating()
//        
//        
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//            
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                  let token = json["token"] as? String,
//                  let role = json["role"] as? String else {
//                // Handle login failure
//                return
//            }
//            
//            // Save the token and role (e.g., in UserDefaults)
//            UserDefaults.standard.set(token, forKey: "authToken")
//            UserDefaults.standard.set(role, forKey: "userRole")
//            
//            DispatchQueue.main.async {
//                loading.stopAnimating()
//                UserDefaults.standard.set(true, forKey: "isUserLogged")
//                UserDefaults.standard.synchronize()
//                UserData.shared.username =   username
//           
//                self.loginSuccessful()
//                
//            }
//          
//           
//        }.resume()
//        
//    }
//    
    
    
//            guard let email = emailTextField.text?.lowercased(), !email.isEmpty,
//                  let password = passwordTextField.text, !password.isEmpty else {
//                showAlert(title: "Message", message: "Please enter both email and password.")
//                return
//            }
//    
//        let parameters: [String: Any] = ["email": email, "password": password]
//            let url = URL(string: "http://localhost:3001/api/auth/login")!
//            var request = URLRequest(url: url)
//            request.httpMethod = "POST"
//                    request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//                    request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//    
//    
//          s
    
    
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
    @objc private func forgotPasswordButtonTapped(){
        let forgotPassword = ForgotPasswordViewController()
        present(forgotPassword, animated: true)
    }
    @objc private func keyboardWillShow(notification: NSNotification) {
        if let userInfo = notification.userInfo,
           let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect {
            let keyboardHeight = keyboardFrame.height
            scrollView.contentInset.bottom = keyboardHeight
            scrollView.scrollIndicatorInsets.bottom = keyboardHeight
        }
    }
    
    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = 0
        scrollView.scrollIndicatorInsets.bottom = 0
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
        if #available(iOS 13.0, *) {
            showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
        } else {
            // Fallback on earlier versions
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
}
