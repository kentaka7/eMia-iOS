//
//  Examples.swift
//  eMia
//
//  Created by Sergey Krotkih on 02/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa


//struct LoginViewModel {
//
//   var username = Variable<String>("")
//   var password = Variable<String>("")
//
//   // Computed property to retunr the result of expected validation
//   var isValid : Observable <Bool> {
//      return Observable.combineLatest(username.asObservable(), password.asObservable()){ usernameString, passwordString in
//         usernameString.count >= 4 && passwordString.count >= 4
//      }
//   }
//
//
//   _ = usernameTextField.rx.text.map { $0 ?? "" }
//   .bind(to: self.username)
//
//   _ = self.isValid.subscribe(onNext: {[unowned self] isValid in
//
//   })
//
//}
