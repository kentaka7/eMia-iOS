//
//  Helpers.swift
//  eMia
//

import UIKit

// A delay function
func delay(seconds: Double, completion: @escaping ()-> Void) {
   DispatchQueue.main.asyncAfter(deadline: .now() + seconds, execute: completion)
}
