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
  func didLogout(coordinator: ChatCoordinator)
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
    let chatManager = ChatManager(path: ["channels", "main", "thread"].joined(separator: "/"))
    let chatroom = ChatroomViewController(user: Auth.auth().currentUser!, chatManager: chatManager)
    chatroom.delegate = self
    navigationController.pushViewController(chatroom, animated: true)
  }
}

extension ChatCoordinator: ChatroomViewControllerProtocol {
  func didtapLogout(completion: @escaping (Error?) -> Void) {
    do {
      try Auth.auth().signOut()
      completion(nil)
      delegate?.didLogout(coordinator: self)
    } catch {
      completion(error)
    }
  }
}
