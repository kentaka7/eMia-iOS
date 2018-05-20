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
         self?.lookFor = lookFor.element
      }
   }
   
   var lookFor: Gender! {
      didSet {
         interactor.lookFor = lookFor
      }
   }
   
   var status: FilterFavorite! {
      didSet {
         view.status = status
         interactor.status = status
      }
   }

   var municipalityId: String? {
      didSet {
         view.municipalityId = municipalityId
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
