//
//  NewPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostPresenter: NSObject, NewPostPresenting {

   var interactor: NewPostStoring!
   var tableView: UITableView!
   var viewController: UIViewController!
   
   enum Rows: Int {
      case Title
      case Body
      case Photo
      static let allValues = [Title, Body, Photo]
   }

   private var textBodyHeight: CGFloat = 78.0
   
   private var titleCell: NewPost1ViewCell!
   private var bodyCell: NewPost2ViewCell!
   private var photoCell: NewPost3ViewCell!
   
   var title: String {
      return "\(AppConstants.ApplicationName) - My New Post".localized
   }
   
   func cell(for indexPath: IndexPath) -> UITableViewCell {
      if let selector = Rows(rawValue: indexPath.row) {
         switch selector {
         case .Title:
            return tableView.dequeueCell(ofType: NewPost1ViewCell.self).then { cell in
               self.titleCell = cell
            }
         case .Body:
            return tableView.dequeueCell(ofType: NewPost2ViewCell.self).then { cell in
               self.bodyCell = cell
               bodyCell.didChangeHeight = { height in
                  if height > self.textBodyHeight {
                     self.textBodyHeight = height
                     self.tableView.reloadData()
                     runAfterDelay(0.2) {
                        let _ = self.bodyCell.postBodyTextView.becomeFirstResponder()
                     }
                  }
               }
            }
         case .Photo:
            return tableView.dequeueCell(ofType: NewPost3ViewCell.self).then { cell in
               self.photoCell = cell
               self.photoCell.viewController = viewController
            }
         }
      } else {
         let cell = UITableViewCell()
         return cell
      }
   }

   func heightCell(for indexPath: IndexPath) -> CGFloat {
      if let selector = Rows(rawValue: indexPath.row) {
         switch selector {
         case .Title:
            return 59.0
         case .Body:
            return textBodyHeight
         case .Photo:
            return 364.0
         }
      } else {
         return 0.0
      }
   }

   var numberOfRows: Int {
      return Rows.allValues.count
   }
}

// MARK: - Create new Post

extension NewPostPresenter {
   
   func save(_ completed: @escaping () -> Void) {
      let title = titleCell.titlePostText
      if title.isEmpty {
         titleCell.invalidValue()
         return
      }
      guard let image = photoCell.photoImage else {
         Alert.default.showOk("", message: "Please add photo to your post!".localized)
         return
      }
      let bodyText = bodyCell.postBodyText
      interactor.saveNewPost(title: title, image: image, body: bodyText, completed)
   }
}
