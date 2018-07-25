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
   lazy var dbRef = gFireBaseManager.firebaseRef.child(FavoriteItemFields.favorits)
   private let disposeBag = DisposeBag()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               FavoriteModel.addFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               FavoriteModel.deleteFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               FavoriteModel.editFavorite(item)
            }
         }).disposed(by: disposeBag)
   }
}
