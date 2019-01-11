//
//  User.swift
//  iOSClientTests
//
//  Created by Milad on 11/23/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import Foundation

//TODO: Rename user to namespaced class (SDWUser?) or extend User
struct Userr: Equatable {
  var username: String
  var email: String
  static func == (_ lhs: Userr, _ rhs: Userr) -> Bool {
    return lhs.username == rhs.username && lhs.email == rhs.email
  }
}
