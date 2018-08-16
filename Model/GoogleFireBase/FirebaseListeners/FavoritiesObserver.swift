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

class FavoritiesObserver: FireBaseListener {
   lazy var dbRef = gDataBaseRef.child(FavoriteItemFields.favorits)
   private let favoritsManager = FavoritsManager()
   private let disposeBag = DisposeBag()
   
   func startListening() {
      dbRef.rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.favoritsManager.addFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.favoritsManager.deleteFavorite(item)
            }
         }).disposed(by: disposeBag)
      dbRef.rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem(snapshot) {
               self.favoritsManager.editFavorite(item)
            }
         }).disposed(by: disposeBag)
   }
}
