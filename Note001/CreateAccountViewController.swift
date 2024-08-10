//
//  CreateAccountViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 7/21/24.
//

import UIKit
import SnapKit

class CreateAccountViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    let nameTextField = UITextField()
    let genderTextField = UITextField()
    let addressTextField = UITextField()
    let phoneTextField = UITextField()
    let imageView = UIImageView()
    let selectImageButton = UIButton(type: .system)
    let submitButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        setupViews()
        setupConstraints()
    }

    func setupViews() {
        nameTextField.placeholder = "Name"
        genderTextField.placeholder = "Gender"
        addressTextField.placeholder = "Address"
        phoneTextField.placeholder = "Phone"
        
        selectImageButton.setTitle("Select Image", for: .normal)
        selectImageButton.addTarget(self, action: #selector(selectImage), for: .touchUpInside)
        
        submitButton.setTitle("Submit", for: .normal)
        submitButton.addTarget(self, action: #selector(submitForm), for: .touchUpInside)
        
        imageView.contentMode = .scaleAspectFit
        
        view.addSubview(nameTextField)
        view.addSubview(genderTextField)
        view.addSubview(addressTextField)
        view.addSubview(phoneTextField)
        view.addSubview(imageView)
        view.addSubview(selectImageButton)
        view.addSubview(submitButton)
    }

    func setupConstraints() {
        nameTextField.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }

        genderTextField.snp.makeConstraints { make in
            make.top.equalTo(nameTextField.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }

        addressTextField.snp.makeConstraints { make in
            make.top.equalTo(genderTextField.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }

        phoneTextField.snp.makeConstraints { make in
            make.top.equalTo(addressTextField.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }

        imageView.snp.makeConstraints { make in
            make.top.equalTo(phoneTextField.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(200)
        }

        selectImageButton.snp.makeConstraints { make in
            make.top.equalTo(imageView.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }

        submitButton.snp.makeConstraints { make in
            make.top.equalTo(selectImageButton.snp.bottom).offset(20)
            make.left.right.equalTo(view).inset(20)
            make.height.equalTo(40)
        }
    }

    @objc func selectImage() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.sourceType = .photoLibrary
        present(imagePickerController, animated: true, completion: nil)
    }

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let selectedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            imageView.image = selectedImage
        }
        picker.dismiss(animated: true, completion: nil)
    }

    @objc func submitForm() {
        guard let name = nameTextField.text,
              let gender = genderTextField.text,
              let address = addressTextField.text,
              let phone = phoneTextField.text,
              let image = imageView.image else {
                  print("Please fill all fields and select an image.")
                  return
        }

        saveUserData(name: name, gender: gender, address: address, phone: phone, image: image)
    }

    func saveUserData(name: String, gender: String, address: String, phone: String, image: UIImage) {
        let url = URL(string: "http://localhost:8080/saveUserData")!
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var data = Data()
        
        // Add name
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"name\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(name)\r\n".data(using: .utf8)!)
        
        // Add gender
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"gender\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(gender)\r\n".data(using: .utf8)!)
        
        // Add address
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"address\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(address)\r\n".data(using: .utf8)!)
        
        // Add phone
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"phone\"\r\n\r\n".data(using: .utf8)!)
        data.append("\(phone)\r\n".data(using: .utf8)!)
        
        // Add image
        let imageData = image.jpegData(compressionQuality: 1.0)!
        data.append("--\(boundary)\r\n".data(using: .utf8)!)
        data.append("Content-Disposition: form-data; name=\"image\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        data.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        data.append(imageData)
        data.append("\r\n".data(using: .utf8)!)
        
        data.append("--\(boundary)--\r\n".data(using: .utf8)!)
        
        let task = URLSession.shared.uploadTask(with: request, from: data) { responseData, response, error in
            if let error = error {
                print("Error: \(error.localizedDescription)")
                return
            }
            if let responseData = responseData {
                if let responseString = String(data: responseData, encoding: .utf8) {
                    print("Response: \(responseString)")
//                   
                }
            }
        }
        
        task.resume()
    }
}
