//
//  EditPostPresenter.swift
//  eMia
//
//  Created by Сергей Кротких on 20/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit

class EditPostPresenter: NSObject, EditPostPresenterProtocol {
   var numberOfRows: Int = 0
   
   weak var view: EditPostViewProtocol!
   weak var post: PostModel!

   var interactor: EditPostInteractor!
   var router: EditPostRouterProtocol!
   
   private var editor: EditPostEditor!

   deinit {
      Log()
   }
   
   func configure() {
      editor = EditPostEditor(view: view, interactor: interactor)
      editor.configure()
   }
   
   var title: String {
      return post.title
   }
   
   func updateView() {
      editor.updateView()
   }
   
   func didUpdateComments() {
      editor.didUpdateComments()
   }
   
   func didAddComment() {
      editor.didAddComment()
   }
   
   func didPressOnBackButton() {
      self.router.closeCurrentViewController()
   }
}
