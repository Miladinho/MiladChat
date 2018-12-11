import XCTest
@testable import iOSClient

class AccountCreationTests: XCTestCase {
  //let userManager : UserManager?
  
  class UserAuthSpy: AuthService {
    var inviteCode: String = "valid"
    func createUser(username: String, password: String, inviteCode: String, completion: @escaping (Error?, String?) -> Void) {
      if inviteCode.elementsEqual(self.inviteCode) {
        completion(nil, "auth-true")
      } else {
        completion(NSError(), nil)
      }
    }
  }
  func setup() {
  
  }
  func test_InvalidInviteCode_Returns_InvalidInviteCodeError() {
    let expectation = XCTestExpectation()
    let userManager = UserManager(with: UserAuthSpy())
    
    userManager.createUser(withInvitationCode: "invalidCode", username: "testuser", email: "test@test.com",password: "testpass"){ error, user in
      if let err = error {
        XCTAssertEqual(err as! Errors, Errors.InvalidInviteCode)
        XCTAssertNil(user)
      } else {
        XCTFail()
      }
      expectation.fulfill()
    }
  }

  func test_ValidInviteCode_Returns_UserObject() {
    let expectation = XCTestExpectation()
    let userManager = UserManager(with: UserAuthSpy())
    let username = "testuser"
    let password = "testpass"
    let expectedUser = User(username: username, email: password)
    
    userManager.createUser(withInvitationCode: "valid", username: username, email: "test@test.com",password: password) { error, user in
      XCTAssertEqual(user, expectedUser)
      XCTAssertNil(error)
      expectation.fulfill()
    }
  }
  
  /* App doesn't control invitation codes so this test is not necessary,
   keeping it still in order to study async test behavior (below test is false
   positive)
  */
//  func test_Reused_ValidInviteCode_Returns_InvalidInviteCodeError() {
//    let u = User(username: "", email: "")
//    let expectation = XCTestExpectation()
//
//    let validCode : String = "valid"
//
//    //let group = DispatchGroup()
//
//   // group.enter()
//    userManager.createNewUser(withInvitationCode: validCode, newUser: u) { error, user in
//      XCTAssertEqual(user, u)
//      print("op1")
//      //group.leave()
//          sleep(40) // should cause "op2" to be printed first?
//    }
//    //group.enter()
//    userManager.createNewUser(withInvitationCode: validCode, newUser: u) { error, user in
//      if let err = error {
//        XCTAssertEqual(err as! Errors, Errors.InvalidInviteCode)
//      } else {
//        XCTAssertFalse(true) //fail test gracefully
//      }
//      //group.leave()
//      print("op2")
//    }
//    //group.wait()
//    expectation.fulfill()
//  }
  
}

