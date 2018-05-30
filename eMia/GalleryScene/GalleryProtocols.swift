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

protocol GalleryPresentable {
   var title: String {get}
   func configure()
   func reloadData()
   func prepare(for segue: UIStoryboardSegue, sender: Any?)
   func previewPhoto(for location: CGPoint) -> UIViewController?
}

protocol GallerySearching {
   func configure(searchBar: UISearchBar)
}

protocol PostsFiltering {
   func filterPosts(_ posts: [PostModel], searchText: String) -> [PostModel]
}
