//
//  CustomPresentAnimator.swift
//  Note001
//
//  Created by Sophors Pheng on 8/6/24.
//

import Foundation
import UIKit

class CustomPresentAnimator: NSObject, UIViewControllerAnimatedTransitioning {

    // Duration of the transition
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.3 // Adjust the duration as needed
    }

    // Animation block
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let toViewController = transitionContext.viewController(forKey: .to),
              let fromViewController = transitionContext.viewController(forKey: .from) else { return }

        let containerView = transitionContext.containerView
        
        // Initial and final frames
        let finalFrame = transitionContext.finalFrame(for: toViewController)
        let initialFrame = finalFrame.offsetBy(dx: -finalFrame.width, dy: 0)
        toViewController.view.frame = initialFrame
        
        containerView.addSubview(toViewController.view)
        
        // Perform the animation
        UIView.animate(withDuration: transitionDuration(using: transitionContext), animations: {
            toViewController.view.frame = finalFrame
        }, completion: { finished in
            transitionContext.completeTransition(finished)
        })
    }
}
