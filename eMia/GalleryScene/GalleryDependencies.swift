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
      let filterModel = FilterModel.data
      
      router.rootViewController = view
      
      view.presenter = presenter
      view.layoutDelegate = presenter
      view.searcher = presenter
      
      presenter.router = router
      presenter.interactor = interactor
      presenter.view = view
      
      interactor.presenter = presenter
      interactor.collectionView = view.galleryCollectionView
      interactor.filter = filterModel
   }
}
