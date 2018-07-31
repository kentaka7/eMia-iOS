//
//  EditPostProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol EditPostPresenting: TableViewPresentable {
   var title: String {get}
   func configure()
   func updateView()
}
