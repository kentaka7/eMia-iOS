//
//  UsersObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

protocol FirebaseListener {
   func startListening()
}

class UsersObserver: FirebaseListener {
   lazy var dbRef = gDataBaseRef.child(UserItem.TableName)
   private let disposeBag = DisposeBag()
   private let localDB = LocalBaseController()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               self.localDB.addUser(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               self.localDB.deleteUser(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               self.localDB.editUser(item)
            }
         }).disposed(by: disposeBag)
   }
}
