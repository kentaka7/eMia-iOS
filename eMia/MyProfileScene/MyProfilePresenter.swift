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

   internal struct CellName {
      static let register3ViewCell = "Register3ViewCell"
      static let register4ViewCell = "Register4ViewCell"
      static let register5ViewCell = "Register5ViewCell"
      static let register6ViewCell = "Register6ViewCell"
      static let register7ViewCell = "Register7ViewCell"
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
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register7ViewCell) as! Register7ViewCell
         cell.configure(for: user)
         return cell
      case .Address:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register3ViewCell) as! Register3ViewCell
         cell.configure(for: user, delegate: self)
         return cell
      case .Gender:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register4ViewCell) as! Register4ViewCell
         cell.configure(for: user)
         return cell
      case .YearBirth:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register5ViewCell) as! Register5ViewCell
         cell.configure(for: user)
         return cell
      case .Photo:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register6ViewCell) as! Register6ViewCell
         cell.viewController = viewController
         cell.configure(for: user)
         return cell
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
