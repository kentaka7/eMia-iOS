//
//  PostModel.swift
//  eMia
//

import UIKit

final class PostModel: NSObject, NSCoding {
   
   var ref: Any?
   var key: String?
   var id: String?
   var uid: String
   var author: String
   var title: String
   var body: String
   var created: Double
   var portrait: Bool
   var starCount: Int

   override init() {
      self.ref = nil
      self.key = nil
      self.id = nil
      self.uid = ""
      self.author = ""
      self.title = ""
      self.body = ""
      self.created = 0
      self.portrait = true
      self.starCount = 0
   }

   convenience init(coder decoder: NSCoder) {
      self.init()
      self.key = decoder.decodeObject(forKey: UserFields.key) as? String ?? ""
      self.id = decoder.decodeObject(forKey: PostItemFields.id) as? String ?? ""
      self.uid = decoder.decodeObject(forKey: PostItemFields.uid) as? String ?? ""
      self.author = decoder.decodeObject(forKey: PostItemFields.author) as? String ?? ""
      self.title = decoder.decodeObject(forKey: PostItemFields.title) as? String ?? ""
      self.body = decoder.decodeObject(forKey: PostItemFields.body) as? String ?? ""
      self.created = decoder.decodeObject(forKey: PostItemFields.created) as! TimeInterval
      self.portrait = decoder.decodeObject(forKey: PostItemFields.portrait) as? Bool ?? true
      self.starCount = decoder.decodeObject(forKey: PostItemFields.starCount) as? Int ?? 0
   }
   
   func encode(with coder: NSCoder) {
      coder.encode(key, forKey: PostItemFields.key)
      coder.encode(id, forKey: PostItemFields.id)
      coder.encode(uid, forKey: PostItemFields.uid)
      coder.encode(author, forKey: PostItemFields.author)
      coder.encode(title, forKey: PostItemFields.title)
      coder.encode(body, forKey: PostItemFields.body)
      coder.encode(created, forKey: PostItemFields.created)
      coder.encode(portrait, forKey: PostItemFields.portrait)
      coder.encode(starCount, forKey: PostItemFields.starCount)
   }
   
   convenience init(uid: String, author: String, title: String, body: String, portrait: Bool) {
      self.init()
      self.uid = uid
      self.author = author
      self.title = title
      self.body = body
      self.portrait = portrait
      self.created = Date().timeIntervalSince1970
   }
   
   init(postItem: PostItem) {
      self.ref = postItem.ref
      self.key = postItem.key
      self.id = postItem.id
      self.uid = postItem.uid
      self.author = postItem.author
      self.title = postItem.title
      self.body = postItem.body
      self.created = postItem.created
      self.starCount = postItem.starCount
      self.portrait = postItem.portrait
   }
   
   func copy(_ rhs: PostModel) {
      self.ref = rhs.ref
      self.key = rhs.key
      self.id = rhs.id
      self.uid = rhs.uid
      self.author = rhs.author
      self.title = rhs.title
      self.body = rhs.body
      self.created = rhs.created
      self.portrait = rhs.portrait
   }
}

extension PostModel {
   
   func synchronize(completion: @escaping (String) -> Void) {
      let postItem = PostItem(uid: uid, author: author, title: title, body: body, portrait: portrait, starCount: starCount, created: created)
      postItem.setRef(ref: ref)
      postItem.id = id ?? ""
      postItem.key = key ?? ""
      postItem.synchronize() { _ in
         completion(postItem.id)
      }
   }
}

func == (lhs: PostModel, rhs: PostModel) -> Bool {
   return lhs.id == rhs.id
}

extension PostModel {
   
   func relativeTimeToCreated() -> String {
      let date = Date(timeIntervalSince1970: self.created)
      return date.relativeTime
   }
   
   func getPhoto(completion: @escaping (UIImage?) -> Void) {
      PhotosManager.downloadPhoto(for: self) { image in
         completion(image)
      }
   }
   
}
