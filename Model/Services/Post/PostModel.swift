//
//  PostModel.swift
//  eMia
//

import UIKit
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class PostModel: Object {
   
   @objc dynamic var id: String?
   @objc dynamic var uid: String = ""
   @objc dynamic var author: String = ""
   @objc dynamic var title: String = ""
   @objc dynamic var body: String = ""
   @objc dynamic var created: Double = 0
   @objc dynamic var photosize: String = ""
   @objc dynamic var starCount: Int = 0
   
   override class func primaryKey() -> String? {
      return "id"
   }
   
   var photoSize: (CGFloat, CGFloat) {
      get {
         if photosize.isEmpty {
            return (0.0, 0.0)
         } else {
            let arr = photosize.split(separator: ";")
            if arr.count == 2, let width = Double(arr[0]), let height = Double(arr[1]) {
               return (CGFloat(width), CGFloat(height))
            } else {
               return (0.0, 0.0)
            }
         }
      }
      set {
         photosize = "\(newValue.0);\(newValue.1)"
      }
   }
   
   convenience init(uid: String, author: String, title: String, body: String, photosize: String, starCount: Int = 0, created: Double? = nil, id: String? = nil) {
      self.init()
      self.id = id
      self.uid = uid
      self.author = author
      self.title = title
      self.body = body
      self.photosize = photosize
      self.starCount = starCount
      self.created = created ?? Date().timeIntervalSince1970
   }
   
   convenience init(item: PostItem) {
      self.init(uid: item.uid, author: item.author, title: item.title, body: item.body, photosize: item.photosize, starCount: item.starCount, created: item.created, id: item.id)
   }
   
   func copy(_ rhs: PostModel) {
      id = rhs.id
      uid = rhs.uid
      author = rhs.author
      title = rhs.title
      body = rhs.body
      created = rhs.created
      starCount = rhs.starCount
      photosize = rhs.photosize
   }
   
   func synchronize(completion: @escaping (String) -> Void) {
      PostItem.save(self, completion: completion)
   }
}

// We use the IdentifiableType to have a possibility
// to use RxDataSources in the Posts collection view

extension PostModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return id!
   }
}

extension PostModel {
   
   func relativeTimeToCreated() -> String {
      let date = Date(timeIntervalSince1970: self.created)
      return date.relativeTime
   }
   
   func getPhoto(completion: @escaping (UIImage?) -> Void) {
      gPhotosManager.downloadPhoto(for: self) { image in
         completion(image)
      }
   }
}

func == (lhs: PostModel, rhs: PostModel) -> Bool {
   return lhs.id == rhs.id
}
