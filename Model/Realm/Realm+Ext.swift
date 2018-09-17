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
   
   func description() -> String {
      switch self {
      case .creationFailed:
        return "Realm: There is failed creating a new record!"
      case .deletionFailed:
        return "Realm: There is failed deleting a record!"
      case .updatingFailed:
        return "Realm: There is failed updating a record!"
      }
   }
}

extension Realm {
   
   @discardableResult
   class func create(model: Object) -> Observable<Object> {
      let result = Realm.withRealm("creating") { realm -> Observable<Object> in
         try realm.write {
            realm.add(model, update: true)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.creationFailed)
   }

   @discardableResult
   class func update(_ closure: () -> Void) -> Observable<Void> {
      let result = Realm.withRealm("updating") { realm -> Observable<Void> in
         try realm.write {
            closure()
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.updatingFailed)
   }
   
   @discardableResult
   class func delete(model: Object) -> Observable<Object> {
      let result = Realm.withRealm("deleting") { realm -> Observable<Object> in
         try realm.write {
            realm.delete(model)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.deletionFailed)
   }
   
   class func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
      do {
         let realm = try Realm()
         return try action(realm)
      } catch let err {
         print("Realm opertation \(operation) was finished with error: \(err)")
         return nil
      }
   }
}
