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
  var username = "random \(Date().timeIntervalSinceNow)"
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    print(view.frame.size)
  }

  @IBAction func enterChat(_ sender: Any) {
    if usernameTextField.text != "" {
      username = usernameTextField.text!
    } else {
      let randomInt = Int.random(in: 0 ..< Int(Date().timeIntervalSince1970)/100000)
      username = "User-"+String(randomInt)
    }
    print(username)
  }
  
}

