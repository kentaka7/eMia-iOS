//
//  MyProfileEditor.swift
//  eMia
//
//  Created by Сергей Кротких on 03/09/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

enum MyProfileRows: Int {
   case name
   case address
   case gender
   case yearBirth
   case photo
   static let allValues = [name, address, gender, yearBirth, photo]
}

class MyProfileEditor: NSObject {
   
   weak private var user: UserModel?
   weak private var viewController: UIViewController?
   weak private var tableView: UITableView?
   weak private var locationWorker: MyProfileLocationWorker?

   required init(with user: UserModel, viewController: UIViewController, tableView: UITableView, locationWorker: MyProfileLocationWorker) {
      super.init()
      self.user = user
      self.viewController = viewController
      self.tableView = tableView
      self.locationWorker = locationWorker
      self.configureView()
   }

   deinit {
      Log()
   }

   private func configureView() {
      guard let tableView = self.tableView else {
         assert(false, "Need to define tableView before!")
      }
      tableView.delegate = self
      tableView.dataSource = self
   }
}

// MARK: - The profile editor is a tableView delegate

extension MyProfileEditor: UITableViewDelegate, UITableViewDataSource {
   
   func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView, for: indexPath)
   }
   
   private func cell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      switch MyProfileRows(rawValue: indexPath.row)! {
      case .name:
         return tableView.dequeueCell(ofType: Register7ViewCell.self)!.then { cell in
            cell.configure(for: user!)
         }
      case .address:
         return tableView.dequeueCell(ofType: Register3ViewCell.self)!.then { cell in
            cell.configure(for: user!, delegate: self)
         }
      case .gender:
         return tableView.dequeueCell(ofType: Register4ViewCell.self)!.then { cell in
            cell.configure(for: user!)
         }
      case .yearBirth:
         return tableView.dequeueCell(ofType: Register5ViewCell.self)!.then { cell in
            cell.configure(for: user!)
         }
      case .photo:
         return tableView.dequeueCell(ofType: Register6ViewCell.self)!.then { cell in
            cell.viewController = viewController
            cell.configure(for: user!)
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

extension MyProfileEditor {
   
   func myProfileData() -> MyProfileData? {
      guard let tableView = self.tableView else {
         assert(false, "Need to define tableView before!")
      }
      var userPhoto: UIImage!
      var userName = ""
      var userGender: Gender = .none
      var userYearBirth = 0
      var userAddress = ""
      
      if let nameCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.name.rawValue, section: 0)) as? Register7ViewCell {
         guard let name = nameCell.name, name.isEmpty == false else {
            Alert.default.showOk("", message: "Please enter your name".localized)
            return nil
         }
         userName = name
      }
      if let photoCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.photo.rawValue, section: 0)) as? Register6ViewCell {
         guard let image = photoCell.photo else {
            Alert.default.showOk("", message: "Please add photo".localized)
            return nil
         }
         userPhoto = image
      }
      if let genderCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.gender.rawValue, section: 0)) as? Register4ViewCell {
         userGender = genderCell.gender
      }
      if let yearBirthCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.yearBirth.rawValue, section: 0)) as? Register5ViewCell {
         userYearBirth = yearBirthCell.yearBirth ?? -1
      }
      if let addressCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.address.rawValue, section: 0)) as? Register3ViewCell {
         userAddress = addressCell.address ?? ""
      }
      let data = MyProfileData(name: userName, address: userAddress, gender: userGender, yearBirth: userYearBirth, photo: userPhoto)
      return data
   }

}

// MARK: - Where Am I button pressed

extension MyProfileEditor: LocationComputing {
   
   func calculateWhereAmI() {
      setUpMunicipalityAccordingMyLocation()
   }
   
   private func setUpMunicipalityAccordingMyLocation() {
      locationWorker?.requestLocation { location in
         if let myLocation = location {
            // TODO: Use this location to compute user's municipality
            print(myLocation)
         }
      }
   }
}
