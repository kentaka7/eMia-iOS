//
//  UsersObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class UsersObserver: NSObject {

   fileprivate var _refHandleForAdd: DatabaseHandle?
   fileprivate var _refHandleForRemove: DatabaseHandle?
   fileprivate var _refHandleForChange: DatabaseHandle?
   
   lazy var dbRef = FireBaseManager.firebaseRef.child(UserFields.users)
   private let disposeBag = DisposeBag()
   
   func addObserver() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            ModelData.addUserListener(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            ModelData.deleteUserListener(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            ModelData.editUserListener(item)
         }).disposed(by: disposeBag)
   }

   private func oldObserver() {
      removeObserver()
      
      // Listen for new users in the Firebase database
      _refHandleForAdd = dbRef.observe(.childAdded, with: { (snapshot) -> Void in
         let item = UserItem(snapshot)
         ModelData.addUserListener(item)
      })
      // Listen for deleted users in the Firebase database
      _refHandleForRemove = dbRef.observe(.childRemoved, with: { (snapshot) -> Void in
         let item = UserItem(snapshot)
         ModelData.deleteUserListener(item)
      })
      // Listen for changed users in the Firebase database
      _refHandleForChange = dbRef.observe(.childChanged, with: {(snapshot) -> Void in
         let item = UserItem(snapshot)
         ModelData.editUserListener(item)
      })
   }
   
   func removeObserver() {
      if let _ = _refHandleForAdd, let _ = _refHandleForRemove, let _ = _refHandleForChange {
         FireBaseManager.firebaseRef.child(UserFields.users).removeObserver(withHandle: _refHandleForAdd!)
         FireBaseManager.firebaseRef.child(UserFields.users).removeObserver(withHandle: _refHandleForRemove!)
         FireBaseManager.firebaseRef.child(UserFields.users).removeObserver(withHandle: _refHandleForChange!)
      }
   }
}
