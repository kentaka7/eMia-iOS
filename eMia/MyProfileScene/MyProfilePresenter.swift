//
//  MyProfilePresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class MyProfilePresenter: NSObject, MyProfilePresenting {

   enum MyProfileRows: Int {
      case Name
      case Address
      case Gender
      case YearBirth
      case Photo
      static let allValues = [Name, Address, Gender, YearBirth, Photo]
   }

   weak var viewController: UIViewController!
   weak var tableView: UITableView!
   weak var user: UserModel!
   weak var activityIndicator: NVActivityIndicatorView!
   var locationManager: LocationManager!
   
   var interactor: MyProfileInteractor!
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch MyProfileRows(rawValue: indexPath.row)! {
      case .Name:
         return tableView.dequeueCell(ofType: Register7ViewCell.self).then { cell in
            cell.configure(for: user)
         }
      case .Address:
         return tableView.dequeueCell(ofType: Register3ViewCell.self).then { cell in
            cell.configure(for: user, delegate: self)
         }
      case .Gender:
         return tableView.dequeueCell(ofType: Register4ViewCell.self).then { cell in
            cell.configure(for: user)
         }
      case .YearBirth:
         return tableView.dequeueCell(ofType: Register5ViewCell.self).then { cell in
            cell.configure(for: user)
         }
      case .Photo:
         return tableView.dequeueCell(ofType: Register6ViewCell.self).then { cell in
            cell.viewController = viewController
            cell.configure(for: user)
         }
      }
   }
   
   func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch MyProfileRows(rawValue: indexPath.row)! {
      case .Name:
         return 68.0
      case .Address:
         return 146.0
      case .Gender:
         return 94.0
      case .YearBirth:
         return 146.0
      case .Photo:
         return 291.0
      }
   }

   var numberOfRows: Int {
      return MyProfileRows.allValues.count
   }
   
   func updateMyProfile(_ completed: @escaping () -> Void) {
      let nameCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.Name.rawValue, section: 0)) as! Register7ViewCell
      let genderCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.Gender.rawValue, section: 0)) as! Register4ViewCell
      let yearBirthCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.YearBirth.rawValue, section: 0)) as! Register5ViewCell
      let photoCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.Photo.rawValue, section: 0)) as! Register6ViewCell
      let addressCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.Address.rawValue, section: 0)) as! Register3ViewCell

      let data = MyProfileInteractor.MyProfileData(name: nameCell.name,
                                                 address: addressCell.address,
                                                 gender: genderCell.gender,
                                                 yearBirth: yearBirthCell.yearBirth,
                                                 photo: photoCell.photo)
      interactor.updateMyProfile(data, completed: completed)
   }
}

// MARK: - Where Am I button pressed

extension MyProfilePresenter: LocationComputing {
   
   func calculateWhereAmI() {
      setUpMunicipalityAccordingMyLocation()
   }
   
   fileprivate func setUpMunicipalityAccordingMyLocation() {
      activityIndicator.startAnimating()
      locationManager.requestLocation { location in
         self.activityIndicator.stopAnimating()
         if let myLocation = location {
            // TODO: Use the location for computing user's municipality
            print(myLocation)
         }
      }
   }
}
