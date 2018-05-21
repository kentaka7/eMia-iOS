//
//  FilterPresenter.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class FilterPresenter: NSObject {
   
   var interactor: FilterInteractor!
   var view: FiltersViewController!
   
   func viewDidLoad() {
      interactor.requestFilterValues()
   }
   
   func backButtonPressed() {
      interactor.saveChanges()
   }

   func setUpLookFor(_ lookFor: Gender) {
      let genderFilter = view.genderControllerView.genderFilter
      genderFilter.value = lookFor
      _ = genderFilter.asObservable().subscribe() { [weak self] lookFor in
         guard let `self` = self else { return }
         self.lookFor = lookFor.element
      }
   }
   
   var lookFor: Gender! {
      didSet {
         interactor.lookFor = lookFor
      }
   }

   func setUpStatus(_ status: FilterFavorite) {
      let favoriteFilter = view.favoriteControllerView.favoriteFilter
      favoriteFilter.value = status
      _ = favoriteFilter.asObservable().subscribe() { [weak self] status in
         guard let `self` = self else { return }
         self.status = status.element
      }
   }
   
   var status: FilterFavorite! {
      didSet {
         interactor.status = status
      }
   }

   func setUpMunicipality(_ municipalityId: String) {
      let municipalityFilter = view.municipalityControllerView.municipalityFilter
      municipalityFilter.value = municipalityId
      _ = municipalityFilter.asObservable().subscribe() { [weak self] municipalityId in
         guard let `self` = self else { return }
         self.municipalityId = municipalityId.element
      }
   }

   var municipalityId: String? {
      didSet {
         interactor.municipalityId = municipalityId
      }
   }
   
   var minAge: CGFloat! {
      didSet {
         view.minAge = minAge
         interactor.minAge = minAge
      }
   }
   
   var maxAge: CGFloat! {
      didSet {
         view.maxAge = maxAge
         interactor.maxAge = maxAge
      }
   }

}
