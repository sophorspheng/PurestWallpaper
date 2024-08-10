//import UIKit
//
//class Login1ViewController: UIViewController {
//    // UI elements
//    private let usernameTextField = UITextField()
//    private let passwordTextField = UITextField()
//    private let loginButton = UIButton()
//
//    override func viewDidLoad() {
//        super.viewDidLoad()
//        setupUI()
//        setupConstraints()
//    }
//
//    private func setupUI() {
//        // Configure UI elements (e.g., text fields, button)
//        view.backgroundColor = .white
//
//        usernameTextField.placeholder = "Username"
//        usernameTextField.borderStyle = .roundedRect
//        passwordTextField.placeholder = "Password"
//        passwordTextField.borderStyle = .roundedRect
//        passwordTextField.isSecureTextEntry = true
//        loginButton.setTitle("Login", for: .normal)
//        loginButton.backgroundColor = .systemBlue
//        loginButton.addTarget(self, action: #selector(loginUser), for: .touchUpInside)
//
//        // Add subviews
//        view.addSubview(usernameTextField)
//        view.addSubview(passwordTextField)
//        view.addSubview(loginButton)
//    }
//
//    private func setupConstraints() {
//        // Add constraints for UI elements
//        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
//        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
//        loginButton.translatesAutoresizingMaskIntoConstraints = false
//
//        NSLayoutConstraint.activate([
//            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            usernameTextField.widthAnchor.constraint(equalToConstant: 200),
//
//            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
//            passwordTextField.widthAnchor.constraint(equalToConstant: 200),
//
//            loginButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loginButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
//            loginButton.widthAnchor.constraint(equalToConstant: 200)
//        ])
//    }
//
//    @objc private func loginUser() {
//        guard let username = usernameTextField.text, !username.isEmpty,
//              let password = passwordTextField.text, !password.isEmpty else {
//            // Show error
//            return
//        }
//
//        let parameters: [String: Any] = ["username": username, "password": password]
//
//        guard let url = URL(string: "http://localhost:3000/login") else { return }
//        var request = URLRequest(url: url)
//        request.httpMethod = "POST"
//        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
//        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])
//
//        URLSession.shared.dataTask(with: request) { data, response, error in
//            if let error = error {
//                print("Error: \(error.localizedDescription)")
//                return
//            }
//
//            guard let data = data,
//                  let json = try? JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
//                  let token = json["token"] as? String else {
//                // Handle login failure
//                return
//            }
//
//            // Save the token (e.g., in UserDefaults)
//            UserDefaults.standard.set(token, forKey: "authToken")
//
//            DispatchQueue.main.async {
//                let nav = AdminViewController()
//                nav.modalPresentationStyle = .fullScreen
//                self.present(nav, animated: true)
//            }
//        }.resume()
//    }
//}
