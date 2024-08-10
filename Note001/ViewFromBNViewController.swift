//
//  ViewFromBNViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 7/28/24.
//

import UIKit
import SnapKit
struct UserData1: Codable {
    let name: String
    let gender: String
    let address: String
    let phone: String
    let imageURL: String
}

class ViewFromBNViewController: UIViewController {


        let nameLabel = UILabel()
        let genderLabel = UILabel()
        let addressLabel = UILabel()
        let phoneLabel = UILabel()
        let imageView = UIImageView()

        override func viewDidLoad() {
            super.viewDidLoad()
            view.backgroundColor = .white
            setupViews()
            setupConstraints()
            loadData()
            
        }

        func setupViews() {
            nameLabel.text = "Name: "
            genderLabel.text = "Gender: "
            addressLabel.text = "Address: "
            phoneLabel.text = "Phone: "

            imageView.contentMode = .scaleAspectFit
            
            view.addSubview(nameLabel)
            view.addSubview(genderLabel)
            view.addSubview(addressLabel)
            view.addSubview(phoneLabel)
            view.addSubview(imageView)
        }

        func setupConstraints() {
            nameLabel.snp.makeConstraints { make in
                make.top.equalTo(view.safeAreaLayoutGuide).offset(20)
                make.left.right.equalTo(view).inset(20)
            }

            genderLabel.snp.makeConstraints { make in
                make.top.equalTo(nameLabel.snp.bottom).offset(20)
                make.left.right.equalTo(view).inset(20)
            }

            addressLabel.snp.makeConstraints { make in
                make.top.equalTo(genderLabel.snp.bottom).offset(20)
                make.left.right.equalTo(view).inset(20)
            }

            phoneLabel.snp.makeConstraints { make in
                make.top.equalTo(addressLabel.snp.bottom).offset(20)
                make.left.right.equalTo(view).inset(20)
            }

            imageView.snp.makeConstraints { make in
                make.top.equalTo(phoneLabel.snp.bottom).offset(20)
                make.left.right.equalTo(view).inset(20)
                make.height.equalTo(200)
            }
        }

        func loadData() {
            // Fetch data from the backend and populate the labels and image view
            // This is a placeholder for demonstration purposes
            nameLabel.text = "Name: John Doe"
            genderLabel.text = "Gender: Male"
            addressLabel.text = "Address: 123 Main St"
            phoneLabel.text = "Phone: 123-456-7890"
            
            // Placeholder image
            if let imageURL = URL(string: "file:///Users/macbookpro/Desktop/aigeneratapi/uploads/image-1722133885007.png") {
                loadImage(from: imageURL)
            }
        }

        func loadImage(from url: URL) {
            let task = URLSession.shared.dataTask(with: url) { data, response, error in
                guard let data = data, error == nil else { return }
                DispatchQueue.main.async {
                    self.imageView.image = UIImage(data: data)
                }
            }
            task.resume()
        }
    }

    
