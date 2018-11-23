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
    
    XCTAssertThrowsError(try createNewUser(withInvitationCode: invalidCode, "", "", ""))
  }

  func test_ValidInvitationCode_ReturnsUserObject() {
    let validCode : String = "validCode"
    let username = "test"
    let password = "test"
    let email = "test@test.com"
    
    
    let user = User(username: username, email: email)
    XCTAssertEqual(try createNewUser(withInvitationCode: validCode, username, password, email), user)
  }
  
  // MARK: - Application code
  struct User: Equatable {
    var username: String
    var email: String
    static func ==(_ lhs: User, _ rhs: User) -> Bool {
      return lhs.username == rhs.username && lhs.email == rhs.email
    }
  }

  // refactor into seperate class or struct later
  func createNewUser(withInvitationCode validationCode: String, _ username: String, _ password: String, _ email: String) throws -> User {
    struct InvalidInviteCodeError: Error {} // create as part of enum later
    if validationCode == "validCode" {
      return User(username: username, email: email)
    }
    throw InvalidInviteCodeError()
  }
}
