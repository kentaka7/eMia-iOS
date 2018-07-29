//
//  UsersObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

protocol FireBaseListener {
   func startListening()
}

class UsersObserver: FireBaseListener {
   lazy var dbRef = gDataBaseRef.child(UserFields.users)
   private let disposeBag = DisposeBag()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               UserModel.addUser(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               UserModel.deleteUser(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = UserItem(snapshot) {
               UserModel.editUser(item)
            }
         }).disposed(by: disposeBag)
   }
}
