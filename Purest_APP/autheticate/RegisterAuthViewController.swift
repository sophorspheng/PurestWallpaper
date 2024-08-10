//
//  RegisterAuthViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/10/24.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class RegisterAuthViewController: UIViewController, UITextFieldDelegate {

   
    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let nameTextField = UITextField()
    private let emailTextField = UITextField()
    private let passwordTextField = UITextField()
    private let roleSegmentedControl = UISegmentedControl(items: ["User", "Admin"]) // Added Segmented Control
    private let signUpButton = UIButton()
    private let termsLabel = UILabel()
    private let signInButton = UIButton()
    
    private let showPasswordButton = UIButton()
    private let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)

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
    }

    private func setupUI() {
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

        // Name TextField
        nameTextField.placeholder = "Enter your name"
        nameTextField.borderStyle = .roundedRect
        nameTextField.backgroundColor = .blue
        nameTextField.delegate = self
        contentView.addSubview(nameTextField)
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // Email TextField
        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.backgroundColor = .blue
        emailTextField.delegate = self
        contentView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // Password TextField
        passwordTextField.placeholder = "Create a password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        passwordTextField.backgroundColor = .blue
        passwordTextField.delegate = self
        contentView.addSubview(passwordTextField)
        passwordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
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

        // Role Segmented Control
        roleSegmentedControl.selectedSegmentIndex = 0
        roleSegmentedControl.tintColor = .red
        roleSegmentedControl.backgroundColor = .blue
        contentView.addSubview(roleSegmentedControl)
        
        roleSegmentedControl.snp.makeConstraints { make in
            make.top.equalTo(passwordTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // Sign-Up Button
        signUpButton.setTitle("Sign Up", for: .normal)
        signUpButton.backgroundColor = .blue
        signUpButton.setTitleColor(.white, for: .normal)
        signUpButton.layer.cornerRadius = 22
        contentView.addSubview(signUpButton)
        signUpButton.snp.makeConstraints { make in
            make.top.equalTo(roleSegmentedControl.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        signUpButton.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)

        // Terms Label
        termsLabel.text = "By signing up, you agree to our Terms and Conditions"
        termsLabel.font = .systemFont(ofSize: 12)
        termsLabel.textColor = .gray
        termsLabel.textAlignment = .center
        contentView.addSubview(termsLabel)
        termsLabel.snp.makeConstraints { make in
            make.top.equalTo(signUpButton.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        // Sign-In Button
        signInButton.setTitle("Already have an account? Sign in", for: .normal)
        signInButton.setTitleColor(.blue, for: .normal)
        contentView.addSubview(signInButton)
        signInButton.addTarget(self, action: #selector(alreadySigninTapped), for: .touchUpInside)
        signInButton.snp.makeConstraints { make in
            make.top.equalTo(termsLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-20) // Add bottom constraint to ensure proper scrolling
        }

        // Activity Indicator
        view.addSubview(activityIndicatorView)
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
    }

    private func setupKeyboardObservers() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    func isEmailValid(_ email: String) -> Bool {
        return email.hasSuffix("@gmail.com")
    }
    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 8
    }
    @objc private func signUpButtonTapped() {
        UserDefaults.standard.set(true, forKey: "isUserLogged")
        UserDefaults.standard.synchronize()
        
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Message", message: "Please enter all fields.")
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
        guard let password = passwordTextField.text, !password.isEmpty else {
              // Show error message
              self.showAlert(title: "Error", message: "Password cannot be empty.")
              return
          }
          
          if !isPasswordValid(password) {
              // Show error message
              self.showAlert(title: "Error", message: "Password must be at least 8 characters long.")
              return
          }

        startLoading()

        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/register")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let selectedRole = roleSegmentedControl.selectedSegmentIndex == 0 ? "user" : "admin"
        let body: [String: Any] = ["name": name, "email": email, "password": password, "role": selectedRole]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            // Check for errors
            if let error = error {
                DispatchQueue.main.async {
                    self.stopLoading()
                    self.showAlert(title: "Error", message: error.localizedDescription)
                }
                return
            }

            // Check for valid response and data
            guard let data = data, let httpResponse = response as? HTTPURLResponse else {
                DispatchQueue.main.async {
                    self.stopLoading()
                    self.showAlert(title: "Error", message: "Invalid response from server")
                }
                return
            }

            // Parse JSON
            do {
                let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                let message = json?["message"] as? String ?? "An error occurred."
                
                // Handle based on status code
                DispatchQueue.main.async {
                    self.stopLoading()
                    
            ///Debug
                    print(selectedRole)
                    switch httpResponse.statusCode {
                    case 201:
                        if let token = json?["token"] as? String, let role = json?["role"] as? String {
                            UserDefaults.standard.set(token, forKey: "authToken")
                            UserDefaults.standard.set(role, forKey: "userRole")
                        }
                        self.showAlertWithAction(title: "Success", message: "User registered successfully.", actionTitle: "OK") { _ in
                             self.nameTextField.text = nil
                            self.emailTextField.text =  nil
                            self.passwordTextField.text =  nil
                        }
                    case 400:
                        self.showAlert(title: "Bad Request", message: message)
                    case 401:
                        self.showAlert(title: "Unauthorized", message: message)
                    case 404:
                        self.showAlert(title: "Not Found", message: message)
                    case 500:
                        self.showAlert(title: "Server Error", message: message)
                    default:
                        self.showAlert(title: "Error", message: "Unexpected error occurred")
                    }
                }
            } catch {
                DispatchQueue.main.async {
                    self.showAlert(title: "Error", message: "Failed to parse response")
                }
            }
        }
        task.resume()
    }


    private func startLoading() {
        activityIndicatorView.startAnimating()
    }

    private func stopLoading() {
        activityIndicatorView.stopAnimating()
    }

    @objc private func alreadySigninTapped() {
        dismiss(animated: true, completion: nil)
    }

    @objc private func togglePasswordVisibility() {
        passwordTextField.isSecureTextEntry.toggle()
        if #available(iOS 13.0, *) {
            let imageName = passwordTextField.isSecureTextEntry ? "eye" : "eye.slash"
            showPasswordButton.setImage(UIImage(systemName: imageName), for: .normal)
        } else {
            // Fallback on earlier versions
        }
    }

    @objc private func keyboardWillShow(notification: NSNotification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            scrollView.contentInset.bottom = keyboardSize.height
            scrollView.scrollIndicatorInsets.bottom = keyboardSize.height
        }
    }

    @objc private func keyboardWillHide(notification: NSNotification) {
        scrollView.contentInset.bottom = .zero
        scrollView.scrollIndicatorInsets.bottom = .zero
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }

    private func showAlertWithAction(title: String, message: String, actionTitle: String, action: @escaping (UIAlertAction) -> Void) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let alertAction = UIAlertAction(title: actionTitle, style: .default, handler: action)
        alert.addAction(alertAction)
        present(alert, animated: true)
    }
}
