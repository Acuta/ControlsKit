//
//  PageViewController.swift
//  ControlsKitExample
//
//  Created by Stéphane Copin on 5/18/17.
//  Copyright © 2017 Acuta. All rights reserved.
//

import Foundation
import ControlsKit

class PageViewController: ControlsKit.PageViewController {
	override func viewDidLoad() {
		super.viewDidLoad()

		let mainStoryboard = UIStoryboard(name: "Main", bundle: nil)
		self.viewControllers = [
			mainStoryboard.instantiateViewController(withIdentifier: "Switch"),
			mainStoryboard.instantiateViewController(withIdentifier: "PageControl"),
			mainStoryboard.instantiateViewController(withIdentifier: "NibView"),
		]
	}

	@IBAction func displayPagedTitleChanged(_ switch: UISwitch) {
		self.displayPagedTitleView = `switch`.isOn
	}
}
