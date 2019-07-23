//
//  ProgressDisplayable.swift
//  Habit-Calendar
//
//  Created by  Rauan Zhorabek   on 19/02/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

protocol ProgressDisplayable {

    // MARK: Properties

    /// The main color of the progress view.
    var tint: UIColor? { get set }

    /// The progress (from 0 to 1) to be displayed by the view.
    var progress: CGFloat { get set }

    // MARK: Imperatives

    /// Draws the view, showing its progress.
    func drawProgress()
}
