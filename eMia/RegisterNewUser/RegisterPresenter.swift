//
//  RegisterPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView

class RegisterPresenter: NSObject {

   enum RegisterRows: Int {
      case Email
      case Password
      case Name
      case Address
      case Gender
      case YearBirth
      case Photo
      static let allValues = [Email, Password, Name, Address, Gender, YearBirth, Photo]
   }

   internal struct CellName {
      static let register1ViewCell = "Register1ViewCell"
      static let register2ViewCell = "Register2ViewCell"
      static let register3ViewCell = "Register3ViewCell"
      static let register4ViewCell = "Register4ViewCell"
      static let register5ViewCell = "Register5ViewCell"
      static let register6ViewCell = "Register6ViewCell"
      static let register7ViewCell = "Register7ViewCell"
   }
   
   weak var viewController: UIViewController!
   weak var tableView: UITableView!
   weak var user: UserModel!
   var password: String?
   weak var activityIndicator: NVActivityIndicatorView!
   var locationManager: LocationManager!
   
   weak var interactor: RegisterInteractor!
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch RegisterRows(rawValue: indexPath.row)! {
      case .Email:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register1ViewCell) as! Register1ViewCell
         return cell
      case .Password:
         let cell = tableView.dequeueReusableCell(withIdentifier: CellName.register2ViewCell) as! Register2ViewCell
         cell.password = password
         return cell
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
   
   func tableView(_ tableView: UITableView, heightCellFor indexPath: IndexPath) -> CGFloat {
      switch RegisterRows(rawValue: indexPath.row)! {
      case .Email:
         return 64.0
      case .Password:
         return 64.0
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
      return RegisterRows.allValues.count
   }
   
   func registerNewUser() {
      let emailCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Email.rawValue, section: 0)) as! Register1ViewCell
      let passwordCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Password.rawValue, section: 0)) as! Register2ViewCell
      let nameCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Name.rawValue, section: 0)) as! Register7ViewCell
      let genderCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Gender.rawValue, section: 0)) as! Register4ViewCell
      let yearBirthCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.YearBirth.rawValue, section: 0)) as! Register5ViewCell
      let photoCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Photo.rawValue, section: 0)) as! Register6ViewCell
      let addressCell = tableView.cellForRow(at: IndexPath(row: RegisterRows.Address.rawValue, section: 0)) as! Register3ViewCell

      let data = RegisterInteractor.RegisterData(name: nameCell.name,
                                                 email: emailCell.email,
                                                 password: passwordCell.password,
                                                 address: addressCell.address,
                                                 gender: genderCell.gender,
                                                 yearBirth: yearBirthCell.yearBirth,
                                                 photo: photoCell.photo)
      interactor.registerNewUser(data)
   }
}

// MARK: - Where Am I button pressed

extension RegisterPresenter: LocationComputing {
   
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
