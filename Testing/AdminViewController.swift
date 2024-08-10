import UIKit

class DeleteUserViewController: UIViewController {

    let userIdTextField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Enter User ID"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .numberPad
        return textField
    }()
    
    let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Delete User", for: .normal)
        button.addTarget(self, action: #selector(deleteUser), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupLayout()
    }
    
    private func setupLayout() {
        view.addSubview(userIdTextField)
        view.addSubview(deleteButton)
        
        userIdTextField.translatesAutoresizingMaskIntoConstraints = false
        deleteButton.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            userIdTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            userIdTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: -20),
            userIdTextField.widthAnchor.constraint(equalToConstant: 200),
            userIdTextField.heightAnchor.constraint(equalToConstant: 40),
            
            deleteButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            deleteButton.topAnchor.constraint(equalTo: userIdTextField.bottomAnchor, constant: 20),
            deleteButton.widthAnchor.constraint(equalToConstant: 200),
            deleteButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    @objc private func deleteUser() {
        guard let userId = userIdTextField.text, !userId.isEmpty else {
            showAlert(message: "Please enter a valid User ID")
            return
        }
        
        deleteUserById(userId: userId)
    }
    
    private func deleteUserById(userId: String) {
        guard let url = URL(string: "http://localhost:3001/delete/\(userId)") else { return }
        
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("Bearer your_jwt_token", forHTTPHeaderField: "Authorization") // Replace with actual JWT
        
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.showAlert(message: "Error: \(error.localizedDescription)")
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else { return }
            
            DispatchQueue.main.async {
                switch httpResponse.statusCode {
                case 200:
                    self.showAlert(message: "User and image deleted successfully")
                case 403:
                    self.showAlert(message: "Access denied. Admin only.")
                case 404:
                    self.showAlert(message: "User not found")
                default:
                    self.showAlert(message: "Server error")
                }
            }
        }
        
        task.resume()
    }
    
    private func showAlert(message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
}
