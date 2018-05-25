//
//  GalleryProtocols.swift
//  eMia
//
//  Created by Сергей Кротких on 25/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import Foundation

protocol GalleryViewProtocol {
   var galleryCollectionView: UICollectionView? { get }
   func startProgress()
   func stopProgress()
}

protocol GallerySearchable {
   func configure()
   func fetchData(searchText: String, _ completed: @escaping ([PostModel]) -> Void)
   func startSearch(_ text: String, _ completed: @escaping ([PostModel]) -> Void)
   func stopSearch()
}

protocol GalleryPresentable {
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
   func previewPhoto(for location: CGPoint) -> UIViewController?
}


