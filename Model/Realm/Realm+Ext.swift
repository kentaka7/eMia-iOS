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
      let message = "Realm opertation creating was finished with error:".localized
      let result = Realm.withRealm(message) { realm -> Observable<Object> in
         try realm.write {
            realm.add(model, update: true)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.creationFailed)
   }

   @discardableResult
   class func update(_ closure: () -> Void) -> Observable<Void> {
      let message = "Realm opertation updating was finished with error:".localized
      let result = Realm.withRealm(message) { realm -> Observable<Void> in
         try realm.write {
            closure()
         }
         return .empty()
      }
      return result ?? .error(RealmOperationsError.updatingFailed)
   }
   
   @discardableResult
   class func delete(model: Object) -> Observable<Object> {
      let message = "Realm opertation deleting was finished with error:".localized
      let result = Realm.withRealm(message) { realm -> Observable<Object> in
         try realm.write {
            realm.delete(model)
         }
         return .just(model)
      }
      return result ?? .error(RealmOperationsError.deletionFailed)
   }
   
   class func withRealm<T>(_ message: String, action: (Realm) throws -> T) -> T? {
      do {
         let realm = try Realm()
         return try action(realm)
      } catch let err {
         Alert.default.showError(message: "\(message)\n\(err)")
         return nil
      }
   }
}
