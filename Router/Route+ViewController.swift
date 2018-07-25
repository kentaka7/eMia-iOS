import UIKit

extension Route {

   struct Storyboards {
      static let main = "Main"
      static let gallery = "Gallery"
      static let login = "Login"
      static let myProfile = "ProfileEditor"
   }
   
  func viewController() -> UIViewController {
    switch self {
    case .login:
      let storyboard = UIStoryboard(name: Storyboards.login, bundle: nil)
      let nc = storyboard.instantiateInitialViewController() as! UINavigationController
      return nc

    case .gallery:
      let storyboard = UIStoryboard(name: Storyboards.gallery, bundle: nil)
      let nc = storyboard.instantiateInitialViewController() as! UINavigationController
      return nc

    case .settings:
      return UIViewController()
      
    case .myProfile(let user, let password):
      let storyboard = UIStoryboard(name: Storyboards.myProfile, bundle: nil)
      let vc = storyboard.instantiateInitialViewController() as! MyProfileViewController
      vc.user = user
      vc.password = password
      return vc

    case .filter:
      return UIViewController()
      
    case .newPost:
      return UIViewController()
      
    case .editPost:
      return UIViewController()
      
   }
  }
}
