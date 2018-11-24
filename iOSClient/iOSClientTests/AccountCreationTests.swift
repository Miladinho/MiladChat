//
//  iOSClientTests.swift
//  iOSClientTests
//
//  Created by Milad on 11/21/18.
//  Copyright © 2018 Milad. All rights reserved.
//

import XCTest
@testable import iOSClient

class AccountCreationTests: XCTestCase {
  
  class UserAuthSpy: UserAuthService {
    var validCode: String = "valid"
    func isValidInvite(code: String, completion: @escaping (Error?, Bool) -> Void) {
      validCode.elementsEqual(code) ? completion(nil, true): completion(Errors.InvalidInviteCode, false)
    }
    func getNewInviteCode() {
      
    }
  }
  
  let userManager = UserManager(with: UserAuthSpy())
  
  func test_InvalidInvitationCode_Returns_InvalidInviteCodeError() {
    let invalidCode: String = "invalidCode"
    let u = User(username: "", email: "")
    
    let expectation = XCTestExpectation()
    
    userManager.createNewUser(withInvitationCode: invalidCode, newUser: u) { error, user in
      XCTAssertEqual(error as! Errors, Errors.InvalidInviteCode)
      XCTAssertNil(user)
      expectation.fulfill()
    }
  }

  func test_ValidInvitationCode_Returns_UserObject() {
    let validCode : String = "valid"
    let u = User(username: "test", email: "test@test.com")

    userManager.createNewUser(withInvitationCode: validCode, newUser: u) { error, user in
      XCTAssertEqual(user, u)
      XCTAssertNil(error)
    }
  }

//  func test_Reused_ValidInvitationCode_Returns_InvalidInviteCodeError() {
//    let validCode : String = userManager.getNewInviteCode()
//    let u = User(username: "", email: "")
//
//    let expectation = XCTestExpectation()
//    userManager.createNewUser(withInvitationCode: validCode, newUser: u) { error, user in
//      XCTAssertEqual(user, u)
//    }
//
//    userManager.createNewUser(withInvitationCode: validCode, newUser: u) { err, usr in
//
//      XCTAssertEqual(err as! Errors, Errors.InvalidInviteCode)
//      expectation.fulfill()
//    }
//  }
  
}

