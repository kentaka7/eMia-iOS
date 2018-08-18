//
//  CommentsManager.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift
import RealmSwift

class CommentsManager: NSObject {

   private var post: PostModel?

   var comments: [CommentModel] {
      do {
         let realm = try Realm()
         let comms = realm.objects(CommentModel.self)
         return comms.toArray()
      } catch _ {
         return []
      }
   }
   
}
