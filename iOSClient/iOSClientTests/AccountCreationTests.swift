import XCTest
@testable import iOSClient

class AccountCreationTests: XCTestCase {
  let accountManager = AccountManager(with: UserAuthSpy())
  
  class UserAuthSpy: APIService {
    var inviteCode: String = "valid"
    func createUser(code: String, completion: @escaping (Error?, Bool) -> Void) {
      if inviteCode.elementsEqual(code) {
        completion(nil, true)
      } else {
        completion(NSError(), false)
      }
    }
  }
  
  func test_InvalidInviteCode_Returns_InvalidInviteCodeError() {
    let u = User(username: "", email: "")
    
    let expectation = XCTestExpectation()
    let invalidCode: String = "invalidCode"
    accountManager.createNewUser(withInvitationCode: invalidCode, newUser: u) { error, user in
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
    let u = User(username: "test", email: "test@test.com")
    let validCode: String = "valid"
    
    let expectation = XCTestExpectation()
    accountManager.createNewUser(withInvitationCode: validCode, newUser: u) { error, user in
      XCTAssertEqual(user, u)
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

