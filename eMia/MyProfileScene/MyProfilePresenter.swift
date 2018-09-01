//
//  MyProfilePresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import NVActivityIndicatorView
import RxSwift

class MyProfilePresenter: NSObject, MyProfilePresenterProtocol {

   enum MyProfileRows: Int {
      case name
      case address
      case gender
      case yearBirth
      case photo
      static let allValues = [name, address, gender, yearBirth, photo]
   }

   private var tableView: UITableView {
      return view.tableView
   }

   // Strong Dependencies
   weak var view: MyProfileViewProtocol!
   var interactor: MyProfileInteractorProtocol!
   var router: MyProfilePouterProtocol!
   var locationWorker: MyProfileLocationWorker!

   // Weak Dependencies
   weak var viewController: UIViewController!
   weak var user: UserModel!
   weak var activityIndicator: NVActivityIndicatorView!

   private let disposeBag = DisposeBag()

   deinit {
      Log()
   }

   func configureView() {
      setUpTableView()
      configureDoneButton()
      bindBackButton()
      bindDoneButton()
   }
   
   private func setUpTableView() {
      tableView.delegate = self
      tableView.dataSource = self
   }
   
   private func configureDoneButton() {
      view.saveDataButton.setAsCircle()
      view.saveDataButton.backgroundColor = GlobalColors.kBrandNavBarColor
   }
   
   private func bindBackButton() {
      view.backBarButtonItem.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.router.closeScene()
      }).disposed(by: disposeBag)
   }
   
   private func bindDoneButton() {
      view.saveDataButton.rx.tap.bind(onNext: { [weak self] in
         guard let `self` = self else { return }
         self.saveData()
      }).disposed(by: disposeBag)
   }

   private func saveData() {
      self.updateMyProfile { [weak self] in
         guard let `self` = self else { return }
         self.router.goToNextScene()   // documented: press alt+click to see the description 
      }
   }
   
   private func updateMyProfile(_ completed: @escaping () -> Void) {
      var userPhoto: UIImage!
      var userName = ""
      var userGender: Gender = .none
      var userYearBirth = 0
      var userAddress = ""
      
      if let nameCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.name.rawValue, section: 0)) as? Register7ViewCell {
         guard let name = nameCell.name, name.isEmpty == false else {
            Alert.default.showOk("", message: "Please enter your name".localized)
            return
         }
         userName = name
      }
      if let photoCell = tableView.cellForRow(at: IndexPath(row: MyProfileRows.photo.rawValue, section: 0)) as? Register6ViewCell {
         guard let image = photoCell.photo else {
            Alert.default.showOk("", message: "Please add photo".localized)
            return
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
      let data = MyProfileInteractor.MyProfileData(name: userName, address: userAddress, gender: userGender, yearBirth: userYearBirth, photo: userPhoto)
      interactor.updateProfile(for: data, completed: completed)
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
   
   private func setUpMunicipalityAccordingMyLocation() {
      activityIndicator.startAnimating()
      locationWorker.requestLocation { location in
         self.activityIndicator.stopAnimating()
         if let myLocation = location {
            // TODO: Use this location to compute user's municipality
            print(myLocation)
         }
      }
   }
}
