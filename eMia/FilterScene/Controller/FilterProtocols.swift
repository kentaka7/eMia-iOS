//
//  FilterProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation

protocol FilterDependenciesProtocol {
   func configure(_ view: FiltersViewController)
}

protocol FilterStoragable {
   func fetchFilterPreferences()
   func saveFilterPreferences()
}

protocol FilterPresented {
   func showCurrentFilterState()
   func saveCurrentFilterState()
   func addShowMeComponent(_ bacgroundView: UIView)
   func addFavoriteStatusComponent(_ bacgroundView: UIView)
   func addMunicipalityComponent(_ bacgroundView: UIView)
   func addAggesComponent(_ bacgroundView: UIView)
}
