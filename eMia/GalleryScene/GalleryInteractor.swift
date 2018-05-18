//
//  GalleryInteractor.swift
//  eMia
//

import UIKit

class GalleryInteractor: NSObject {
    
    var output: GalleryPresenter!
    var collectionView: UICollectionView?
    var filterManager: FilterManager!
    
    fileprivate var mSearchText: String?
    
    func configure() {
        PostsManager.postsListener() {
            let searchText = self.mSearchText ?? ""
         self.fetchData(searchText: searchText) { _ in
            
         }
        }
    }

    deinit {
        PostsManager.removeListener()
    }
   
   func fetchData(searchText: String = "", _ completed: @escaping ([PostModel]) -> Void) {
      DispatchQueue.global(qos: .utility).async() {
         let data = PostsManager.getData()
         let filteredData = self.filterPosts(data, searchText: searchText)
         DispatchQueue.main.async {
            completed(filteredData)
         }
      }
   }
   
    func filterPosts(_ posts: [PostModel], searchText: String = "") -> [PostModel] {
        mSearchText = searchText
        return filterManager.filterPosts(posts,searchText: searchText)
    }
}

// MARK: - Preview Photo

extension GalleryInteractor {
    
    func previewPhoto(for location: CGPoint) -> UIImage? {
        guard let indexPath = collectionView?.indexPathForItem(at: location) else {
            return nil
        }
        guard let image = getPhotoFor(indexPath: indexPath) else {
            return nil
        }
        return image
    }
    
    private func getPhotoFor(indexPath: IndexPath) -> UIImage? {
        guard let cell = collectionView?.cellForItem(at: indexPath) as? GalleryViewCell, let photoImageView = cell.photoImageView  else {
            return nil
        }
        return photoImageView.image
    }
}
