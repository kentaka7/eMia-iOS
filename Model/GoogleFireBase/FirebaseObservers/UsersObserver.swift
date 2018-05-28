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
   private var add = Variable<UserItem>(UserItem())
   private var update = Variable<UserItem>(UserItem())
   private var remove = Variable<UserItem>(UserItem())
   
   func addObserver() -> (add: Observable<UserItem>, update: Observable<UserItem>, remove: Observable<UserItem>) {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            self.add.value = item
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            self.remove.value = item
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            let item = UserItem(snapshot)
            self.update.value = item
         }).disposed(by: disposeBag)
      return (add.asObservable(), update.asObservable(), remove.asObservable())
   }
}
