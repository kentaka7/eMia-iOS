//
//  FilterInteractor.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift

class FilterInteractor: FilterStoragable {
   
   weak var presenter: FilterPresenter!
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
      let value: Gender = lookFor ?? .both
      let genderFilter = presenter.showMeComponent.genderFilter
      genderFilter.value = value
      _ = genderFilter.asObservable().subscribe { [weak self] lookFor in
         guard let `self` = self else { return }
         self.lookFor = lookFor.element
      }
   }
   
   // MARK: With status (favorite all or my favorite)
   private func setUpStatus(_ status: FilterFavorite?) {
      let value: FilterFavorite = status ?? .all
      let favoriteFilter = presenter.favoriteStatusComponent.favoriteFilter
      favoriteFilter.value = value
      _ = favoriteFilter.asObservable().subscribe { [weak self] status in
         guard let `self` = self else { return }
         self.status = status.element
      }
   }
   
   // MARK: Age
   private func setUpAgesSlider(minAge: CGFloat?, maxAge: CGFloat?) {
      let value1: CGFloat = minAge ?? 0.0
      let value2: CGFloat = maxAge ?? 100.0
      presenter.agesComponent.minAge = value1
      presenter.agesComponent.maxAge = value2
      let minAgeFilter = presenter.agesComponent.minAgeFilter
      minAgeFilter.value = Int(value1)
      _ = minAgeFilter.asObservable().subscribe { [weak self] minAge in
         guard let `self` = self else { return }
         self.minAge = CGFloat(minAge.element!)
      }
      let maxAgeFilter = presenter.agesComponent.maxAgeFilter
      maxAgeFilter.value = Int(value2)
      _ = maxAgeFilter.asObservable().subscribe { [weak self] maxAge in
         guard let `self` = self else { return }
         self.maxAge = CGFloat(maxAge.element!)
      }
   }
   
   // MARK: Municipality
   private func setUpMunicipality(_ municipalityId: String?) {
      let value = municipalityId ?? ""
      let municipalityFilter = presenter.municipalityComponent.municipalityFilter
      municipalityFilter.value = value
      _ = municipalityFilter.asObservable().subscribe { [weak self] municipalityId in
         guard let `self` = self else { return }
         self.municipalityId = municipalityId.element
      }
   }
}
