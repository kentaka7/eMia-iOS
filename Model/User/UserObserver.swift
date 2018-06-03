//
//  UserObserver.swift
//  eMia
//

import UIKit
import RxSwift

class UserObserver: NSObject {

   fileprivate var observers: Array<(users: [UserModel], closure: UserObserverClosure)> = []

   func addObserver(users: [UserModel], closure: @escaping UserObserverClosure) {
      removeObservers(users)
      observers.append((users, closure))
      _ = DataModel.rxUsers.asObservable().subscribe({ users in
         guard let users = users.event.element else {
            return
         }
         self.didUserUpdate(users)
      })
   }
   
   func removeObservers(_ users: [UserModel]) {
      if observers.count == 0 {
         return
      }
      var observerIndex = 0
      for item in observers {
         let itemUsers = item.users
         var counter = itemUsers.count
         if counter == users.count {
            for index in 0..<users.count {
               let user = users[index]
               let itemUser = itemUsers[index]
               if itemUser.userId == user.userId {
                  counter -= 1
               }
            }
         }
         if counter == 0 {
            observers.remove(at: observerIndex)
            break
         }
         observerIndex += 1
      }
   }

   private func didUserUpdate(_ userItems: [UserModel]) {
      for userItem in userItems {
         for observer in observers {
            let users = observer.users
            for user in users {
               if user.userId == userItem.userId {
                  observer.closure(userItem)
                  return
               }
            }
         }
      }
   }
}
