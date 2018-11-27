import Foundation

enum Errors: Error {
  case InvalidInviteCode
}

protocol APIService {
  func createUser(code: String, completion: @escaping (Error?, Bool) -> Void)
}

class UserManager {
  private var AuthService : APIService
  
  init (with authenticationService: APIService) {
    self.AuthService = authenticationService
  }
  
  func create(withInvitationCode inviteCode: String, newUser: User, completion: @escaping (Error?, User?) -> Void) {
    AuthService.createUser(code: inviteCode) { error, valid in
      if valid {
        completion(nil, newUser)
      } else {
        completion(Errors.InvalidInviteCode, nil)
      }
    }
  }

}
