//
//  ForgotPasswordViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 7/30/24.
//

import UIKit
import SnapKit
import NVActivityIndicatorView
import NVActivityIndicatorViewExtended

class ForgotPasswordViewController: UIViewController, UITextFieldDelegate {

    private let scrollView = UIScrollView()
    private let contentView = UIView()
    
    private let logoImageView = UIImageView()
    private let instructionLabel = UILabel()
    private let emailTextField = UITextField()
    private let submitButton = UIButton()
    private let backButton = UIButton()
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
        // Update other UI elements if necessary
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
        logoImageView.image = UIImage(named: "purest") // Replace with your logo image
        logoImageView.contentMode = .scaleAspectFit
        contentView.addSubview(logoImageView)
        logoImageView.snp.makeConstraints { make in
            make.top.equalTo(contentView.snp.top).offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(100)
        }

        // Instruction Label
        instructionLabel.text = "Enter your email address below, and we'll send you instructions to reset your password."
        instructionLabel.numberOfLines = 0
        instructionLabel.textAlignment = .center
        instructionLabel.font = .systemFont(ofSize: 16)
        instructionLabel.textColor = .gray
        contentView.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { make in
            make.top.equalTo(logoImageView.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
        }

        // Email TextField
        emailTextField.placeholder = "Enter your email"
        emailTextField.borderStyle = .roundedRect
        emailTextField.keyboardType = .emailAddress
        emailTextField.delegate = self
        contentView.addSubview(emailTextField)
        emailTextField.snp.makeConstraints { make in
            make.top.equalTo(instructionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }

        // Submit Button
        submitButton.setTitle("Send", for: .normal)
        submitButton.backgroundColor = .blue
        submitButton.setTitleColor(.white, for: .normal)
        submitButton.layer.cornerRadius = 22
        contentView.addSubview(submitButton)
        submitButton.snp.makeConstraints { make in
            make.top.equalTo(emailTextField.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(44)
        }
        submitButton.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)

        // Back Button
        backButton.setTitle("Back to Login", for: .normal)
        backButton.setTitleColor(.blue, for: .normal)
        backButton.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        contentView.addSubview(backButton)
        backButton.snp.makeConstraints { make in
            make.top.equalTo(submitButton.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(contentView.snp.bottom).offset(-20) // Ensure proper scrolling
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

    @objc private func sendButtonTapped() {
        guard let email = emailTextField.text, !email.isEmpty else {
            showAlert(title: "Message", message: "Please enter your email.")
            return
        }

        startLoading()

        let url = URL(string: "https://nodeapi-backend.vercel.app/api/auth/forgot-password")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let body = ["email": email]
        request.httpBody = try? JSONSerialization.data(withJSONObject: body, options: [])

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            DispatchQueue.main.async {
                self.stopLoading()

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
                        self.showAlertWithAction(title: "Success", message: "Instructions have been sent to your email.", actionTitle: "OK") { _ in
                            let newPasswordVC = NewPasswordViewController()
                                  newPasswordVC.email = email
                            self.present(newPasswordVC, animated: true)
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
    
    @objc private func backButtonTapped() {
        dismiss(animated: true)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
}
