//
//  FilterProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol FilterStoragable {
   func fetchFilterPreferences()
   func saveFilterPreferences()
}

