//
//  ObserverProtocol.swift
//  eMia
//

import Foundation
import Firebase

@objc protocol ObserverProtocol: class {
   var observers: [Any] { get set }
   func registerObserver()
   func unregisterObserver()
}

//extension ObserverProtocol where Self: Any{
//    func unregisterObserver() {
//        observers.forEach {
//            
//            switch $0 {
//            case let dbRef as DatabaseReference:
//                dbRef.removeAllObservers()
//            case let queryRef as DatabaseQuery:
//                queryRef.removeAllObservers()
//            default:
//                NotificationCenter.default.removeObserver($0)
//            }
//        }
//        observers.removeAll()
//    }
//}
