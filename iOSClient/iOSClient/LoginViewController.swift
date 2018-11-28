//
//  ViewController.swift
//  iOSClient
//
//  Created by Milad on 11/21/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
  @IBOutlet weak var usernameTextField: UITextField!
  
  @IBOutlet weak var passwordTextField: UITextField!
  
  
  
  var username = "random \(Date().timeIntervalSinceNow)"
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self.view, action: Selector("endEditing:"))
    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
  }

  @IBAction func enterChat(_ sender: Any) {
    if usernameTextField.text != "" {
      username = usernameTextField.text!
      passwordTextField.isHidden = true
    } else {
      passwordTextField.isHidden = false
      let randomInt = Int.random(in: 0 ..< Int(Date().timeIntervalSince1970)/100000)
      username = "User-"+String(randomInt)
    }
    print(username)
  }
  @IBAction func createAccount(_ sender: Any) {
    
  }
  
}

