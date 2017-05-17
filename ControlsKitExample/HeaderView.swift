//
//  HeaderView.swift
//  ControlsKitExample
//
//  Created by Stéphane Copin on 5/17/17.
//  Copyright © 2017 Stéphane Copin. All rights reserved.
//

import UIKit
import ControlsKit

class HeaderView: CTKNibView {
	@IBOutlet var titleLabel: UILabel!
	@IBOutlet var subtitleLabel: UILabel!

	@IBInspectable var title: String? {
		didSet {
			self.titleLabel?.text = self.title
		}
	}

	@IBInspectable var subtitle: String? {
		didSet {
			self.subtitleLabel?.text = self.subtitle
		}
	}

	override func awakeFromNib() {
		super.awakeFromNib()

		self.titleLabel.text = self.title
		self.subtitleLabel.text = self.subtitle
	}
}
