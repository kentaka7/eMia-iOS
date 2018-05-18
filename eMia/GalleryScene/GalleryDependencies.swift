//
//  GalleryDependencies.swift
//  eMia
//

import UIKit

class GalleryDependencies {

   static func configure(view: GalleryViewController) {
      let router = GalleryRouter()
      let presenter = GalleryPresenter()
      let interactor = GalleryInteractor()
    let filterManager = FilterManager()

      router.rootViewController = view
      
      view.eventHandler = presenter
      view.presenter = presenter
      
      presenter.router = router
      presenter.interactor = interactor
      presenter.view = view
      
      interactor.output = presenter
      interactor.collectionView = view.galleryCollectionView
      interactor.filterManager = filterManager
   }
}
