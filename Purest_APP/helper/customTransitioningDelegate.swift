//
//  customTransitioningDelegate.swift
//  Note001
//
//  Created by Sophors Pheng on 8/6/24.
//

import Foundation
import UIKit

class CustomTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    func animationController(forPresentation controller: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomPresentAnimator()
    }
}
