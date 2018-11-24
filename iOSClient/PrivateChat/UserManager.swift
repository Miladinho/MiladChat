//
//  UserManager.swift
//  iOSClientTests
//
//  Created by Milad on 11/23/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import Foundation

enum Errors: Error {
  case InvalidInviteCode
}

protocol UserAuthService {
  func isValidInvite(code: String, completion: @escaping (Error?, Bool) -> Void)
  func getNewInviteCode()
}

class UserManager {
  private var AuthService : UserAuthService
  
  init (with authenticationService: UserAuthService) {
    self.AuthService = authenticationService
  }
  
  func createNewUser(withInvitationCode inviteCode: String, newUser: User, completion: @escaping (Error?, User?) -> Void) {
    
    AuthService.isValidInvite(code: inviteCode) { error, valid in
      if valid {
        completion(nil, newUser)
      } else {
        completion(Errors.InvalidInviteCode, nil)
      }
    }
  }
}
