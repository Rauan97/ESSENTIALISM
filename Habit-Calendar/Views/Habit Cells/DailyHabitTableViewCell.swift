//
//  DailyHabitTableViewCell.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 29/08/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

/// A UITableViewCell displaying the habits that are daily (don't have an active challenge of days).
class DailyHabitTableViewCell: UITableViewCell {

    // MARK: Properties

    /// The view displaying the habit's color.
    @IBOutlet weak var colorView: RoundedView!

    /// The label displaying the habit's name.
    @IBOutlet weak var nameLabel: UILabel!

    // MARK: Life cycle

    override func layoutSubviews() {
        super.layoutSubviews()
        colorView.cornerRadius = colorView.frame.size.height / 2
    }
}
