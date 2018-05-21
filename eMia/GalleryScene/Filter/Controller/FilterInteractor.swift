//
//  FilterInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class FilterInteractor: NSObject {
   
   weak var view: FiltersViewController!
   private var filterModel: FilterModel!
   private var filterModelCopy: FilterModel!
   
   func viewDidLoad() {
      requestFilterValues()
   }
   
   func backButtonPressed() {
      saveChanges()
   }

   // MARK: Properties
   private var lookFor: Gender! {
      didSet {
         filterModel?.genderFilter = lookFor
      }
   }
   
   private var status: FilterFavorite! {
      didSet {
         filterModel?.myFavoriteFilter = status
      }
   }
   
   private var municipalityId: String? {
      didSet {
         filterModel?.municipality = municipalityId
      }
   }
   private var minAge: CGFloat! {
      didSet {
         filterModel?.minAge = minAge
      }
   }
   
   private var maxAge: CGFloat! {
      didSet {
         filterModel?.maxAge = maxAge
      }
   }
}

// MARK: - Private

extension FilterInteractor {

   // MARK: Save filter req
   private func saveChanges() {
      if filterModel == filterModelCopy {
         return
      }
      filterModel.syncronize()
   }

   // MARK: Read saved data
   private func requestFilterValues() {
      if filterModel == nil {
         filterModel = FilterModel()
         filterModelCopy = FilterModel()
      }
      setUpLookFor(filterModel!.genderFilter)
      setUpStatus(filterModel!.myFavoriteFilter)
      setUpAgesSlider(minAge: filterModel!.minAge, maxAge: filterModel!.maxAge)
      municipalityId = filterModel!.municipality
   }
   
   // MARK: Show me (by gender)
   private func setUpLookFor(_ lookFor: Gender) {
      let genderFilter = view.genderControllerView.genderFilter
      genderFilter.value = lookFor
      _ = genderFilter.asObservable().subscribe() { [weak self] lookFor in
         guard let `self` = self else { return }
         self.lookFor = lookFor.element
      }
   }

   // MARK: With status (favorite all or my favorite)
   private func setUpStatus(_ status: FilterFavorite) {
      let favoriteFilter = view.favoriteControllerView.favoriteFilter
      favoriteFilter.value = status
      _ = favoriteFilter.asObservable().subscribe() { [weak self] status in
         guard let `self` = self else { return }
         self.status = status.element
      }
   }

   // MARK: Municipality
   private func setUpMunicipality(_ municipalityId: String) {
      let municipalityFilter = view.municipalityControllerView.municipalityFilter
      municipalityFilter.value = municipalityId
      _ = municipalityFilter.asObservable().subscribe() { [weak self] municipalityId in
         guard let `self` = self else { return }
         self.municipalityId = municipalityId.element
      }
   }

   // MARK: Age
   private func setUpAgesSlider(minAge: CGFloat, maxAge: CGFloat) {
      view.ageSliderView.minAge = minAge
      view.ageSliderView.maxAge = maxAge
      let minAgeFilter = view.ageSliderView.minAgeFilter
      minAgeFilter.value = Int(minAge)
      _ = minAgeFilter.asObservable().subscribe() { [weak self] minAge in
         guard let `self` = self else { return }
         self.minAge = CGFloat(minAge.element!)
      }
      let maxAgeFilter = view.ageSliderView.maxAgeFilter
      maxAgeFilter.value = Int(maxAge)
      _ = maxAgeFilter.asObservable().subscribe() { [weak self] maxAge in
         guard let `self` = self else { return }
         self.maxAge = CGFloat(maxAge.element!)
      }
   }
}
