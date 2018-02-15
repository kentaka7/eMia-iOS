//
//  GalleryInteractor.swift
//  eMia
//

import UIKit
import DTCollectionViewManager
import DTModelStorage

class GalleryInteractor: NSObject {

   var output: GalleryPresenter!
   var manager: DTCollectionViewManager!
   var collectionView: UICollectionView?
   var delegate: DTCollectionViewManageable!
   
   fileprivate var mFilterManager: FilterManager!
   fileprivate var mSearchText: String?
   
   func configure() {
      mFilterManager = FilterManager()
      PostsManager.postsListener() {
         let searchText = self.mSearchText ?? ""
         self.fetchData(searchText: searchText)
      }
      
      self.manager.startManaging(withDelegate: self.delegate)
      self.manager.configureEvents(for: GalleryViewCell.self) { cellType, modelType in
         self.manager.register(cellType)
         self.manager.registerHeader(GalleryHeaderView.self)
         self.manager.registerFooter(GalleryHeaderView.self)
         self.manager.sizeForCell(withItem: modelType) { [weak self] _, _ in
            
            guard let _ = self?.collectionView?.collectionViewLayout as? UICollectionViewFlowLayout else {
               return .zero
            }
            guard let w = self?.collectionView?.frame.width else {
               return .zero
            }
            let size = CGSize(width: (w / 2.0) - 6.0, height: GalleryViewController.kCellHeight)
            return size
         }
      }
   }
   
   deinit {
      PostsManager.removeListener()
   }

   func fetchData(searchText: String = "") {
      output.startProgress()
      
      DispatchQueue.global(qos: .utility).async() {
         let data = PostsManager.getData()
         let filteredData = self.filterPosts(data, searchText: searchText)
         
         DispatchQueue.main.async {
            
            let section = SectionModel()
            section.collectionHeaderModel = "Bobler near dig".localized
            // section.collectionFooterModel = "Section 0 footer"
            
            let section2 = SectionModel()
            section2.collectionHeaderModel = "Bobler i din region".localized
            
            self.deleteAllSections()
            section.items = filteredData
            section2.items = filteredData
            self.manager.memoryStorage.insertSection(section, atIndex: 0)
            self.manager.memoryStorage.insertSection(section2, atIndex: 1)
            
            self.output.stopProgress()
         }
      }
   }

   private func deleteAllSections() {
      if self.manager.memoryStorage.sections.count > 0 {
         var sections = IndexSet()
         for index in 0..<self.manager.memoryStorage.sections.count {
            sections.insert(index)
         }
         self.manager.memoryStorage.deleteSections(sections)
      }
   }

   private func filterPosts(_ posts: [PostModel], searchText: String = "") -> [PostModel] {
      mSearchText = searchText
      var filteredPosts = [PostModel]()
      for post in posts {
         // Favorities
         var addFavorite = false
         if mFilterManager.myFavoriteFilter == .myFavorite {
            if FavoritsManager.isItMyFavoritePost(post) {
               addFavorite = true
            }
         } else if mFilterManager.myFavoriteFilter == .all {
            addFavorite = true
         }
         
         var addGender = false
         var addMunicipality = false
         var addAge = false
         
         if let user = UsersManager.getUserWith(id: post.uid) {
            // Gender
            if mFilterManager.genderFilter == .both {
               addGender = true
            } else if mFilterManager.genderFilter == .boy && user.gender == .boy {
               addGender = true
            } else if mFilterManager.genderFilter == .girl && user.gender == .girl {
               addGender = true
            }
            // Municipality
            if let municipality = mFilterManager.municipality {
               if let address = user.address, address == municipality {
                  addMunicipality = true
               }
            } else {
               addMunicipality = true
            }
            
            let minAge = Int(mFilterManager.minAge)
            let maxAge = Int(mFilterManager.maxAge)
            if minAge == 0 && maxAge == 100 {
               // Don't filter by age
               addAge = true
            } else if let yearBirth = user.yearbirth, yearBirth > 0 {
               let userAge = Date().years - yearBirth
               addAge = userAge >= minAge && userAge <= maxAge
            } else {
               addAge = false
            }
         }
         
         if addFavorite && addGender && addMunicipality && addAge {
            var isValidvalue = false
            if searchText.isEmpty {
               isValidvalue = true
            } else {
               let title = post.title
               let body = post.body
               if title.lowercased().range(of: searchText.lowercased()) != nil {
                  isValidvalue = true
               } else if body.lowercased().range(of: searchText.lowercased()) != nil {
                  isValidvalue = true
               }
            }
            if isValidvalue {
               filteredPosts.append(post)
            }
         }
      }
      return filteredPosts
   }
   
}

// MARK: -

extension GalleryInteractor {

   func editPost(for indexPath: IndexPath, completion: (PostModel?) -> Void) {
      if let post = manager.storage.item(at: indexPath) as? PostModel {
         completion(post)
      } else {
         completion(nil)
      }
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
