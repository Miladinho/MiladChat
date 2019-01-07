//
//  AppCoordinator.swift
//  iOSClient
//
//  Created by Milad on 11/28/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import UIKit
import FirebaseAuth
import FirebaseMessaging

class AppCoordinator {
  let navigationController: UINavigationController
  var authCoordinator: AuthCoordinator?
  var chatCoordinator: ChatCoordinator?
  
  init(navigationController: UINavigationController) {
    self.navigationController = navigationController
  }
  
  func start(loggedIn: Bool) {
    if (Auth.auth().currentUser != nil) {
      showChat()
    } else {
      showAuthentication()
    }
  }
  
  func showAuthentication() {
    authCoordinator = AuthCoordinator(navigationController: navigationController)
    authCoordinator!.delegate = self
    authCoordinator!.start()
  }
   
  func showChat() {
    print("showing chat")
    chatCoordinator = ChatCoordinator(navigationController: navigationController)
    chatCoordinator!.delegate = self
    chatCoordinator!.start()
    
    Messaging.messaging().subscribe(toTopic: "pushNotifications") { error in
      if error != nil {
        print("error subscribing", error)
      } else {
        print("Subscribed to topic")
      }
    }
  }
}

extension AppCoordinator: AuthCoordinatorDelegate {
  func didAuthenticate(coordinator: AuthCoordinator) {
    print("AuthCoordinator did Authenticate")
    self.authCoordinator = nil
    self.navigationController.viewControllers.removeAll() // this is odd here, make a flow and clean nav on each flow change
    self.showChat()
  }
}

extension AppCoordinator: ChatCoordinatorDelegate {
  func didLogout(coordinator: ChatCoordinator) {
    chatCoordinator = nil
    self.navigationController.viewControllers.removeAll()
    self.showAuthentication()
  }
}
