//
//  EmptyStateView.swift
//  Active
//
//  Created by  Rauan Zhorabek   on 30/08/19.
//  Copyright © 2019  Rauan Zhorabek  . All rights reserved.
//

import UIKit

class EmptyStateView: UIView {

    // MARK: Properties

    /// The main label displaying the empty state message.
    @IBOutlet weak var emptyLabel: UILabel!

    /// The call to action button associated with the empty state.
    @IBOutlet weak var callToActionButton: RoundedButton!
}
