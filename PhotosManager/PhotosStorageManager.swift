//
//  PhotosStorageManager.swift
//  eMia
//

import UIKit
import FirebaseStorage

class PhotosStorageManager: NSObject {

   class func downloadImage(for imageName: String, completion: @escaping (UIImage?) -> Void) {
      FirebaseImagesStorage.downloadImage(for: imageName, completion: completion)
   }

   class func removeImage(for name: String, completion: @escaping (Bool) -> Void) {
      FirebaseImagesStorage.removeImage(name: name, completion: completion)
   }
   
   class func uploadImage(_ image: UIImage, name: String, completion: @escaping (UIImage?) -> Void) {
      FirebaseImagesStorage.savePhoto(image, name: name) { image in
         completion(image)
      }
   }
   
   class func cleanCache(for name: String) {
      FirebaseImagesStorage.cleanCache(for: name)
   }
   
}
