//
//  AuthCoordinator.swift
//  iOSClient
//
//  Created by Milad on 11/29/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol AuthCoordinatorDelegate: AnyObject {
  func didAuthenticate(coordinator: AuthCoordinator)
}

class AuthCoordinator {
  let navigationController: UINavigationController

  weak var delegate: AuthCoordinatorDelegate!
  var loginVC: LoginViewController?
  var createAccountVC: CreateAccountViewController?

  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    showLoginVC()
    print(AuthCoordinator.self, #function, self.delegate)
  }
  
  func showLoginVC() {
    loginVC = LoginViewController()
    loginVC!.delegate = self
    navigationController.pushViewController(loginVC!, animated: true)
  }
  
  func showCreateAccountVC() {
    createAccountVC = CreateAccountViewController()
    createAccountVC!.delegate = self
    navigationController.pushViewController(createAccountVC!, animated: true)
  }
  
  func dismissLoginVC() {
    loginVC?.delegate = nil
    loginVC = nil
    navigationController.dismiss(animated: true, completion: nil)
  }
}

extension AuthCoordinator: LoginViewControllerDelegate {
  func didTapLogin(with email: String, password: String, completion: @escaping (Error?) -> Void) {
    print("handling login request...")
    Auth.auth().signIn(withEmail: email, password: password) { [weak self] (result, error) in
      if error != nil {
        completion(error)
      } else if self != nil && self?.delegate != nil {
        self!.dismissLoginVC()
        self!.delegate.didAuthenticate(coordinator: self!)
        completion(nil)
      } else {
        completion(NSError(domain: "Fatal Error: Unwrapping optional would give nil.", code: 0, userInfo: nil))
      }
    }
  }
  
  func didTapCreateAccount(completion: @escaping (Error?) -> Void) {
    print("showing createAccount")
    showCreateAccountVC()
  }
}

extension AuthCoordinator: CreateAccountViewControllerDelegate {
    func didTapCreate(username: String, password: String, email: String, inviteCode: String, viewController: UIViewController) {
        print(username)
    }
}
