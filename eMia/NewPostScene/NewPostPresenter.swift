//
//  NewPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class NewPostPresenter: NSObject {

   var interactor: NewPostInteractor!
   
   enum Rows: Int {
      case Title
      case Body
      case Photo
      static let allValues = [Title, Body, Photo]
   }

   internal struct CellName {
      static let newPost1ViewCell = "NewPost1ViewCell"
      static let newPost2ViewCell = "NewPost2ViewCell"
      static let newPost3ViewCell = "NewPost3ViewCell"
   }
   private var textBodyHeight: CGFloat = 78.0
   
   private var titleCell: NewPost1ViewCell!
   private var bodyCell: NewPost2ViewCell!
   private var photoCell: NewPost3ViewCell!
   
   func tableView(_ tableView: UITableView, cellFor indexPath: IndexPath, viewController: UIViewController) -> UITableViewCell {
      if let selector = Rows(rawValue: indexPath.row) {
         switch selector {
         case .Title:
            titleCell = tableView.dequeueReusableCell(withIdentifier: CellName.newPost1ViewCell) as! NewPost1ViewCell
            return titleCell
         case .Body:
            bodyCell = tableView.dequeueReusableCell(withIdentifier: CellName.newPost2ViewCell) as! NewPost2ViewCell
            bodyCell.didChangeHeight = { height in
               if height > self.textBodyHeight {
                  self.textBodyHeight = height
                  tableView.reloadData()
                  runAfterDelay(0.2) {
                     let _ = self.bodyCell.postBodyTextView.becomeFirstResponder()
                  }
               }
            }
            return bodyCell
         case .Photo:
            photoCell = tableView.dequeueReusableCell(withIdentifier: CellName.newPost3ViewCell) as! NewPost3ViewCell
            photoCell.viewController = viewController
            return photoCell
         }
      } else {
         let cell = UITableViewCell()
         return cell
      }
   }

   func tableView(_ tableView: UITableView, heightCellFor indexPath: IndexPath) -> CGFloat {
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
