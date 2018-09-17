//
//  GalleryProtocols.swift
//  eMia
//
//  Created by Sergey Krotkih on 25/05/2018.
//  Copyright © 2018 Sergey Krotkih. All rights reserved.
//

import Foundation
import RxSwift

protocol GalleryDependenciesProtocol {
   func configure(_ view: GalleryViewController)
}

protocol GalleryViewProtocol {
   func setUpTitle(text: String)
   var galleryCollectionView: UICollectionView? { get }
   func startProgress()
   func stopProgress()
}

protocol GalleryPresenterProtocol {
   var galleryItemsCount: PublishSubject<Int> {get}
   func configureView()
   func reloadData()
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
   func previewPhoto(for location: CGPoint) -> UIViewController?
}

protocol GallerySearching {
   func configure(searchBar: UISearchBar)
}
