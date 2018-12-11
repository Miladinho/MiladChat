//
//  ChatroomViewController.swift
//  iOSClient
//
//  Created by Milad on 12/9/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import FirebaseAuth

class ChatroomViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    
    let logOutButton = UIBarButtonItem(title: "Logout", style: .plain, target: self, action: #selector(ChatroomViewController.logout) )
    self.navigationItem.leftBarButtonItem = logOutButton
  }
  
  override func viewWillAppear(_ animated: Bool) {
    self.navigationController?.navigationBar.isHidden = false
  }
  
  @objc func logout() {
    print(#function)
    print(Auth.auth().currentUser)
    do {
      try Auth.auth().signOut()
    } catch {
      print("ERROR OCCURED LOGGING OUT")
    }
  }
}
