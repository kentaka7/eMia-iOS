//
//  UsersObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class UsersObserver: NSObject {
   lazy var dbRef = FireBaseManager.firebaseRef.child(UserFields.users)
   private let disposeBag = DisposeBag()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            UserModel.addUser(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            UserModel.deleteUser(item)
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            UserModel.editUser(item)
         }).disposed(by: disposeBag)
   }
}
