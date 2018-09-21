//
//  UserItem.swift
//  eMia
//

import UIKit
import Firebase

class UserItem: FirebaseStorable {

   static let TableName = "users"
   
   var tableName: String {
      return UserItem.TableName
   }
   
   struct Fields {
      static let userId = "id"
      static let name = "username"
      static let email = "email"
      static let address = "address"
      static let gender = "gender"
      static let yearbirth = "yearbirth"
      static let tokenIOS = "tokenIOS"
      static let tokenAndroid = "tokenAndroid"
   }

   var userId: String
   var username: String
   var email: String
   var address: String
   var gender: Int
   var yearbirth: Int
   var tokenIOS: String
   var tokenAndroid: String

   init() {
      self.userId = ""
      self.username = ""
      self.email = ""
      self.address = ""
      self.gender = 0
      self.yearbirth = 0
      self.tokenIOS = ""
      self.tokenAndroid = ""
   }
   
   init(_ user: UserModel) {
      self.userId = user.userId
      self.username = user.name
      self.email = user.email
      self.address = user.address ?? ""
      self.gender = user.gender?.rawValue ?? 0
      self.yearbirth = user.yearbirth
      self.tokenIOS = user.tokenIOS ?? ""
      self.tokenAndroid = user.tokenAndroid ?? ""
   }
   
   required convenience init?(_ snapshot: DataSnapshot) {
      guard
         let snapshotValue = snapshot.value as? [String: AnyObject],
         let id = snapshotValue[UserItem.Fields.userId] as? String,
         let username = snapshotValue[UserItem.Fields.name] as? String,
         let email = snapshotValue[UserItem.Fields.email] as? String
         else {
            return nil
      }
      self.init()
      self.userId = id
      self.username = username
      self.email = email
      self.address = snapshotValue[UserItem.Fields.address] as? String ?? ""
      self.gender = snapshotValue[UserItem.Fields.gender] as? Int ?? 0
      if let stringYear = snapshotValue[UserItem.Fields.yearbirth] as? String {
         self.yearbirth = Int(stringYear)!
      } else {
         self.yearbirth = snapshotValue[UserItem.Fields.yearbirth] as? Int ?? 0
      }
      self.tokenIOS = snapshotValue[UserItem.Fields.tokenIOS] as? String ?? ""
      self.tokenAndroid = snapshotValue[UserItem.Fields.tokenAndroid] as? String ?? ""
   }
   
   func toDictionary() -> [String: Any] {
      return [
         UserItem.Fields.userId: userId,
         UserItem.Fields.name: username,
         UserItem.Fields.email: email,
         UserItem.Fields.address: address,
         UserItem.Fields.gender: gender,
         UserItem.Fields.yearbirth: yearbirth,
         UserItem.Fields.tokenIOS: tokenIOS,
         UserItem.Fields.tokenAndroid: tokenAndroid
      ]
   }
   
   func primaryKey() -> String {
      return self.userId
   }
   
   func setPrimaryKey(_ key: String) {
      self.userId = key
   }
}
