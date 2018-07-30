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
   
   @objc dynamic var key: String?
   @objc dynamic var id: String?
   @objc dynamic var uid: String = ""
   @objc dynamic var author: String = ""
   @objc dynamic var title: String = ""
   @objc dynamic var body: String = ""
   @objc dynamic var created: Double = 0
   @objc dynamic var photosize: String = ""
   @objc dynamic var starCount: Int = 0

   static var rxPosts = BehaviorSubject<[PostModel]>(value: [])
   
   override class func primaryKey() -> String? {
      return "id"
   }
   
   class var posts: [PostModel] {
      do {
         let realm = try Realm()
         let posts = realm.objects(PostModel.self)
         return posts.toArray()
      } catch let err {
         print("Failed read realm user data with error: \(err)")
         return []
      }
   }

   class func postsObservable() -> Observable<Results<PostModel>> {
      let result = Realm.withRealm("getting posts") { realm -> Observable<Results<PostModel>> in
         let realm = try Realm()
         let posts = realm.objects(PostModel.self)
         return Observable.collection(from: posts)
      }
      return result ?? .empty()
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
   
   convenience init(uid: String, author: String, title: String, body: String, photosize: String, starCount: Int = 0, created: Double? = nil, key: String? = nil, id: String? = nil) {
      self.init()
      self.key = key
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
      self.init(uid: item.uid, author: item.author, title: item.title, body: item.body, photosize: item.photosize, starCount: item.starCount, created: item.created, key: item.key, id: item.id)
   }
   
   func copy(_ rhs: PostModel) {
      key = rhs.key
      id = rhs.id
      uid = rhs.uid
      author = rhs.author
      title = rhs.title
      body = rhs.body
      created = rhs.created
      starCount = rhs.starCount
      photosize = rhs.photosize
   }
   
   class func isItMyPost(_ post: PostModel) -> Bool {
      guard let currentUser = gUsersManager.currentUser else {
         return false
      }
      return post.uid == currentUser.userId
   }
   
   class func getPost(with postId: String) -> PostModel? {
      return PostModel.posts.first(where: { $0.id == postId })
   }
}

extension PostModel {
   
   class func addPost(_ item: PostItem) {
      let model = PostModel(item: item)
      guard let modelId = model.id, !modelId.isEmpty else {
         return
      }
      if postsIndex(of: model) != nil {
         return
      }
      _ = Realm.createRealm(model: model)
      try? rxPosts.onNext(rxPosts.value() + [model])
   }
   
   class func deletePost(_ item: PostItem) {
      let post = PostModel(item: item)
      if let index = postsIndex(of: post) {
         let model = posts[index]
         Realm.deleteRealm(model: model)
         do {
            var array = try rxPosts.value()
            array.remove(at: index)
            rxPosts.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func editPost(_  item: PostItem) {
      let post = PostModel(item: item)
      if let index = postsIndex(of: post) {
         do {
            var array = try rxPosts.value()
            array[index] = post
            rxPosts.onNext(array)
         } catch {
            print(error)
         }
      }
   }
   
   class func postsIndex(of post: PostModel) -> Int? {
      let index = posts.index(where: {$0 == post})
      return index
   }
}

extension PostModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return id!
   }
}

extension PostModel {
   
   func synchronize(completion: @escaping (String) -> Void) {
      let postItem = PostItem(uid: uid, author: author, title: title, body: body, photosize: photosize, starCount: starCount, created: created)
      postItem.id = id ?? ""
      postItem.key = key ?? ""
      postItem.synchronize { _ in
         completion(postItem.id)
      }
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
