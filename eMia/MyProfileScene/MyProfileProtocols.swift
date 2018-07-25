//
//  MyProfileProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol LocationComputing {
   func calculateWhereAmI()
}

protocol TableViewPresentable {
   var numberOfRows: Int {get}
   func heightCell(for indexPath: IndexPath) -> CGFloat
   func cell(for indexPath: IndexPath) -> UITableViewCell
}

protocol MyProfilePresenting: TableViewPresentable {
   func updateMyProfile(_ completed: @escaping () -> Void)
}

