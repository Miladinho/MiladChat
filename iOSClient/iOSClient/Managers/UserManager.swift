import Foundation

enum Errors: Error {
  case InvalidInviteCode
}

protocol AuthService {
  func createUser(username: String, password: String, inviteCode: String, completion: @escaping (_ error: Error?, _ authToken: String?) -> Void)
}

class UserManager {
  private var authService : AuthService
  
  init (with authenticationService: AuthService) {
    self.authService = authenticationService
  }
  
  func createUser(withInvitationCode inviteCode: String, username: String, email: String, password: String, completion: @escaping (Error?, Userr?) -> Void) {
    authService.createUser(username: username, password: password, inviteCode: inviteCode) {
      error, authToken in
      if let _ = error {
        completion(Errors.InvalidInviteCode, nil)
      } else {
        completion(nil, Userr(username: username, email: email))
      }
    }
  }

}
