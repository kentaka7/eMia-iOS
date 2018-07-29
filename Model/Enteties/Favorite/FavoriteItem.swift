//
//  FavoriteItem.swift
//  eMia
//

import UIKit
import Firebase
import RxSwift

// MARK: - FavoriteItem

class FavoriteItem: NSObject, NSCoding {
    
    var key: String
    var id: String
   
    var uid: String
    var postid: String
   
   let disposeBag = DisposeBag()
   
    override init() {
      self.key = ""
        self.id = ""
        self.uid = ""
        self.postid = ""
    }
    
    func encode(with coder: NSCoder) {
        coder.encode(id, forKey: FavoriteItemFields.id)
        coder.encode(uid, forKey: FavoriteItemFields.uid)
        coder.encode(postid, forKey: FavoriteItemFields.postid)
    }
    
    convenience required init(coder decoder: NSCoder) {
        self.init()
        self.id = decoder.decodeObject(forKey: FavoriteItemFields.id) as? String ?? ""
        self.uid = decoder.decodeObject(forKey: FavoriteItemFields.uid) as? String ?? ""
        self.postid = decoder.decodeObject(forKey: FavoriteItemFields.postid) as? String ?? ""
    }
    
   init(uid: String, postid: String, key: String? = nil, id: String? = nil) {
        self.key = key ?? ""
        self.id = id ?? ""
        self.uid = uid
        self.postid = postid
    }
    
    convenience init?(_ snapshot: DataSnapshot) {
      if var dict = snapshot.value as? [String: String] {
         self.init()
         key = snapshot.key
         id = dict[FavoriteItemFields.id] ?? ""
         uid = dict[FavoriteItemFields.uid] ?? ""
         postid = dict[FavoriteItemFields.postid] ?? ""
      } else {
         return nil
      }
    }
    
    func toDictionary() -> [String: Any] {
        return [
            FavoriteItemFields.id: id,
            FavoriteItemFields.uid: uid,
            FavoriteItemFields.postid: postid
        ]
    }
}

// MARK: - Save record

extension FavoriteItem {
    
    func synchronize(completion: @escaping (Bool) -> Void) {
        if self.key.isEmpty {
            save(completion: completion)
        } else {
            update(completion: completion)
        }
    }
    
    // Update exists data to Firebase Database
    private func update(completion: @escaping (Bool) -> Void) {
        let childUpdates = ["/\(FavoriteItemFields.favorits)/\(self.key)": self.toDictionary()]
        gDataBaseRef.updateChildValues(childUpdates, withCompletionBlock: { (_, _) in
            completion(true)
        })
    }
    
    // Save new data to Firebase Database
    private func save(completion: @escaping (Bool) -> Void) {
        let key = gDataBaseRef.child(FavoriteItemFields.favorits).childByAutoId().key
        self.key = key
        self.id = key
        update(completion: completion)
    }
    
    func remove() {
      if self.id.isEmpty {
         return
      }
      let recordRef = gDataBaseRef.child(FavoriteItemFields.favorits).child(self.id).queryOrdered(byChild: "\\")
      recordRef.observeSingleEvent(of: .value) { (snapshot) in
         let ref = snapshot.ref
         ref.removeValue()
      }
      
      /// It does not work:
      //      recordRef
      //         .rx
      //         .observeSingleEvent(.value)
      //         .subscribe(onNext: { snapshot in
      //            let ref = snapshot.ref
      //            ref.removeValue()
      //      }).disposed(by: disposeBag)

   }
}

// MARK: -

func == (lhs: FavoriteItem, rhs: FavoriteItem) -> Bool {
    let result = lhs.uid == rhs.uid && lhs.postid == rhs.postid
    return result
}
