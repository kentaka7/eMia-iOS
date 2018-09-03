//
//  NewPostInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 22/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostInteractor: NewPostInteractorProtocol {
   
   deinit {
      Log()
   }
   
   func saveNewPost(data: NewPostData, _ completed: @escaping () -> Void) {
      guard let currentUser = gUsersManager.currentUser else {
         Alert.default.showOk("", message: "Only for registered users!".localized)
         return
      }
      let title = data.title
      let image = data.image
      let bodyText = data.body
      let photosize = "\(image.size.width);\(image.size.height)"
      let newPost = PostModel(uid: currentUser.userId, author: currentUser.name, title: title, body: bodyText, photosize: photosize)
      newPost.synchronize { postid in
         if postid.isEmpty {
            Alert.default.showOk("Somethig went wrong!".localized, message: "We can't upload a photo on server".localized)
         } else {
            gPhotosManager.uploadPhoto(image, for: postid) { success in
               if success {
                  completed()
               } else {
                  Alert.default.showOk("Somethig went wrong!".localized, message: "We can't create a new post on server".localized)
               }
            }
         }
      }
   }
}
