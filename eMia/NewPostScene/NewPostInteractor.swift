//
//  NewPostInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 22/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class NewPostInteractor: NewPostInteractorProtocol {
   
   weak var input: NewPostInteracorInput!
   
   deinit {
      Log()
   }
   
   func save(_ completed: @escaping () -> Void) {
      guard let data = input.buildNewPostData() else {
         return
      }
      self.saveNewPost(data: data, completed)
   }
}

// MARK: - Private methods

extension NewPostInteractor {

   private func saveNewPost(data: NewPostData, _ completed: @escaping () -> Void) {
      guard let currentUser = gUsersManager.currentUser else {
         Alert.default.showOk("Error", message: "This operation accessible only for registered users!".localized)
         return
      }
      let title = data.title
      let image = data.image
      let bodyText = data.body
      let photosize = "\(image.size.width);\(image.size.height)"
      let newPost = PostModel(uid: currentUser.userId, author: currentUser.name, title: title, body: bodyText, photosize: photosize)
      newPost.synchronize { postid in
         if postid.isEmpty {
            Alert.default.showOk("Error".localized, message: "Failed to upload the photo on server. Please try it again.".localized)
         } else {
            gPhotosManager.uploadPhoto(image, for: postid) { success in
               if success {
                  completed()
               } else {
                  Alert.default.showOk("Error".localized, message: "Failed to create a new record on our server. Please try it again.".localized)
               }
            }
         }
      }
   }
}
