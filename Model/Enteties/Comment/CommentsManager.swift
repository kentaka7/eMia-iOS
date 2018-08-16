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

extension CommentsManager {
   
   func addComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if !item.id.isEmpty {
         _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
         }, onError: { error in
            Alert.default.showError(message: error.localizedDescription)
         })
      }
   }
   
   func deleteComment(_ item: CommentItem) {
      let model = CommentModel(item: item)
      if let index = commentIndex(of: model) {
         let model = comments[index]
         Realm.delete(model: model)
      }
   }
   
   func editComment(_  item: CommentItem) {
      addComment(item)
   }
   
   private func commentIndex(of model: CommentModel) -> Int? {
      let index = comments.index(where: {$0 == model})
      return index
   }
}
