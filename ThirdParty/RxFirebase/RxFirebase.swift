//
//  RxFirebase.swift
//  eMia
//
//  Created by Сергей Кротких on 27/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift
import Firebase
import ObjectMapper

extension DatabaseQuery {
   
   func rx_observeSingleEvent(of event: DataEventType) -> Observable<DataSnapshot> {
      return Observable.create({ (observer) -> Disposable in
         self.observeSingleEvent(of: event, with: { (snapshot) in
            observer.onNext(snapshot)
            observer.onCompleted()
         }, withCancel: { (error) in
            observer.onError(error)
         })
         return Disposables.create()
      })
   }
   
   func rx_observeEvent(event: DataEventType) -> Observable<DataSnapshot> {
      return Observable.create({ (observer) -> Disposable in
         let handle = self.observe(event, with: { (snapshot) in
            observer.onNext(snapshot)
         }, withCancel: { (error) in
            observer.onError(error)
         })
         return Disposables.create {
            self.removeObserver(withHandle: handle)
         }
      })
   }
}

class RxPost: Mappable {
   var postId: String?
   var title: String?
   var content: String?
   var author: String?
   var likes: [String]?
   
   func mapping(map: Map) {
      postId <- map[RxPost.firebaseIdKey]
      title <- map["title"]
      content <- map["content"]
      author <- map["author"]
      likes <- (map["likes"], DictionaryKeyTransform())
   }
   required init?(map: Map) { }
}

func getPost(postId: String, completion:@escaping ((RxPost?) -> Void)) {
   let postRef = Database.database()
      .reference().child("posts").child("postId")
   postRef.observeSingleEvent(of: .value, with: { (snapshot) in
      guard !(snapshot.value is NSNull),
         var postDict = snapshot.value as? [String: Any]
         else { return }
      postDict["postId"] = snapshot.key
      completion(RxPost(JSON: postDict))
   })
}

extension BaseMappable {
   static var firebaseIdKey : String {
      get {
         return "FirebaseIdKey"
      }
   }
   init?(snapshot: DataSnapshot) {
      guard var json = snapshot.value as? [String: Any] else {
         return nil
      }
      json[Self.firebaseIdKey] = snapshot.key as Any
      
      self.init(JSON: json)
   }
}

class DictionaryKeyTransform: TransformType {
   typealias Object = [String]
   typealias JSON = [String: Bool]
   
   func transformFromJSON(_ value: Any?) -> [String]? {
      guard let v = value as? JSON else { return [String]() }
      return Array(v.keys)
   }
   
   func transformToJSON(_ value: [String]?) -> [String : Bool]? {
      return value?.reduce([String: Bool](), { (result, string) -> [String: Bool] in
         var dict = result
         dict[string] = true
         return dict
      })
   }
}


extension Mapper {
   func mapArray(snapshot: DataSnapshot) -> [N] {
      return snapshot.children.map { (child) -> N? in
         if let childSnap = child as? DataSnapshot {
            return N(snapshot: childSnap)
         }
         return nil
         //flatMap here is a trick
         //to filter out `nil` values
         }.flatMap { $0 }
   }
}

func getPosts(completion: @escaping (([RxPost]) -> Void)) {
   let postRef = Database.database().reference()
      .child("posts")
   postRef.observeSingleEvent(of: .value) { (snapshot) in
      completion(Mapper<RxPost>().mapArray(snapshot: snapshot))
   }
}
