//
//  BaseViewController.swift
//  Note001
//
//  Created by Sophors Pheng on 8/1/24.
//

import UIKit

class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTheme()
        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged), name: .themeChanged, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .themeChanged, object: nil)
    }
    
    @objc private func themeChanged() {
        setupTheme()
    }
    
    func setupTheme() {
        switch ThemeManager.shared.currentTheme {
        case .light:
            view.backgroundColor = .white
            // Update other UI elements for light theme
        case .dark:
            view.backgroundColor = .black
            // Update other UI elements for dark theme
        }
    }
}
