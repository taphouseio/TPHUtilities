//
//  ActivityIndicatorViewController.swift
//  Utilities
//
//  Created by Jared Sorge on 4/26/20.
//

import UIKit

/// A view controller that shows an activity indicator in the center.
public final class ActivityIndicatorViewController: BaseViewController {
    public override func viewDidLoad() {
        super.viewDidLoad()

        let hud = ActivityHUD()
        hud.showInView(view)
    }
}
