//
//  Observable.swift
//  eMia
//

import Foundation
import Firebase

protocol AnyObservable: class {
   var observers: [Any] { get set }
   func registerObserver()
   func unregisterObserver()
}

extension AnyObservable where Self: Any {

   func unregisterObserver() {
        observers.forEach {
            switch $0 {
            case let dbRef as DatabaseReference:
                dbRef.removeAllObservers()
            case let queryRef as DatabaseQuery:
                queryRef.removeAllObservers()
            default:
                NotificationCenter.default.removeObserver($0)
            }
        }
        observers.removeAll()
    }
}
