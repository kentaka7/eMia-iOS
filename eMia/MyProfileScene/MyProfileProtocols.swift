//
//  MyProfileProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import CoreLocation

protocol LocationComputing {
   func calculateWhereAmI()
}

protocol TableViewPresentable {
   var numberOfRows: Int {get}
   func heightCell(for indexPath: IndexPath) -> CGFloat
   func cell(for indexPath: IndexPath) -> UITableViewCell
}

protocol MyProfilePresenterProtocol {
   func configureView()
}

protocol MyProfileDependenciesProtocol {
   func configure(view: MyProfileViewController, user: UserModel?)
}

protocol MyProfileViewProtocol {
   var tableView: UITableView! {get set}
   var saveDataButton: UIButton! {get set}
   var backBarButtonItem: UIBarButtonItem! {get set}
   var registrationNewUser: Bool {get}
   func close()
}

protocol MyProfileInteractorProtocol {
   func updateProfile(for data: MyProfileInteractor.MyProfileData, completed: @escaping () -> Void)
}

protocol MyProfileLoginWorkerProotocol {
   func signUp(user: UserModel, password: String, completion: @escaping (UserModel?) -> Void)
}

protocol MyProfileLocationWorker {
   func requestLocation(completion: @escaping (CLLocation?) -> Void)
}

protocol MyProfilePouterProtocol {
   /**
    Close MyProfile scene. It used for cancel edit profile.
    
    To use it, simply call closeScene()
    
    :param:
    
    :returns:
    */
   func closeScene()
   
   /**
    Skeep to the next scene. It used after finishing edit profile.
    
    To use it, simply call goToNextScene()
    
    :param:
    
    :returns:
    */
   func goToNextScene()
}
