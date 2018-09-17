//
//  EditPostViewModel.swift
//  eMia
//
//  Created by Sergey Krotkih on 11/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RealmSwift

class EditPostViewModel {
   
   private weak var post: PostModel!
   weak var view: EditPostEditor!
   var locationWorker: MyProfileLocationWorker?
   
   private let favoritsManager = FavoritsManager()
   private let postsManager = PostsManager()
   
   private var cell1: EditPost1ViewCell?
   private var token: NotificationToken?
   
   required init(post: PostModel) {
      self.post = post
      startFavoriteChangeStateListening()
   }

   deinit {
      token?.invalidate()
   }
   
   // Post dependency
   func configure(view: UITableViewCell, row: EditPostRows) {

      switch row {
      case .avatarPhotoAndUserName:
         let cell = view as! EditPost1ViewCell
         cell1 = cell
         if let user = gUsersManager.getUserWith(id: post.uid) {
            cell.setName(user.name)
         } else {
            cell.setName(nil)
         }
         gPhotosManager.downloadAvatar(for: post.uid) { image in
            DispatchQueue.main.async {
               cell.setPhotro(image)
            }
         }
         let isItMyFavoritePost = favoritsManager.isItMyFavoritePost(post)
         cell.setFavorite(isItMyFavoritePost)
         let isItMyPost = postsManager.isItMyPost(post)
         cell.setItIsMyPost(isItMyPost)
      case .dependsOnTextViewContent:
         let cell = view as! EditPost2ViewCell
         let height = cell.setBody(post.body)
         self.view.postBodyTextViewHeight = height
      case .photo:
         let cell = view as! EditPost6ViewCell
         post.getPhoto { image in
            cell.setImage(image)
         }
      case .staticTextAndSendEmailButton:
         let cell = view as! EditPost3ViewCell
         let text = "Created".localized + " " + post.relativeTimeToCreated()
         cell.setCreated(text)
      }
   }
   
   func addToFavoriteButtonPressed() {
      guard let post = self.post else {
         return
      }
      favoritsManager.addToFavorite(post: post)
   }

   private func startFavoriteChangeStateListening() {
      guard let postid = post?.id else {
         return
      }
      let realm = try? Realm()
      let results = realm?.objects(FavoriteModel.self).filter("postid = '\(postid)'") // Auto-Updating Results
      token = results?.observe({ [weak self] change in
         guard let `self` = self else {
             return
         }
         switch change {
         case .initial:
            let isItMyFavoritePost = self.favoritsManager.isItMyFavoritePost(self.post)
            self.cell1?.setFavorite(isItMyFavoritePost)
         case .error(let error):
            fatalError("\(error)")
         case .update( _,  _,  _, _):
            let isItMyFavoritePost = self.favoritsManager.isItMyFavoritePost(self.post)
            self.cell1?.setFavorite(isItMyFavoritePost)
         }
      })
   }
}
