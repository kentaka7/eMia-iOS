//
//  Realm+Ext.swift
//  eMia
//
//  Created by Сергей Кротких on 30/07/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
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
   class func createRealm(model: Object) -> Observable<Object> {
      let result = Realm.withRealm("creating") { realm -> Observable<Object> in
         try realm.write {
            realm.add(model)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.creationFailed)
   }

   @discardableResult
   class func updateRealm(_ closure: () -> Void) -> Observable<Void> {
      let result = Realm.withRealm("updating") { realm-> Observable<Void> in
         try realm.write {
            closure()
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.updatingFailed)
   }

   @discardableResult
   class func update(model: Object) -> Observable<Void> {
      let result = Realm.withRealm("updating") { realm-> Observable<Void> in
         try realm.write {
            realm.add(model, update: true)
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.updatingFailed)
   }
   
   @discardableResult
   class func deleteRealm(model: Object) -> Observable<Void> {
      let result = Realm.withRealm("deleting") { realm-> Observable<Void> in
         try realm.write {
            realm.delete(model)
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.deletionFailed)
   }
   
   class func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
      do {
         let realm = try Realm()
         return try action(realm)
      } catch let err {
         print("Failed \(operation) realm with error: \(err)")
         return nil
      }
   }
}
