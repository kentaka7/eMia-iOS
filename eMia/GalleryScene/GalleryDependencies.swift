//
//  GalleryDependencies.swift
//  eMia
//

import UIKit
import DTCollectionViewManager

class GalleryDependencies {

   static func configure(view: GalleryViewController) {
      let router = GalleryRouter()
      let presenter = GalleryPresenter()
      let interactor = GalleryInteractor()

      router.rootViewController = view
      
      view.eventHandler = presenter
      view.presenter = presenter
      
      presenter.router = router
      presenter.interactor = interactor
      presenter.view = view
      
      interactor.output = presenter
      interactor.delegate = view
      interactor.collectionView = view.galleryCollectionView
      interactor.manager = view.galleryManager
   }
}
