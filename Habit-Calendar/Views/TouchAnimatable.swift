//
//  TouchAnimatable.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 22/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

/// Adds touch down / up animations to any conforming type.
protocol TouchAnimatable: AnyObject {

    var transform: CGAffineTransform { get set }

    /// Animates the button to display the touch down event.
    func animateBeginOfTouch()

    /// Animates the button to display the touch up event.
    func animateEndOfTouch()
}

extension TouchAnimatable {
    func animateBeginOfTouch() {
        UIViewPropertyAnimator(duration: 0.1, curve: .easeIn) {
            self.transform = CGAffineTransform(scaleX: 0.85, y: 0.85)
        }.startAnimation()
    }

    func animateEndOfTouch() {
        UIViewPropertyAnimator(duration: 0.5, dampingRatio: 0.3) {
            self.transform = CGAffineTransform.identity
        }.startAnimation()
    }
}
