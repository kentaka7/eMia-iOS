//
//  Log.swift
//  eMia
//
//  Created by Sergey Krotkih on 11/08/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

func Log(message: String = "", _ path: String = #file, _ function: String = #function) {
   let file = path.components(separatedBy: "/").last!.components(separatedBy: ".").first! // Sorry
   NSLog("\(file).\(function): \(message)")
}

