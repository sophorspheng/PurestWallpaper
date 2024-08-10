//
//  SettingViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 7/20/24.
//

import UIKit

class SettingViewController: UIViewController {
    var LabelUsername : UILabel  = {
        let LabelUsername = UILabel()
        LabelUsername.translatesAutoresizingMaskIntoConstraints = false
        LabelUsername.textColor =  .red
        return LabelUsername
    }()
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Setting"
        if #available(iOS 15.0, *) {
            self.view.backgroundColor = .systemMint
        } else {
            // Fallback on earlier versions
        }
        if #available(iOS 13.0, *) {
            let rightButton = UIBarButtonItem(image: UIImage(systemName: "applelogo"), style: .done, target: self, action: #selector(logout))
        } else {
            // Fallback on earlier versions
        }
//        let rightButton = UIBarButtonItem(title: "Right", style: .plain, target: self, action: #selector(logout))
               
               // Set the tint color to your desired UIColor
//               rightButton.tintColor = UIColor.red
               
               // Add the bar button item to the navigation bar
//               self.navigationItem.rightBarButtonItem = rightButton
        let user = UserData.shared.username
        LabelUsername.text = user
        setupConfig()
    }
    @objc func logout(){
        
        dismiss(animated: true)
    }
    @objc func setupConfig(){
        view.addSubview(LabelUsername)
        LabelUsername.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        LabelUsername.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
    }

}
