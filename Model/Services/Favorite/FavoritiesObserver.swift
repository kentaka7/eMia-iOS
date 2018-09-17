//
//  FavoritiesObserver.swift
//  eMia
//
//  Created by Sergey Krotkih on 20/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

class FavoritiesObserver: FirebaseListener {
   lazy var dbRef = gDataBaseRef.child(FavoriteItem.TableName)
   private let localDB = LocalBaseController()
   private let disposeBag = DisposeBag()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.localDB.addFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.localDB.deleteFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.localDB.editFavorite(item)
            }
         }).disposed(by: disposeBag)
   }
}
