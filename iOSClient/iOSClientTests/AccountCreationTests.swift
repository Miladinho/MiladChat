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
  override func setUp() {
      // Put setup code here. This method is called before the invocation of each test method in the class.
  }

  override func tearDown() {
      // Put teardown code here. This method is called after the invocation of each test method in the class.
  }

  func test_InvalidInvitationCode_Throws_InvalidInviteCodeError() {
    let invalidCode : String = "invalidCode"
    let user = User(username: "", email: "")
    
    XCTAssertThrowsError(try createNewUser(withInvitationCode: invalidCode, user: user, password: "")) { error in
      XCTAssertEqual(error as! Errors, Errors.InvalidInviteCodeError)
    }
  }

  func test_ValidInvitationCode_ReturnsUserObject() {
    let validCode : String = "validCode"
    let username = "test"
    let password = "test"
    let email = "test@test.com"
    let user = User(username: username, email: email)
    
    XCTAssertEqual(try createNewUser(withInvitationCode: validCode, user: user, password: password), user)
  }
  
  
  // MARK: - Application code
  struct User: Equatable {
    var username: String
    var email: String
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
      return lhs.username == rhs.username && lhs.email == rhs.email
    }
  }
  
  enum Errors: Error {
    case InvalidInviteCodeError
  }

  // refactor into seperate class or struct later
  func createNewUser(withInvitationCode validationCode: String, user: User, password: String) throws -> User {
    if validationCode == "validCode" {
      return User(username: user.username, email: user.email)
    }
    throw Errors.InvalidInviteCodeError
  }
}
