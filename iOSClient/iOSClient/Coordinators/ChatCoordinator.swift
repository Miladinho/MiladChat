//
//  ChatCoordinator.swift
//  iOSClient
//
//  Created by Milad on 12/9/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import FirebaseAuth

protocol ChatCoordinatorDelegate: AnyObject {
  
}

class ChatCoordinator {
  let navigationController: UINavigationController
  
  weak var delegate: ChatCoordinatorDelegate?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start() {
    showChatroomVC()
  }
  
  func showChatroomVC() {
    let chatroom = ChatroomViewController()
    // chatroom.delegate = self
    navigationController.pushViewController(chatroom, animated: true)
  }
}
