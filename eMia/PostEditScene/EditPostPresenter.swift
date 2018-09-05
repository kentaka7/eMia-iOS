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

   deinit {
      Log()
   }
   
   func configure() {
      setUpTitle()
   }
   
   private func setUpTitle() {
      let title = post.title
      view.setUpTitle(text: title)
   }

   func updateView() {
      interactor.updateView()
   }
   
   func didUpdateComments() {
      interactor.didUpdateComments()
   }
   
   func didAddComment() {
      interactor.didAddComment()
   }
   
   func closeCurrentViewController() {
      self.router.closeCurrentViewController()
   }
}
