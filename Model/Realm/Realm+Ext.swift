//
//  Realm+Ext.swift
//  eMia
//
//  Created by Sergey Krotkih on 30/07/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import Realm
import RealmSwift
import RxSwift

enum RealmOperationsError: Error {
   case creationFailed
   case deletionFailed
   case updatingFailed
}

extension Realm {
   
   @discardableResult
   class func create(model: Object) -> Observable<Object> {
      let errorDescription = "Realm. Failed to create a new record:".localized
      let result = Realm.withRealm(errorDescription) { realm -> Observable<Object> in
         try realm.write {
            realm.add(model, update: true)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.creationFailed)
   }

   @discardableResult
   class func update(_ closure: () -> Void) -> Observable<Void> {
      let errorDescription = "Realm. Failed to update a record:".localized
      let result = Realm.withRealm(errorDescription) { realm -> Observable<Void> in
         try realm.write {
            closure()
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.updatingFailed)
   }
   
   @discardableResult
   class func delete(model: Object) -> Observable<Object> {
      let errorDescription = "Realm. Failed to delete a record:".localized
      let result = Realm.withRealm(errorDescription) { realm -> Observable<Object> in
         try realm.write {
            realm.delete(model)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.deletionFailed)
   }
   
   class func withRealm<T>(_ prefixError: String, action: (Realm) throws -> T) -> T? {
      do {
         let realm = try Realm()
         return try action(realm)
      } catch let err {
         Alert.default.showError(message: "\(prefixError)\n\(err)")
         return nil
      }
   }
}
