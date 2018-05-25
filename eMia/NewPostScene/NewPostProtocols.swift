//
//  NewPostProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol NewPostPresenting: TableViewPresentable {
   var title: String {get}
   func save(_ completed: @escaping () -> Void)
}

protocol NewPostStoring {
   func saveNewPost(title: String, image: UIImage, body bodyText: String, _ completed: @escaping () -> Void)
}
