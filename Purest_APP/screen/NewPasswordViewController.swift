//
//  NewPasswordViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/1/24.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class NewPasswordViewController: UIViewController, UITextFieldDelegate {

    var email: String?
    
    // MARK: - UI Elements
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        return view
    }()
    
    private let emailTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Email"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .emailAddress
        return textField
    }()
    
    private let newPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "New Password"
        textField.borderStyle = .roundedRect
        textField.isSecureTextEntry = true
        return textField
    }()
    
    private let otpTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "OTP"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    private let doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Done", for: .normal)
        button.backgroundColor = .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 5
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private let activityIndicatorView = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemGray, padding: 0)

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupSubviews()
        setupConstraints()
        
        // Set the delegate for text fields
        emailTextField.delegate = self
        newPasswordTextField.delegate = self
        otpTextField.delegate = self
        emailTextField.isHidden = true
        
        if let email = email {
                  emailTextField.text = email
              }
    }
    
    // MARK: - Setup Methods
    private func setupSubviews() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(emailTextField)
        contentView.addSubview(newPasswordTextField)
        contentView.addSubview(otpTextField)
        contentView.addSubview(doneButton)
        view.addSubview(activityIndicatorView)
    }
    
    private func setupConstraints() {
        scrollView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }
        
        contentView.snp.makeConstraints { make in
            make.edges.equalToSuperview()
            make.width.equalTo(scrollView) // Ensure the contentView's width matches the scrollView
        }
        
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(20)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        newPasswordTextField.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        otpTextField.snp.makeConstraints { make in
            make.top.equalTo(newPasswordTextField.snp.bottom).offset(16)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
        }
        
        doneButton.snp.makeConstraints { make in
            make.top.equalTo(otpTextField.snp.bottom).offset(32)
            make.leading.equalToSuperview().inset(16)
            make.trailing.equalToSuperview().inset(16)
            make.height.equalTo(44)
            make.bottom.equalTo(contentView.snp.bottom).offset(-20) // Ensure button is aligned with bottom of contentView
        }
        
        activityIndicatorView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.height.equalTo(80)
        }
    }
    
    func isPasswordValid(_ password: String) -> Bool {
        return password.count >= 8
    }
    // MARK: - Actions
    @objc private func doneButtonTapped() {
        guard let email = emailTextField.text?.lowercased(), !email.isEmpty,
              let otp = otpTextField.text, !otp.isEmpty else{
            showAlert(title: "Message", message: "Please enter all fields.")
            return
        }
        guard let password = newPasswordTextField.text, !password.isEmpty else {
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

        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/reset-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body: [String: Any] = ["email": email, "newPassword": password, "otp": otp]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.stopLoading()

                if let error = error {
                    self.showAlert(title: "Error", message: error.localizedDescription)
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
                        self.showAlertWithAction(title: "Success", message: "Your password has been reset successfully.", actionTitle: "OK") { _ in
                            let wallpaperListVC = WallpaperListViewController()
                            wallpaperListVC.modalPresentationStyle = .fullScreen
                            self.present(wallpaperListVC, animated: true)
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
                } catch {
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

    // MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder() // Hide the keyboard
        return true
    }
}
