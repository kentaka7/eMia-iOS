//
//  MyProfilePresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RealmSwift
import RxRealm

class MyProfilePresenter: NSObject, MyProfilePresenterProtocol {

   enum MyProfileRows: Int {
      case name
      case address
      case gender
      case yearBirth
      case photo
      static let allValues = [name, address, gender, yearBirth, photo]
   }

   weak var viewController: UIViewController!
   private var tableView: UITableView {
      return view.tableView
   }
   weak var user: UserModel!
   weak var activityIndicator: NVActivityIndicatorView!

   var view: MyProfileViewProtocol!
   var locationManager: LocationManager!
   
   var interactor: MyProfileInteractor!
   
   func configureView() {
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   func updateMyProfile(_ completed: @escaping () -> Void) {
      var photo: UIImage?
      if let nameCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.name.rawValue, section: 0)) as? Register7ViewCell {
         guard let name = nameCell.name, name.isEmpty == false else {
            Alert.default.showOk("", message: "Please enter your name".localized)
            return
         }
         Realm.update {
            user.name = name
         }
      }
      if let photoCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.photo.rawValue, section: 0)) as? Register6ViewCell {
         guard let image = photoCell.photo else {
            Alert.default.showOk("", message: "Please add photo".localized)
            return
         }
         photo = image
      }
      if let genderCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.gender.rawValue, section: 0)) as? Register4ViewCell {
         let gender = genderCell.gender
         Realm.update {
            user.gender = gender
         }
      }
      if let yearBirthCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.yearBirth.rawValue, section: 0)) as? Register5ViewCell {
         let yearBirth = yearBirthCell.yearBirth
         Realm.update {
            user.yearbirth = yearBirth ?? -1
         }
      }
      if let addressCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.address.rawValue, section: 0)) as? Register3ViewCell {
         let address = addressCell.address
         Realm.update {
            user.address = address ?? ""
         }
      }
      if let photo = photo {
         interactor.updateMyProfile(photo, completed: completed)
      } else {
         completed()
      }
   }
}

// MARK: - UITableView protocols

extension MyProfilePresenter: UITableViewDelegate, UITableViewDataSource {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(for: indexPath)
   }
   
   private func cell(for indexPath: IndexPath) -> UITableViewCell {
      switch MyProfileRows(rawValue: indexPath.row)! {
      case .name:
         return tableView.dequeueCell(ofType: Register7ViewCell.self)!.then { cell in
            cell.configure(for: user)
         }
      case .address:
         return tableView.dequeueCell(ofType: Register3ViewCell.self)!.then { cell in
            cell.configure(for: user, delegate: self)
         }
      case .gender:
         return tableView.dequeueCell(ofType: Register4ViewCell.self)!.then { cell in
            cell.configure(for: user)
         }
      case .yearBirth:
         return tableView.dequeueCell(ofType: Register5ViewCell.self)!.then { cell in
            cell.configure(for: user)
         }
      case .photo:
         return tableView.dequeueCell(ofType: Register6ViewCell.self)!.then { cell in
            cell.viewController = viewController
            cell.configure(for: user)
         }
      }
   }
   
   private func heightCell(for indexPath: IndexPath) -> CGFloat {
      switch MyProfileRows(rawValue: indexPath.row)! {
      case .name:
         return 68.0
      case .address:
         return 146.0
      case .gender:
         return 94.0
      case .yearBirth:
         return 146.0
      case .photo:
         return 291.0
      }
   }
   
   private var numberOfRows: Int {
      return MyProfileRows.allValues.count
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
