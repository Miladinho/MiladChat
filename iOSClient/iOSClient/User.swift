//
//  User.swift
//  iOSClientTests
//
//  Created by Milad on 11/23/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import Foundation

struct User: Equatable {
  var username: String
  var email: String
  static func ==(_ lhs: User, _ rhs: User) -> Bool {
    return lhs.username == rhs.username && lhs.email == rhs.email
  }
}
