//
//  GalleryInteractor.swift
//  eMia
//

import UIKit
import RxSwift
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
   
   private var mSearchText: String?

   private let disposeBag = DisposeBag()
   
   private var dataSource: RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>?

   var data = Variable([RxSectionModel]())
   
   func configure() {
      configureDataSource()
      prepareData() {
         self.prepareListenersData()
         self.subscribeOnSelectGalleryItem()
      }
   }
   
   deinit {
      PostsManager.removeListener()
   }

   private func prepareListenersData() {
      PostsManager.postsListener() {
         let searchText = self.mSearchText ?? ""
         self.fetchData(searchText: searchText) { _ in
            
         }
      }
   }
   
   private func prepareData(_ completed: @escaping () -> Void) {
      self.fetchData(searchText: "") { [weak self] posts in
         let section = [RxSectionModel(title: "Near dig", data: posts)]
         self?.data.value.append(contentsOf: section)
         DispatchQueue.main.async { [weak self] in
            self?.bindData()
            completed()
         }
      }
   }
   
   func bindData() {
      guard let dataSource = self.dataSource else {
         return
      }
      data.asDriver()
         .drive(self.collectionView!.rx.items(dataSource: dataSource))
         .disposed(by: disposeBag)
   }
   
   func configureDataSource() {
      let dataSource = RxCollectionViewSectionedAnimatedDataSource<RxSectionModel>(configureCell: { _, collectionView, indexPath, dataItem in
         return self.output.prepareGalleryCell(collectionView, indexPath: indexPath, post: dataItem)
      }, configureSupplementaryView: {dataSource, collectionView, kind, indexPath in
         let title = dataSource.sectionModels[indexPath.section].title
         return self.output.prepareGalleryHeader(collectionView, indexPath: indexPath, kind: kind, text: title)
      })
      self.dataSource = dataSource
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
   
   private func filterPosts(_ posts: [PostModel], searchText: String = "") -> [PostModel] {
      mSearchText = searchText
      return filterManager.filterPosts(posts,searchText: searchText)
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

// MARK: -

extension GalleryInteractor: GalleryLayoutDelegate {
   
   func collectionView(_ collectionView: UICollectionView, photoSizeAtIndexPath indexPath: IndexPath) -> CGSize {
      let post = self.data.value[0].items[indexPath.row]
      return CGSize(width: post.photoSize.0, height: post.photoSize.1)
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
