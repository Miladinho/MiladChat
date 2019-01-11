//
//  ViewController.swift
//  iOSClient
//
//  Created by Milad on 11/21/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import MBProgressHUD

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
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    deinit {
        print("Deinit Login")
    }
    
    func showError(message: String) {
        alert.message = message
        alert.addAction(dismisAction)
        self.present(alert, animated: true)
    }
    
    @IBAction func enterChat(_ sender: Any) {
        showLoadingHUD(for: self.view!, text: "Logging in...")
        delegate!.didTapLogin(with: emailTextField.text!, password: passwordTextField.text!) { [weak self] error in
            guard let self = self else { return }
            if error != nil {
                self.showError(message: "Login failed!")
            }
            self.hideLoadingHUD(for: self.view)
        }
    }
    
    @IBAction func createAccount(_ sender: Any) {
        delegate!.didTapCreateAccount() { error in
            if let error = error {
                self.showError(message: error.localizedDescription)
            }
        }
    }
}
