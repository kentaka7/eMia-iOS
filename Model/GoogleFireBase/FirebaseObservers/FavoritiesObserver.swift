//
//  FavoritiesObserver.swift
//  eMia
//

import UIKit
import RxSwift
import Firebase

class FavoritiesObserver: NSObject {
   lazy var dbRef = FireBaseManager.firebaseRef.child(FavoriteItemFields.favorits)
   private let disposeBag = DisposeBag()
   
   func addObserver() {
      dbRef
         .rx
         .observeEvent(.childAdded)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               ModelData.addFavoritiesListener(item)
            }
         }).disposed(by: disposeBag)
      dbRef
         .rx
         .observeEvent(.childRemoved)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               ModelData.deleteFavoritiesListener(item)
            }
         }).disposed(by: disposeBag)
      dbRef
         .rx
         .observeEvent(.childChanged)
         .subscribe(onNext: { snapshot in
            if let item = FavoriteItem.decodeSnapshot(snapshot) {
               ModelData.editFavoritiesListener(item)
            }
         }).disposed(by: disposeBag)
   }
}
