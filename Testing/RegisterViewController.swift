import UIKit

class RegisterViewController: UIViewController {
    // UI elements
    private let usernameTextField = UITextField()
    private let passwordTextField = UITextField()
    private let roleSegmentedControl = UISegmentedControl(items: ["User", "Admin"])
    private let registerButton = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        roleSegmentedControl.isHidden = true
        setupUI()
        setupConstraints()
    }

    private func setupUI() {
        // Configure UI elements (e.g., text fields, button)
        view.backgroundColor = .white

        usernameTextField.placeholder = "Username"
        usernameTextField.borderStyle = .roundedRect
        passwordTextField.placeholder = "Password"
        passwordTextField.borderStyle = .roundedRect
        passwordTextField.isSecureTextEntry = true
        roleSegmentedControl.selectedSegmentIndex = 0
        registerButton.setTitle("Register", for: .normal)
        registerButton.backgroundColor = .systemBlue
        registerButton.addTarget(self, action: #selector(registerUser), for: .touchUpInside)

        // Add subviews
        view.addSubview(usernameTextField)
        view.addSubview(passwordTextField)
        view.addSubview(roleSegmentedControl)
        view.addSubview(registerButton)
    }

    private func setupConstraints() {
        // Add constraints for UI elements
        usernameTextField.translatesAutoresizingMaskIntoConstraints = false
        passwordTextField.translatesAutoresizingMaskIntoConstraints = false
        roleSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        registerButton.translatesAutoresizingMaskIntoConstraints = false

        NSLayoutConstraint.activate([
            usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            usernameTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            usernameTextField.widthAnchor.constraint(equalToConstant: 200),

            passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 20),
            passwordTextField.widthAnchor.constraint(equalToConstant: 200),

            roleSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            roleSegmentedControl.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 20),
            roleSegmentedControl.widthAnchor.constraint(equalToConstant: 200),

            registerButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            registerButton.topAnchor.constraint(equalTo: roleSegmentedControl.bottomAnchor, constant: 20),
            registerButton.widthAnchor.constraint(equalToConstant: 200)
        ])
    }

    @objc private func registerUser() {
        guard let username = usernameTextField.text, !username.isEmpty,
              let password = passwordTextField.text, !password.isEmpty else {
            // Show error
            return
        }

        let role = roleSegmentedControl.selectedSegmentIndex ==  0 ? "user" : "user"
//        0 ? "User" : "Admin"

        let parameters: [String: Any] = ["username": username, "password": password, "role": role]

        guard let url = URL(string: "http://localhost:3000/register") else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: parameters, options: [])

        URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }

            // Handle response
            DispatchQueue.main.async {
                // Show success message
            }
        }.resume()
    }
}
