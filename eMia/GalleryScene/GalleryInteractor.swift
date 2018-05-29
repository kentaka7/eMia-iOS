//
//  GalleryInteractor.swift
//  eMia
//
//  Created by Сергей Кротких on 27/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import RxDataSources

struct RxSectionModel {
   let title: String
   var data: [PostModel]
}

extension RxSectionModel : AnimatableSectionModelType {
   typealias Item = PostModel
   typealias Identity = String
   
   var identity: Identity {
      return title
   }
   var items: [Item] {
      return data
   }
   init(original: RxSectionModel, items: [PostModel]) {
      self = original
      data = items
   }
}

class GalleryInteractor: NSObject {
   
   var output: GalleryPresenter!
   var collectionView: UICollectionView?
   var filterManager: FilterManager!
   
   private weak var searchBar: UISearchBar!
   private var mSearchText: String?

   private let disposeBag = DisposeBag()
   
   private var dataSource: RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>?

   var data = Variable([RxSectionModel]())
   
   func configure() {
      configureRxDataSource()
      subscribeOnSelectGalleryItem()
      configureDataModelListener()
      FavoritsManager.configureDataModelListener()
      UsersManager.configureDataModelListener()
   }

   func searchConfiguration(with searchBar: UISearchBar) {
      self.searchBar = searchBar
      searchBar.delegate = self
      searchBar.rx.text                                     // observable property
         .throttle(0.5, scheduler: MainScheduler.instance)  // wait 0.5 seconds for changes
         .distinctUntilChanged()                            // check if the new value is the same as the old one
         .subscribe { [unowned self] (query) in
            if let text = query.event.element {
               self.mSearchText = text
               self.fetchData()
            }
         }
         .disposed(by: disposeBag)
   }
   
   private func configureDataModelListener() {
      _ = DataModel.postFull.asObservable().subscribe({ b in
         if let b = b.event.element, b {
            self.fetchData()
         }
      }).disposed(by: disposeBag)
      _ = DataModel.postAdd.asObservable().subscribe({ post in
            self.fetchData()
      }).disposed(by: disposeBag)
      _ = DataModel.postRemove.asObservable().subscribe({ post in
            self.fetchData()
      }).disposed(by: disposeBag)
      _ = DataModel.postUpdate.asObservable().subscribe({ post in
            self.fetchData()
      }).disposed(by: disposeBag)
   }
   
   private func subscribeOnSelectGalleryItem() {
      collectionView!.rx.itemSelected.subscribe({ [unowned self] event in
         if let indexPath = event.element {
            if let post = self.getPost(for: indexPath) {
               self.output.edit(post: post)
            }
         }
      }).disposed(by: disposeBag)
   }
   
   private func getPost(for indexPath: IndexPath) -> PostModel? {
      if indexPath.row < self.data.value[0].items.count {
         return self.data.value[0].items[indexPath.row]
      } else {
         return nil
      }
   }
}

// MARK: - DataSource

extension GalleryInteractor {
   
   func fetchData() {
      DispatchQueue.global(qos: .utility).async() {
         let posts = DataModel.posts.sorted(by: {$0.created > $1.created})
         let searchText = self.mSearchText ?? ""
         let filteredData = self.filterManager.filterPosts(posts,searchText: searchText)
         
         if self.data.value.count > 0 {

            print("'\(searchText)':\(filteredData.count)")

            return
         }
         
         DispatchQueue.main.async { [weak self] in
            let section = [RxSectionModel(title: "Near dig", data: filteredData)]
            self?.data.value.append(contentsOf: section)
            self?.bindData()
         }
      }
   }
   
   private func configureRxDataSource() {
      let dataSource = RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>(configureCell: { _, collectionView, indexPath, dataItem in
         return self.output.prepareGalleryCell(collectionView, indexPath: indexPath, post: dataItem)
      }, configureSupplementaryView: {dataSource, collectionView, kind, indexPath in
         let title = dataSource.sectionModels[indexPath.section].title
         return self.output.prepareGalleryHeader(collectionView, indexPath: indexPath, kind: kind, text: title)
      })
      self.dataSource = dataSource
   }
   
   private func bindData() {
      guard let dataSource = self.dataSource else {
         return
      }
      data.asDriver()
         .drive(self.collectionView!.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)
   }
}

// MARK: - Gallery Layout

extension GalleryInteractor: GalleryLayoutDelegate {
   
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      if let post = getPost(for: indexPath) {
         return CGSize(width: post.photoSize.0, height: post.photoSize.1)
      } else {
         return CGSize(width: 0, height: 0)
      }
   }
   
   func collectionView(_ collectionView: UICollectionView, numberOfItemsinSection: Int) -> Int {
      return data.value[numberOfItemsinSection].data.count
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

// MARK: - UISearchBarDelegate

extension GalleryInteractor: UISearchBarDelegate {
   
   public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
      if search(searchBar.text) {
         hideKeyboard()
      }
   }
   
   public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
      if needStopSearch(for: searchText) {
         hideKeyboard()
      }
   }
   
   private func search(_ text: String?) -> Bool {
      if let text = text, text.isEmpty == false {
         mSearchText = text
         fetchData()
         return true
      } else {
         return false
      }
   }
   
   private func needStopSearch(for text: String) -> Bool {
      if text.isEmpty {
         _ = search("")
         return true
      } else {
         return false
      }
   }
   
   fileprivate func hideKeyboard() {
      searchBar.resignFirstResponder()
   }
}
