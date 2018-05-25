//
//  FilterInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class FilterInteractor: FilterStoragable {
   
   weak var view: FiltersViewController!
   private var filterModel: FilterModel!
   private var filterModelCopy: FilterModel!
   
   func fetchFilterPreferences() {
      if filterModel == nil {
         filterModel = FilterModel()
         filterModelCopy = FilterModel()
      }
      configurePresenters()
   }
   
   func saveFilterPreferences() {
      if filterModel == filterModelCopy {
         return
      }
      filterModel.syncronize()
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

// MARK: - Configure Presenters

extension FilterInteractor {

   private func configurePresenters() {
      setUpLookFor(filterModel.genderFilter)
      setUpStatus(filterModel.myFavoriteFilter)
      setUpAgesSlider(minAge: filterModel.minAge, maxAge: filterModel.maxAge)
      setUpMunicipality(filterModel.municipality)
   }
   
   // MARK: Show me (by gender)
   private func setUpLookFor(_ lookFor: Gender?) {
      let _lookFor: Gender = lookFor ?? .both
      let genderFilter = view.genderControllerView.genderFilter
      genderFilter.value = _lookFor
      _ = genderFilter.asObservable().subscribe() { [weak self] lookFor in
         guard let `self` = self else { return }
         self.lookFor = lookFor.element
      }
   }
   
   // MARK: With status (favorite all or my favorite)
   private func setUpStatus(_ status: FilterFavorite?) {
      let _status: FilterFavorite = status ?? .all
      let favoriteFilter = view.favoriteControllerView.favoriteFilter
      favoriteFilter.value = _status
      _ = favoriteFilter.asObservable().subscribe() { [weak self] status in
         guard let `self` = self else { return }
         self.status = status.element
      }
   }
   
   // MARK: Age
   private func setUpAgesSlider(minAge: CGFloat?, maxAge: CGFloat?) {
      let _minAge: CGFloat = minAge ?? 0.0
      let _maxAge: CGFloat = maxAge ?? 100.0
      view.ageSliderView.minAge = _minAge
      view.ageSliderView.maxAge = _maxAge
      let minAgeFilter = view.ageSliderView.minAgeFilter
      minAgeFilter.value = Int(_minAge)
      _ = minAgeFilter.asObservable().subscribe() { [weak self] minAge in
         guard let `self` = self else { return }
         self.minAge = CGFloat(minAge.element!)
      }
      let maxAgeFilter = view.ageSliderView.maxAgeFilter
      maxAgeFilter.value = Int(_maxAge)
      _ = maxAgeFilter.asObservable().subscribe() { [weak self] maxAge in
         guard let `self` = self else { return }
         self.maxAge = CGFloat(maxAge.element!)
      }
   }
   
   // MARK: Municipality
   private func setUpMunicipality(_ municipalityId: String?) {
      let _municipalityId = municipalityId ?? ""
      let municipalityFilter = view.municipalityControllerView.municipalityFilter
      municipalityFilter.value = _municipalityId
      _ = municipalityFilter.asObservable().subscribe() { [weak self] municipalityId in
         guard let `self` = self else { return }
         self.municipalityId = municipalityId.element
      }
   }
}
