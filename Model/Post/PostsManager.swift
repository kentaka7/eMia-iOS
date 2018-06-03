//
//  FavoritsManager.swift
//  eMia
//

import UIKit
import RxSwift

internal let PostsManager = PostsDataBaseInteractor.sharedInstance

class PostsDataBaseInteractor: NSObject {
   
   static let sharedInstance: PostsDataBaseInteractor = {
      let appDelegate = UIApplication.shared.delegate as! AppDelegate
      return appDelegate.postsManager
   }()
   
   // It isn't very good!
   var isFilterUpdated = Variable<Bool>(false)
}
