//
//  NewPostEditor.swift
//  eMia
//
//  Created by Sergey Krotkih on 03/09/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import UIKit

enum NewPostRows: Int {
   case title
   case body
   case photo
   static let allValues = [title, body, photo]
}

struct NewPostData {
   var title: String
   var body: String
   var image: UIImage
}

class NewPostEditor: NSObject, NewPostEditorProtocol, NewPostInteracorInput {
   private var textBodyHeight: CGFloat = 78.0
   
   weak var tableView: UITableView?
   weak var fakeTextField: UITextField?
   weak var viewController: UIViewController?
   
   private var titleCell: NewPost1ViewCell!
   private var bodyCell: NewPost2ViewCell!
   private var photoCell: NewPost3ViewCell!

   deinit {
      Log()
   }

   func configureView() {
      self.configureTableView()
   }
   
   private func configureTableView() {
      guard let tableView = self.tableView else {
         return
      }
      tableView.delegate = self
      tableView.dataSource = self
   }

   func buildNewPostData() -> NewPostData? {
      let title = titleCell.titlePostText
      if title.isEmpty {
         titleCell.invalidValue()
         return nil
      }
      guard let image = photoCell.photoImage else {
         Alert.default.showOk("", message: "Please add photo!".localized)
         return nil
      }
      let bodyText = bodyCell.postBodyText
      let data = NewPostData(title: title, body: bodyText, image: image)
      return data
   }
}

extension NewPostEditor: UITableViewDelegate, UITableViewDataSource {
   
   public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
      return self.numberOfRows
   }
   
   public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
      return self.heightCell(for: indexPath)
   }
   
   public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
      return self.cell(tableView, for: indexPath)
   }
   
   func cell(_ tableView: UITableView, for indexPath: IndexPath) -> UITableViewCell {
      if let selector = NewPostRows(rawValue: indexPath.row) {
         switch selector {
         case .title:
            return tableView.dequeueCell(ofType: NewPost1ViewCell.self)!.then { cell in
               self.titleCell = cell
            }
         case .body:
            return tableView.dequeueCell(ofType: NewPost2ViewCell.self)!.then { cell in
               self.bodyCell = cell
               bodyCell.didChangeHeight = { height in
                  if height > self.textBodyHeight {
                     self.textBodyHeight = height
                     // It prevents hiding keyboard
                     self.fakeTextField!.becomeFirstResponder()
                     tableView.reloadData()
                     delay(seconds: 0.2) {
                        // return back focus on the text view
                        _ = self.bodyCell.postBodyTextView.becomeFirstResponder()
                     }
                  }
               }
            }
         case .photo:
            return tableView.dequeueCell(ofType: NewPost3ViewCell.self)!.then { cell in
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
      if let selector = NewPostRows(rawValue: indexPath.row) {
         switch selector {
         case .title:
            return 59.0
         case .body:
            return textBodyHeight
         case .photo:
            return 364.0
         }
      } else {
         return 0.0
      }
   }
   
   var numberOfRows: Int {
      return NewPostRows.allValues.count
   }

}
