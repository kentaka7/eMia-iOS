//
//  Helpers.swift
//  eMia
//

import UIKit

func runAfterDelay(_ delay: TimeInterval, block: @escaping () -> Void) {
  let time = DispatchTime.now() + Double(Int64(delay * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
  DispatchQueue.main.asyncAfter(deadline: time, execute: block)
}
