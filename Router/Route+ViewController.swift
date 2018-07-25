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
         if let navController = storyboard.instantiateInitialViewController() as? UINavigationController {
            return navController
         }
      case .gallery:
         let storyboard = UIStoryboard(name: Storyboards.gallery, bundle: nil)
         if let navController = storyboard.instantiateInitialViewController() as? UINavigationController {
            return navController
         }
         
      case .myProfile(let user, let password):
         let storyboard = UIStoryboard(name: Storyboards.myProfile, bundle: nil)
         if let viewController = storyboard.instantiateInitialViewController() as? MyProfileViewController {
            viewController.user = user
            viewController.password = password
            return viewController
         }
         
      case .settings, .filter, .newPost, .editPost:
         break
      }
      return UIViewController()
   }
}
