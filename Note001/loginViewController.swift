////
////  ViewController.swift
////  Note001
////
////  Created by Sophors Pheng on 7/20/24.
////
//
//import UIKit
//import SnapKit
//import NVActivityIndicatorView
//
//class loginViewController: UIViewController {
//   
//      private var scrollView : UIScrollView = {
//          let scrollView = UIScrollView()
//          if #available(iOS 15.0, *) {
//              scrollView.backgroundColor = .white
//          } else {
//              
//          }
//          scrollView.translatesAutoresizingMaskIntoConstraints = false
//          return scrollView
//      }()
//      private var mainView : UIView = {
//          let mainView = UIView()
//          mainView.translatesAutoresizingMaskIntoConstraints = false
//          return mainView
//      }()
//      private var imageView : UIImageView = {
//          let imageView = UIImageView()
//          imageView.translatesAutoresizingMaskIntoConstraints = false
//          return imageView
//      }()
//      private var userTextField : UITextField = {
//          let userTextField = UITextField()
//          userTextField.translatesAutoresizingMaskIntoConstraints = false
//          return userTextField
//      }()
//      private var passTextField : UITextField = {
//          let passTextField = UITextField()
//          passTextField.translatesAutoresizingMaskIntoConstraints = false
//          return passTextField
//      }()
//   
//      var bottomContraint = NSLayoutConstraint()
//      var stackView  = UIStackView()
//      var stackUserTextField  = UIStackView()
//      var loginButton = UIButton()
//      var tapGestureRecognizer = UITapGestureRecognizer()
//      
//      override func viewDidLoad() {
//          super.viewDidLoad()
//          self.view.backgroundColor = .systemPink
//          startAnimation()
//          navigationController?.navigationBar.isHidden = true
//          setupUI()
//          NotificationCenter.default.addObserver(self, selector: #selector(showkeyboard), name: UIResponder.keyboardWillShowNotification, object: nil)
//          NotificationCenter.default.addObserver(self, selector: #selector(hidekeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
//          tapGestureRecognizer.addTarget(self, action: #selector(tapEndEdit))
//      }
//    
//    
//
//  
//      @objc func showkeyboard(notification : Notification){
//          guard let size = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect else{return}
//          bottomContraint.constant =  size.height
//          view.layoutIfNeeded()
//      }
//      @objc func hidekeyboard(){
//          bottomContraint.constant  = 0
//          view.layoutIfNeeded()
//          
//      }
//      @objc func tapEndEdit(sender: UITapGestureRecognizer){
//          view.endEditing(true)
//      }
//      
//      
//      func setupUI(){
//          view.addSubview(scrollView)
//          view.addGestureRecognizer(tapGestureRecognizer)
//          scrollView.addSubview(mainView)
//          mainView.addSubview(stackView)
//          stackView.addArrangedSubview(imageView)
//          stackView.addArrangedSubview(stackUserTextField)
//          stackUserTextField.addArrangedSubview(userTextField)
//          stackUserTextField.addArrangedSubview(passTextField)
//          stackUserTextField.addArrangedSubview(loginButton)
//          scrollView.translatesAutoresizingMaskIntoConstraints = false
//          scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0).isActive = true
//          scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0).isActive = true
//          bottomContraint = view.safeAreaLayoutGuide.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: 0)
//          scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0).isActive = true
//          bottomContraint.isActive = true
//          
//          //main view
//          mainView.translatesAutoresizingMaskIntoConstraints = false
//          mainView.snp.makeConstraints { make in
//              make.top.equalTo(scrollView.contentLayoutGuide.snp.top)
//              make.leading.equalTo(scrollView.contentLayoutGuide.snp.leading)
//              make.bottom.equalTo(scrollView.contentLayoutGuide.snp.bottom)
//              make.trailing.equalTo(scrollView.contentLayoutGuide.snp.trailing)
//              make.width.equalTo(scrollView.frameLayoutGuide.snp.width)
//              let heightConstraint = make.height.equalTo(scrollView.frameLayoutGuide.snp.height).priority(.low)
//          }
//
//          stackView.translatesAutoresizingMaskIntoConstraints = false
//          stackView.axis  = .vertical
//          stackView.spacing = 20
//          stackView.alignment = .fill
//          stackView.distribution = .fill
//          stackView.snp.makeConstraints { make in
//              make.top.greaterThanOrEqualTo(mainView).offset(10)
//              make.bottom.greaterThanOrEqualTo(stackView).offset(10)
//              make.trailing.equalTo(stackView).offset(10)
//              make.leading.equalTo(mainView).offset(10)
//              make.centerX.equalTo(mainView)
//              make.centerY.equalTo(mainView)
//          }
//          
//          
//          
//          
//          imageView.image = UIImage(systemName: "macpro.gen1.fill")
//          imageView.tintColor = .systemPink
//          imageView.contentMode  = .scaleAspectFit
//          imageView.heightAnchor.constraint(equalToConstant: 160).isActive = true
//          
//          stackUserTextField.translatesAutoresizingMaskIntoConstraints  = false
//          stackUserTextField.axis = .vertical
//          stackUserTextField.spacing = 40
//          stackUserTextField.alignment = .fill
//          stackUserTextField.distribution = .fill
//          
//          userTextField.placeholder = "Email or Phone"
//          userTextField.borderStyle = .roundedRect
//          userTextField.font = .boldSystemFont(ofSize: 12)
//          userTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
//          
//          
//          
//          passTextField.placeholder = "Password"
//          passTextField.borderStyle = .roundedRect
//          passTextField.font = .boldSystemFont(ofSize: 12)
//          
//          passTextField.borderStyle = .roundedRect
//          passTextField.layer.cornerRadius = 100
//          passTextField.isSecureTextEntry = true
//          passTextField.heightAnchor.constraint(equalToConstant: 60).isActive = true
//          
//          
//          loginButton.translatesAutoresizingMaskIntoConstraints = false
//          loginButton.setTitle("Login", for: .normal)
//          loginButton.backgroundColor = .systemPink
//          loginButton.setTitleColor(.white, for: .highlighted)
//          loginButton.layer.cornerRadius = 15
//          loginButton.addTarget(self, action: #selector(loginVC), for: .touchUpInside)
//          loginButton.heightAnchor.constraint(equalToConstant: 60).isActive =  true
//          
//          
//      }
//    fileprivate func startAnimation(){
//        let  loading = NVActivityIndicatorView(frame: .zero, type: .ballSpinFadeLoader, color: .lightGray, padding: 0)
//        loading.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loading)
//        NSLayoutConstraint.activate([
//            loading.widthAnchor.constraint(equalToConstant: 40),
//            loading.heightAnchor.constraint(equalToConstant: 40),
//            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
//        ])
//        loading.startAnimating()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 10){
//            loading.stopAnimating()
//        }
//    }
//    @objc func loginVC(_ sender: UIButton){
//        if(userTextField.text == ""){
//                return
//        }
//        let  loading = NVActivityIndicatorView(frame: .zero, type: .ballRotateChase, color: .systemBlue, padding: 0)
//        loading.translatesAutoresizingMaskIntoConstraints = false
//        view.addSubview(loading)
//        loading.snp.makeConstraints { make in
//            make.width.height.equalTo(40)
//            make.centerX.equalToSuperview()
//            make.centerY.equalToSuperview()
//        }
//        loading.startAnimating()
//        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 4){
//            loading.stopAnimating()
//            let user = self.userTextField.text ?? ""
//            let nav = ViewFromBNViewController()
//            let tabBaritem =  UITabBarController()
//            let home = UINavigationController(rootViewController: nav)
//            home.tabBarItem = UITabBarItem(title: "Home", image: UIImage(systemName: "house.fill"), tag: 0)
//            
//            
//            let Privacy = UINavigationController(rootViewController: SettingViewController())
//            Privacy.tabBarItem = UITabBarItem(title: "Privacy", image: UIImage(systemName: "lock.icloud.fill"), tag: 0)
//            
//            let appearance = UINavigationBarAppearance()
//            
//            tabBaritem.setViewControllers([home,Privacy], animated: true)
//            appearance.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.red]
//            
//            home.navigationBar.standardAppearance = appearance
//            
//            Privacy.navigationBar.standardAppearance = appearance
//            
//            home.navigationBar.barTintColor = UIColor.red
//            home.navigationBar.scrollEdgeAppearance = appearance
//            home.navigationBar.compactAppearance = appearance
//            home.navigationBar.tintColor = .red
//            tabBaritem.modalPresentationStyle = .fullScreen
//            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.red], for: .normal)
//            UITabBarItem.appearance().setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.systemPink], for: .selected)
//            
//            UserData.shared.username = user
//           
//            self.present(tabBaritem, animated: true)
//            
//            
//        }
//        
//        }
//          
//      
//  }
//
