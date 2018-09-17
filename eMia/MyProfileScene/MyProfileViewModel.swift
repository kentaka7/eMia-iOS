//
//  MyProfileViewModel.swift
//  eMia
//
//  Created by Sergey Krotkih on 11/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation


class MyProfileViewModel {
   
   private weak var user: UserModel!
   var locationWorker: MyProfileLocationWorker?
   
   init(user: UserModel) {
      self.user = user
   }
   
   // User dependency
   func configure(view: UITableViewCell, row: MyProfileRows) {
      switch row {
      case .name:
         let cell = view as! Register7ViewCell
         cell.setTextField(text: user.name)
      case .address:
         let cell = view as! Register3ViewCell
         cell.locationAgent = self
         cell.setAddress(user.address)
      case .gender:
         let cell = view as! Register4ViewCell
         cell.setGender(user.gender)
      case .yearBirth:
         let cell = view as! Register5ViewCell
         let year = user.yearbirth
         if year > 0 {
            cell.setYear(year)
         }
      case .photo:
         let cell = view as! Register6ViewCell
         guard !user.userId.isEmpty else {
            cell.setImage(nil)
            return
         }
         gPhotosManager.downloadAvatar(for: user.userId) { image in
            cell.setImage(image)
         }
      }
   }
}

// MARK: - Where Am I button pressed

extension MyProfileViewModel: LocationComputing {
   
   func calculateWhereAmI() {
      locationWorker?.requestLocation { location in
         if let myLocation = location {
            // TODO: Use this location to compute user's municipality
            print(myLocation)
         }
      }
   }
}

extension MyProfileViewModel {

   
   
}
