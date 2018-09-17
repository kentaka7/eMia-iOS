//
//  FilterDependencies.swift
//  eMia
//
//  Created by Sergey Krotkih on 2/7/18.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

class FilterDependencies: FilterDependenciesProtocol {
   
   func configure(_ view: FiltersViewController) {
      let interactor = FilterInteractor()
      let presenter = FilterPresenter()
      presenter.interactor = interactor
      view.presenter = presenter
      interactor.presenter = presenter
   }
}
