//
//  String.swift
//  eMia
//

import UIKit

extension String {

   func isValidEmail() -> Bool {
      let pattern = "^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$"
      if let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) {
         return regex.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.count)) != nil
      } else {
         return false
      }
   }
   
   static func getDocumentsPath() -> String {
      let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
      return documentsPath
   }
   
}
