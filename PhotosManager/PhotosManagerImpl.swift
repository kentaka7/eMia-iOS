//
//  PhotosManager.swift
//  eMia
//

import UIKit
import Firebase

internal let gPhotosManager = PhotosManagerImpl.sharedInstance

class PhotosManagerImpl: NSObject, AnyObservable {
   
   var observers: [Any] = []
   
   fileprivate var fetchingDataInProgress = true
   
   fileprivate var stopDownloading: Bool!
   
   static let sharedInstance: PhotosManagerImpl = {
      return AppDelegate.instance.avatarManager
   }()
   
   override init() {
      super.init()
      registerObserver()
   }
   
   func registerObserver() {
      let center = NotificationCenter.default
      let queue = OperationQueue.main
      
      observers.append(
         _ = center.addObserver(forName: Notification.Name(Notifications.WillEnterMainScreen), object: nil, queue: queue) { [weak self] notification in
            guard let `self` = self else {
               return
            }
            self.willEnterToMainScreen(notification)
         }
      )
   }
   
   deinit {
      unregisterObserver()
   }
   
   @objc func willEnterToMainScreen(_ notification: Notification) {
   }
   
   func smallAvatarName(_ user: UserModel) -> String {
      return "\(user.userId)"
   }
   
   public func removeAvatar(user: UserModel, completion: (Bool) -> Void) {
   }
}

extension PhotosManagerImpl {

   func downloadPhoto(for post: PostModel, completion: @escaping (UIImage?) -> Void) {
      guard let photoName = post.id else {
         completion(nil)
         return
      }
      PhotosStorageManager.downloadImage(for: photoName) { image in
         completion(image)
      }
   }

   func downloadAvatar(for userId: String, completion: @escaping (UIImage?) -> Void) {
      PhotosStorageManager.downloadImage(for: userId) { image in
         completion(image)
      }
   }
   
   func uploadPhoto(_ image: UIImage, for name: String, completion: @escaping (Bool) -> Void) {
      PhotosStorageManager.uploadImage(image, name: name) { image in
         completion(image != nil)
      }
   }
   
   func cleanPhotoCache(for user: UserModel) {
      let avatarFileName = user.userId
      PhotosStorageManager.cleanCache(for: avatarFileName)
   }
}
