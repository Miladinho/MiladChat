//
//  LoadingView.swift
//  iOSClient
//
//  Created by Milad on 12/10/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import Foundation
import MBProgressHUD

extension UIViewController {
    func showLoadingHUD(for viewController: UIView, text: String) {
        let hud = MBProgressHUD.showAdded(to: viewController, animated: true)
        hud.label.text = text
        viewController.isUserInteractionEnabled = false
    }
    
    func hideLoadingHUD(for viewController: UIView) {
        MBProgressHUD.hide(for: viewController, animated: true)
        viewController.isUserInteractionEnabled = true
    }
}
