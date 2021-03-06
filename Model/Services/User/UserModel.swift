//
//  UserModel.swift
//  eMia
//

import Foundation
import RealmSwift
import RxDataSources
import RxSwift
import RxRealm

final class UserModel: Object {

   @objc dynamic var userId: String = ""
   @objc dynamic var name: String = ""
   @objc dynamic var email: String = ""
   @objc dynamic var address: String?
   @objc dynamic var mGender: Int = 0
   @objc dynamic var yearbirth: Int = 0
   @objc dynamic var tokenIOS: String?
   @objc dynamic var tokenAndroid: String?

   override class func primaryKey() -> String? {
      return "userId"
   }
   
   var gender: Gender? {
      get {
         return Gender(rawValue: self.mGender)
      }
      set {
         self.mGender = newValue?.rawValue ?? 0
      }
   }
   
   convenience init(name: String, email: String, address: String?, gender: Gender?, yearbirth: Int?) {
      self.init()
      self.name = name
      self.email = email
      self.address = address
      self.mGender = gender == nil ? Gender.both.rawValue : gender!.rawValue
      self.yearbirth = yearbirth ?? 0
   }
   
   convenience init(userId: String, name: String, email: String, address: String?, gender: Gender?, yearbirth: Int?, tokenIOS: String?, tokenAndroid: String?) {
      self.init(name: name, email: email, address: address, gender: gender, yearbirth: yearbirth)
      self.userId = userId
      self.tokenIOS = tokenIOS
      self.tokenAndroid = tokenAndroid
   }
   
   convenience init(item: UserItem) {
      self.init(userId: item.userId, name: item.username, email: item.email, address: item.address, gender: Gender(rawValue: item.gender), yearbirth: item.yearbirth, tokenIOS: item.tokenIOS, tokenAndroid: item.tokenAndroid)
   }
   
   func copy(_ rhs: UserModel) {
      userId = rhs.userId
      name = rhs.name
      email = rhs.email
      address = rhs.address
      mGender = rhs.mGender
      yearbirth = rhs.yearbirth
      tokenIOS = rhs.tokenIOS
      tokenAndroid = rhs.tokenAndroid
   }
   
   static func registerUserWith(email: String) -> UserModel {
      let name = email.components(separatedBy: "@").first!
      let user = UserModel(name: name, email: email, address: nil, gender: nil, yearbirth: nil)
      return user
   }

   func synchronize(completion: @escaping (Bool) -> Void) {
      UserItem.save(self, completion: completion)
   }
}

extension UserModel: IdentifiableType {
   typealias Identity = String
   
   var identity: Identity {
      return userId
   }
}

func == (lhs: UserModel, rhs: UserModel) -> Bool {
   return lhs.userId == rhs.userId
}
