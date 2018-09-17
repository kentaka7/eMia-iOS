//
//  MyProfileProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import CoreLocation
import NVActivityIndicatorView

protocol LocationComputing: class {
   func calculateWhereAmI()
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
   func configure(_ view: MyProfileViewController)
}

protocol MyProfileViewProtocol: class {
   var user: UserModel! {get}
   var editor: MyProfileEditorProtocol! {get set}
   var tableView: UITableView! {get set}
   var saveDataButton: UIButton! {get set}
   var backBarButtonItem: UIBarButtonItem! {get set}
   func setUpTitle(text: String)
}

protocol MyProfileInteractorProtocol {
   var loginWorker: MyProfileLoginWorkerProotocol! {get set}
   var tableView: UITableView! {get set}
   var activityIndicator: NVActivityIndicatorView! {get set}
   func saveData(_ completion: @escaping () -> Void)
}

protocol MyProfileInteractorInput: class {
   func myProfileData() -> MyProfileData?
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
    
    :param: registrationNewUser = true if it is registration an new user
    
    :returns:
    */
   func goToNextScene(registrationNewUser: Bool)
}

protocol MyProfileEditorProtocol {
   func configureView()
}

