//
//  GalleryDependencies.swift
//  eMia
//

import UIKit

class GalleryDependencies {
   
   func configure(_ view: GalleryViewController) {
      let router = GalleryRouter()
      let presenter = GalleryPresenter()
      let interactor = GalleryInteractor()
      
      router.rootViewController = view
      router.interactor = interactor
      
      view.presenter = presenter
      view.layoutDelegate = presenter
      view.searcher = presenter
      
      presenter.router = router
      presenter.interactor = interactor
      presenter.view = view
      
      interactor.presenter = presenter
      interactor.collectionView = view.galleryCollectionView
   }
}
