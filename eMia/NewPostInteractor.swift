//
//  NewPostInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 22/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostInteractor: NewPostStoring {

   func saveNewPost(title: String, image: UIImage, body bodyText: String, _ completed: @escaping () -> Void) {
      guard let currentUser = gUsersManager.currentUser else {
         Alert.default.showOk("", message: "Only for registered users!".localized)
         return
      }
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
