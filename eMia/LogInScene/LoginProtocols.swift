//
//  LoginProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation
import RxSwift

protocol LogInValidating {
   var email: BehaviorSubject<String> {get}
   var password: BehaviorSubject<String> {get}
   var isValid: Observable<Bool> {get}
}

protocol LogInActing {
   func signIn(completion: @escaping (LoginPresenter.LoginError?) -> Void)
   func signUp(completion: (LoginPresenter.LoginError?) -> Void)
}

protocol LogInRouting {
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
}

