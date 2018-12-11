//
//  ViewController.swift
//  iOSClient
//
//  Created by Milad on 11/21/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit

protocol LoginViewControllerDelegate: AnyObject {
  func didTapCreateAccount(completion: @escaping (Error?) -> Void)
  func didTapLogin(with email: String, password: String, completion: @escaping (Error?) -> Void)
}

class LoginViewController: UIViewController {
  @IBOutlet weak var emailTextField: UITextField!
  @IBOutlet weak var passwordTextField: UITextField!
  
  let alert = UIAlertController(title: "An Error occured!", message: "", preferredStyle: .alert)
  let dismisAction = UIAlertAction(title: "Dismis", style: .cancel, handler: nil)
  
  weak var delegate: LoginViewControllerDelegate?
  
  init() {
    super.init(nibName: String(describing: LoginViewController.self), bundle: nil)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()

    let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
    tap.cancelsTouchesInView = false
    self.view.addGestureRecognizer(tap)
    
    alert.addAction(dismisAction)
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = true
  }
  
  deinit {
    print(self.nibName, #function)
  }
  
  func showError(message: String) {
    alert.message = message
    self.present(alert, animated: true)
  }
  
  @IBAction func enterChat(_ sender: Any) {
    print(self.nibName, #function)

    delegate!.didTapLogin(with: emailTextField.text!, password: passwordTextField.text!) {
      error in
      if error != nil {
        self.showError(message: "Login failed!")
      }
    }
  }
  
  @IBAction func createAccount(_ sender: Any) {
    print("create account clicked")
    delegate!.didTapCreateAccount() {
      error in
    }
  }
  
}

