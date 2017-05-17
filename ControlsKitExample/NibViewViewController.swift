//
//  NibViewViewController.swift
//  ControlsKitExample
//
//  Created by Stéphane Copin on 5/17/17.
//  Copyright © 2017 Acuta. All rights reserved.
//

import UIKit

class NibViewViewController: UIViewController {
	@IBOutlet private var headerView: HeaderView!

	override func viewDidLoad() {
		super.viewDidLoad()

		self.headerView.layer.borderColor = UIColor.red.cgColor
		self.headerView.layer.borderWidth = 2.0
	}
}
