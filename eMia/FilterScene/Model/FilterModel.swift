//
//  FilterModel.swift
//  eMia
//
//  Created by Sergey Krotkih on 12/28/17.
//  Copyright © 2017 Sergey Krotkih. All rights reserved.
//

import Foundation
import RealmSwift
import RxRealm
import RxSwift

final class FilterModel: Object {
   
   @objc dynamic var id: String?
   @objc dynamic var myFavorite: Int = -1
   @objc dynamic var gender: Int = -1
   @objc dynamic var _minAge: CGFloat = 0.0
   @objc dynamic var _maxAge: CGFloat = 100.0
   @objc dynamic var _municipality: String?
   
   let disposeBag = DisposeBag()
   
   convenience init(id: String, favorite: FilterFavorite, gender: Gender, minAge: CGFloat, maxAge: CGFloat, municipality: String) {
      self.init()
      self.id = id
      self.myFavoriteFilter = favorite
      self.genderFilter = gender
      self._minAge = minAge
      self._maxAge = maxAge
      self._municipality = municipality
   }

   var myFavoriteFilter: FilterFavorite {
      get {
         if let value = FilterFavorite(rawValue: myFavorite) {
            return value
         } else {
            return .none
         }
         
      }
      set {
         // As an example with a handling error:
         Realm.update {
            myFavorite = newValue.rawValue
            }.subscribe(onNext: { _ in
            }, onError: { error in
               print(error.localizedDescription)
            }).disposed(by: disposeBag)
      }
   }
   
   var genderFilter: Gender {
      get {
         if let value = Gender(rawValue: gender) {
            return value
         } else {
            return .none
         }
      }
      set {
         Realm.update {
            gender = newValue.rawValue
         }
      }
   }

   var minAge: CGFloat {
      get {
         return _minAge
      }
      set {
         Realm.update {
            _minAge = newValue
         }
      }
   }

   var maxAge: CGFloat {
      get {
         return _maxAge
      }
      set {
         Realm.update {
            _maxAge = newValue
         }
      }
   }

   var municipality: String? {
      get {
         return _municipality
      }
      set {
         Realm.update {
            _municipality = newValue
         }
      }
   }
   
   override class func primaryKey() -> String? {
      return "id"
   }
   
   class var data: FilterModel {
      let model = self.currentModel
      makeCopy(model)
      return model
   }

   var isChanged: Bool {
      do {
         let realm = try Realm()
         if let model = realm.object(ofType: FilterModel.self, forPrimaryKey: "2") {
            return !(self == model)
         } else {
            return false
         }
      } catch _ {
            return false
      }
   }
   
   private class var currentModel: FilterModel {
      do {
         let realm = try Realm()
         if let model = realm.object(ofType: FilterModel.self, forPrimaryKey: "1") {
            return model
         } else {
            return defaulModel
         }
      } catch _ {
         return defaulModel
      }
   }
   
   private class var defaulModel: FilterModel {
      let model = FilterModel(id: "1", favorite: .all, gender: .both, minAge: 0.0, maxAge: 100.0, municipality: "")
      _ = Realm.create(model: model).asObservable().subscribe(onNext: { _ in
      }, onError: { error in
         Alert.default.showError(message: error.localizedDescription)
      })
      return model
   }

   private class func makeCopy(_ model: FilterModel) {
      let copyModel = FilterModel(id: "2", favorite: model.myFavoriteFilter, gender: model.genderFilter, minAge: model.minAge, maxAge: model.maxAge, municipality: model.municipality ?? "")
      Realm.create(model: copyModel)
   }
   
   func syncronize() {
      _ = Realm.create(model: self).asObservable().subscribe(onNext: { _ in
         NotificationCenter.default.post(name: Notification.Name(Notifications.UpdatedFilter), object: nil)
      }, onError: { error in
         Alert.default.showError(message: error.localizedDescription)
      })
   }
}

// MARK: - Check a post on current filter condition

extension FilterModel {

   class func check(post: PostModel, searchTemplate: String) -> Bool {
      let model = FilterModel.currentModel
      
      var itsok = true
      let favoritsManager = FavoritsManager()
      
      // Favorities
      switch model.myFavoriteFilter {
      case .myFavorite:
         itsok = itsok && favoritsManager.isItMyFavoritePost(post)
      default:
         break
      }
      if let user = gUsersManager.getUserWith(id: post.uid) {
         // Gender
         switch model.genderFilter {
         case .boy:
            itsok = itsok && user.gender == .boy
         case .girl:
            itsok = itsok && user.gender == .girl
         default:
            break
         }
         // Municipality
         if let municipality = model.municipality, municipality.isEmpty == false {
            if let address = user.address, address.isEmpty == false {
               itsok = itsok && address == municipality
            } else {
               itsok = itsok && false
            }
         }
         // Age
         let minAge = Int(model.minAge)
         let maxAge = Int(model.maxAge)
         if (minAge != 0 || maxAge != 100) {
            if user.yearbirth > 0 {
               let userAge = Date().years - user.yearbirth
               itsok = itsok && (userAge >= minAge && userAge <= maxAge)
            } else {
               itsok = itsok && false
            }
         }
      }
      
      if itsok {
         // Sesarch template
         var isValidvalue = false
         if searchTemplate.isEmpty {
            isValidvalue = true
         } else {
            let title = post.title
            let body = post.body
            if title.lowercased().range(of: searchTemplate.lowercased()) != nil {
               isValidvalue = true
            } else if body.lowercased().range(of: searchTemplate.lowercased()) != nil {
               isValidvalue = true
            }
         }
         return isValidvalue
      } else {
         return false
      }
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
