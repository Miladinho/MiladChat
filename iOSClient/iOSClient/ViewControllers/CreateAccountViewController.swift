//
//  CreateAccountViewController.swift
//  iOSClient
//
//  Created by Milad on 11/28/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit

protocol CreateAccountViewControllerDelegate: AnyObject {
    func didTapCreate(username: String, password: String, email: String, inviteCode: String, completion: @escaping (Error?) -> Void)
}

class CreateAccountViewController: UIViewController {
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var invitationCodeTextField: UITextField!
    
    let alert = UIAlertController(title: "An Error occured!", message: "", preferredStyle: .alert)
    let dismisAction = UIAlertAction(title: "Dismis", style: .cancel, handler: nil)
    
    weak var delegate: CreateAccountViewControllerDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController!.navigationBar.isHidden = false
        self.navigationController!.navigationBar.tintColor = .black
        self.title = "Create Account"
        
        let tap = UITapGestureRecognizer(target: self.view, action: #selector(UIView.endEditing(_:)))
        tap.cancelsTouchesInView = false
        self.view.addGestureRecognizer(tap)
    }
    
    func showError(message: String) {
        alert.message = message
        alert.addAction(dismisAction)
        self.present(alert, animated: true)
    }
    
    func getValidStringValue(from textFieldValue: String?) -> String {
        if let text = textFieldValue { return text }
        return ""
    }
    
    @IBAction func createAccount(_ sender: Any) {
        let username : String = getValidStringValue(from: self.usernameTextField.text)
        let password : String = getValidStringValue(from: self.passwordTextField.text)
        let confPassword : String = getValidStringValue(from: self.confirmPasswordTextField.text)
        let email : String = getValidStringValue(from: self.emailTextField.text)
        let inviteCode : String = getValidStringValue(from: self.invitationCodeTextField.text)
        
        if confPassword != password {
            showError(message: "Passwords do not match!")
        } else {
            showLoadingHUD(for: self.view!, text: "Creating...")
            self.delegate!.didTapCreate(username: username, password: password, email: email, inviteCode: inviteCode) {
                [weak self] (error) in
                guard let self = self else { return }
                if let error = error {
                    self.showError(message: error.localizedDescription)
                }
                self.hideLoadingHUD(for: self.view)
            }
        }
    }
}
