//
//  FilterModel.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/28/17.
//  Copyright © 2017 Coded I/S. All rights reserved.
//

import UIKit

struct FilterModel: Equatable {
   
   private var storage = FilterStorage()
   
   var myFavoriteFilter: FilterFavorite
   var genderFilter: Gender
   var minAge: CGFloat
   var maxAge: CGFloat
   var municipality: String?

   init() {
      myFavoriteFilter = storage.myFavoriteFilter
      genderFilter = storage.genderFilter
      minAge = storage.minAge
      maxAge = storage.maxAge
      municipality = storage.municipality
   }
   
   func syncronize() {
      storage.myFavoriteFilter = myFavoriteFilter
      storage.genderFilter = genderFilter
      storage.minAge = minAge
      storage.maxAge = maxAge
      storage.municipality = municipality
      NotificationCenter.default.post(name: Notification.Name(Notifications.UpdatedFilter), object: nil)
   }
}

func == (leftSide: FilterModel, rightSide: FilterModel) -> Bool {
   let cmp1 = leftSide.myFavoriteFilter == rightSide.myFavoriteFilter
   let cmp2 = leftSide.genderFilter == rightSide.genderFilter
   let cmp3 = leftSide.minAge == rightSide.minAge
   let cmp4 = leftSide.maxAge == rightSide.maxAge
   let mun1 = leftSide.municipality ?? ""
   let mun2 = rightSide.municipality ?? ""
   let cmp5 = mun1 == mun2
   return cmp1 && cmp2 && cmp3 && cmp4 && cmp5
}
