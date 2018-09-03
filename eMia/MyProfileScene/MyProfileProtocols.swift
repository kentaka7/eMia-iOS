//
//  MyProfileProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import CoreLocation
import NVActivityIndicatorView

protocol LocationComputing: class {
   func calculateWhereAmI()
}

protocol TableViewPresentable {
   var numberOfRows: Int {get}
   func heightCell(for indexPath: IndexPath) -> CGFloat
   func cell(for indexPath: IndexPath) -> UITableViewCell
}

protocol MyProfilePresenterProtocol: class {
   var view: MyProfileViewProtocol! {get set}
   var interactor: MyProfileInteractorProtocol! {get set}
   var router: MyProfileRouterProtocol! {get set}
   var user: UserModel! {get set}
   func configureView()
   func backButtonPressed()
   func doneButtonPressed()
}

protocol MyProfileDependenciesProtocol {
   func configure(_ view: MyProfileViewController, user: UserModel?)
}

protocol MyProfileViewProtocol: class {
   var tableView: UITableView! {get set}
   var saveDataButton: UIButton! {get set}
   var backBarButtonItem: UIBarButtonItem! {get set}
   var registrationNewUser: Bool {get}
}

protocol MyProfileInteractorProtocol {
   var loginWorker: MyProfileLoginWorkerProotocol! {get set}
   var tableView: UITableView! {get set}
   var activityIndicator: NVActivityIndicatorView! {get set}
   func updateProfile(for data: MyProfileInteractor.MyProfileData, completed: @escaping () -> Void)
}

protocol MyProfileLoginWorkerProotocol {
   func signUp(user: UserModel, password: String, completion: @escaping (UserModel?) -> Void)
}

protocol MyProfileLocationWorker: class {
   func requestLocation(completion: @escaping (CLLocation?) -> Void)
}

protocol MyProfileRouterProtocol {
   var view: MyProfileViewController! {get set}
   
   // There are recommendations about documenting code by link https://www.appcoda.com/documenting-source-code-in-xcode/
   
   /**
    Close MyProfile scene. It used for cancel edit profile.
    
    To use it, simply call closeCurrentViewController()
    
    :param:
    
    :returns:
    */
   func closeCurrentViewController()
   
   /**
    Skeep to the next scene. It used after finishing edit profile.
    
    To use it, simply call goToNextScene()
    
    :param:
    
    :returns:
    */
   func goToNextScene()
}
