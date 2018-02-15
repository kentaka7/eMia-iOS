//
//  FilterManager.swift
//  eMia
//

import UIKit

class FilterManager {
   
   enum Settings {
      static let filterMinAgeKey = "FiltersViewController.Settings.minValueKey"
      static let filterMaxAgeKey = "FiltersViewController.Settings.maxValueKey"
      static let filterMyFavoriteKey = "FiltersViewController.Settings.myFavoriteKey"
      static let filterGenderKey = "FiltersViewController.Settings.gender"
      static let filterMunicipalityKey = "FiltersViewController.Settings.municipality"
      static let filterIsInitialized = "FiltersViewController.Settings.filterIsInitialized"
   }
   
   var didFilerUpdateCallabck: () -> Void = { }
   private var queue : DispatchQueue = DispatchQueue(label: "dk.coded.\(AppConstants.ApplicationName).filterQueue")

   init() {
      setUpDefaults()
   }
   
   private func setUpDefaults() {
      if UserDefaults.standard.bool(forKey: Settings.filterIsInitialized) {
         return
      }
      UserDefaults.standard.set(FilterFavorite.all.rawValue, forKey: Settings.filterMyFavoriteKey)
      UserDefaults.standard.set(Gender.both.rawValue, forKey: Settings.filterGenderKey)
      UserDefaults.standard.set(0.0, forKey: Settings.filterMinAgeKey)
      UserDefaults.standard.set(100.0, forKey: Settings.filterMaxAgeKey)
      UserDefaults.standard.set(true, forKey: Settings.filterIsInitialized)
      UserDefaults.standard.synchronize()
   }
   
   private func didFilterUpdate() {
      didFilerUpdateCallabck()
   }
   
   var myFavoriteFilter :FilterFavorite {     
      set {
         queue.async {
            UserDefaults.standard.set(newValue.rawValue, forKey: Settings.filterMyFavoriteKey)
            UserDefaults.standard.synchronize()
            self.didFilterUpdate()
         }
      }
      get {
         return queue.sync {
            let status = UserDefaults.standard.integer(forKey: Settings.filterMyFavoriteKey)
            if let value = FilterFavorite(rawValue: Int16(status)) {
               return value
            } else {
               return FilterFavorite(rawValue: FilterFavorite.all.rawValue)!
            }
         }
      }
   }
   
   var genderFilter: Gender {
      set {
         queue.async {
            UserDefaults.standard.set(newValue.rawValue, forKey: Settings.filterGenderKey)
            UserDefaults.standard.synchronize()
            self.didFilterUpdate()
         }
      }
      get {
         return queue.sync {
            let genderRowValue = UserDefaults.standard.integer(forKey: Settings.filterGenderKey)
            if let gender = Gender(rawValue: Int(genderRowValue)) {
               return gender
            } else {
               return .both
            }
         }
      }
   }

   var municipality: String? {
      set {
         queue.async {
            UserDefaults.standard.set(newValue, forKey: Settings.filterMunicipalityKey)
            UserDefaults.standard.synchronize()
            self.didFilterUpdate()
         }
      }
      get {
         return queue.sync {
            UserDefaults.standard.string(forKey: Settings.filterMunicipalityKey)
         }
      }
   }
   
   var minAge: CGFloat {
      set {
         queue.async {
            UserDefaults.standard.set(newValue, forKey: Settings.filterMinAgeKey)
            UserDefaults.standard.synchronize()
            self.didFilterUpdate()
         }
      }
      get {
         return queue.sync {
            CGFloat(UserDefaults.standard.float(forKey: Settings.filterMinAgeKey))
         }
      }
   }

   var maxAge: CGFloat {
      set {
         queue.async {
            UserDefaults.standard.set(newValue, forKey: Settings.filterMaxAgeKey)
            UserDefaults.standard.synchronize()
            self.didFilterUpdate()
         }
      }
      get {
         return CGFloat(UserDefaults.standard.float(forKey: Settings.filterMaxAgeKey))
      }
   }
}
