//
//  UserItem.swift
//  eMia
//

import UIKit
import Firebase

class UserItem: NSObject {
   var key: String
   var userId: String
   var username: String
   var email: String
   var address: String
   var gender: Int
   var yearbirth: Int
   var tokenIOS: String
   var tokenAndroid: String

   override init() {
      self.key = ""
      self.userId = ""
      self.username = ""
      self.email = ""
      self.address = ""
      self.gender = 0
      self.yearbirth = 0
      self.tokenIOS = ""
      self.tokenAndroid = ""
      super.init()
   }
   
   init(user: UserModel) {
      self.key = user.key
      self.userId = user.userId
      self.username = user.name
      self.email = user.email
      self.address = user.address ?? ""
      self.gender = user.gender?.rawValue ?? 0
      self.yearbirth = user.yearbirth
      self.tokenIOS = user.tokenIOS ?? ""
      self.tokenAndroid = user.tokenAndroid ?? ""
   }
   
   convenience init?(_ snapshot: DataSnapshot) {
      if var snapshotValue = snapshot.value as? [String: AnyObject] {
         self.init()
         key = snapshot.key
         userId = snapshotValue[UserFields.userId] as? String ?? ""
         username = snapshotValue[UserFields.name] as? String ?? ""
         email = snapshotValue[UserFields.email] as? String ?? ""
         address = snapshotValue[UserFields.address] as? String ?? ""
         gender = snapshotValue[UserFields.gender] as? Int ?? 0
         if let stringYear = snapshotValue[UserFields.yearbirth] as? String {
            yearbirth = Int(stringYear)!
         } else {
            yearbirth = snapshotValue[UserFields.yearbirth] as? Int ?? 0
         }
         tokenIOS = snapshotValue[UserFields.tokenIOS] as? String ?? ""
         tokenAndroid = snapshotValue[UserFields.tokenAndroid] as? String ?? ""
      } else {
         return nil
      }
   }
   
   func toDictionary() -> [String: Any] {
      return [
         UserFields.userId: userId,
         UserFields.name: username,
         UserFields.email: email,
         UserFields.address: address,
         UserFields.gender: gender,
         UserFields.yearbirth: yearbirth,
         UserFields.tokenIOS: tokenIOS,
         UserFields.tokenAndroid: tokenAndroid
      ]
   }
}

func == (lhs: UserItem, rhs: UserItem) -> Bool {
   return lhs.userId == rhs.userId && lhs.email.lowercased() == rhs.email.lowercased()
}

// MARK: - Update data on server

extension UserItem {

   func synchronize(completion: @escaping (Bool) -> Void) {
      update(completion: completion)
   }
   
   // Update exists data to Firebase Database
   private func update(completion: @escaping (Bool) -> Void) {
      let childUpdates = ["/\(UserFields.users)/\(self.userId)": self.toDictionary()]
      gDataBaseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, _) in
         if let error = error {
            print("Error while synchronize user item: \(error.localizedDescription)")
            completion(false)
         } else {
            completion(true)
         }
      })
   }
   
   func remove() {
      if self.userId.isEmpty {
         return
      }
      let recordRef = gDataBaseRef.child(UserFields.users).child(self.userId).queryOrdered(byChild: "\\")
      recordRef.observeSingleEvent(of: .value) { (snapshot) in
         let ref = snapshot.ref
         ref.removeValue()
      }
   }
}
