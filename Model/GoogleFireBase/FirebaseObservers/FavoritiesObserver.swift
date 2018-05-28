//
//  FavoritiesObserver.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class FavoritiesObserver: NSObject {
   lazy var dbRef = FireBaseManager.firebaseRef.child(FavoriteItemFields.favorits)
   private let disposeBag = DisposeBag()

   private var add = Variable<FavoriteItem>(FavoriteItem())
   private var update = Variable<FavoriteItem>(FavoriteItem())
   private var remove = Variable<FavoriteItem>(FavoriteItem())
   
   func addObserver() -> (add: Observable<FavoriteItem>, update: Observable<FavoriteItem>, remove: Observable<FavoriteItem>) {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               self.add.value = item
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               self.remove.value = item
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               self.update.value = item
            }
         }).disposed(by: disposeBag)

      return (add.asObservable(), update.asObservable(), remove.asObservable())
   }
}
