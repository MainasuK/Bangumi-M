//
//  LoginViewPresentTransition.swift
//  Percolator
//
//  Created by Cirno MainasuK on 2017-7-30.
//  Copyright © 2017年 Cirno MainasuK. All rights reserved.
//

import UIKit

class LoginViewPresentTransition: NSObject, UIViewControllerAnimatedTransitioning {

    let blurEffect = UIBlurEffect(style: .light)
    var blurEffectView: UIVisualEffectView?

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return 0.5
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        transitionAnimator(using: transitionContext).startAnimation()
    }

    func transitionAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        let duration = transitionDuration(using: transitionContext)
        let container = transitionContext.containerView
        guard let to = transitionContext.view(forKey: .to) else {
            let from = transitionContext.view(forKey: .from)!
            let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
            animator.addAnimations(self.blurAnimations(false))
            animator.addAnimations { from.alpha = 0 }

            animator.addCompletion { _ in
                transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
            }
            return animator
        }

        to.alpha = 0

        setupBlurView(in: container)
        container.addSubview(to)

        let animator = UIViewPropertyAnimator(duration: duration, curve: .easeOut)
        animator.addAnimations({ to.alpha = 1.0 }, delayFactor: 0.5)
        animator.addAnimations(blurAnimations(true))
        animator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }

        return animator
    }

    private func setupBlurView(in view: UIView) {
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = view.bounds
        blurEffectView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        blurEffectView.translatesAutoresizingMaskIntoConstraints = true
        blurEffectView.isUserInteractionEnabled = false

        view.addSubview(blurEffectView)
        view.sendSubview(toBack: blurEffectView)

        // Autolayout blurEffectView
        let leading = NSLayoutConstraint(item: blurEffectView, attribute: .leading, relatedBy: .equal, toItem: view, attribute: .leading, multiplier: 1, constant: 0)
        let trailing = NSLayoutConstraint(item: blurEffectView, attribute: .trailing, relatedBy: .equal, toItem: view, attribute: .trailing, multiplier: 1, constant: 0)
        let top = NSLayoutConstraint(item: blurEffectView, attribute: .top, relatedBy: .equal, toItem: view, attribute: .top, multiplier: 1.0, constant: 0.0)
        let bottom = NSLayoutConstraint(item: blurEffectView, attribute: .bottom, relatedBy: .equal, toItem: view, attribute: .bottom, multiplier: 1.0, constant: 0)
        blurEffectView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([leading, trailing, top, bottom])

        self.blurEffectView = blurEffectView
    }

    func blurAnimations(_ blurred: Bool) -> () -> Void {
        return {
            self.blurEffectView?.effect = blurred ? self.blurEffect : nil
        }
    }

}
