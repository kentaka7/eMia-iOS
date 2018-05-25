//
//  CollectionViewController.swift
//  eMia
//

import UIKit
import NVActivityIndicatorView
import RxSwift
import RxDataSources

class GalleryViewController: UIViewController, UICollectionViewDelegateFlowLayout {
   static let kHeaderHeight: CGFloat = 40.0
   static let kCellHeight: CGFloat = 250.0

   var presenter: GalleryPresentable!
   var interactor: GallerySearchable!
   var layoutDelegate: GalleryLayoutDelegate!
   
   private var refreshControl: UIRefreshControl!
   private var mSearchText: String = ""
   private let disposeBag = DisposeBag()
   
   @IBOutlet weak var collectionView: UICollectionView?
   @IBOutlet weak var newPostButton: UIButton!
   
   @IBOutlet weak var searchBackgroundView: UIView!
   @IBOutlet weak var searchBar: UISearchBar!
   @IBOutlet weak var searchBaxckgroundViewTopConstraint: NSLayoutConstraint!
   
   @IBOutlet weak var activityIndicatorView: NVActivityIndicatorView!
   
   @IBAction func exitToGalleryController(_ segue: UIStoryboardSegue) {
   }
   
   override func viewDidLoad() {
      super.viewDidLoad()
      
      navigationItem.title = "\(AppConstants.ApplicationName)"
      
      refreshControl = UIRefreshControl()
      refreshControl?.addTarget(self, action: #selector(simulateRefresh), for: .valueChanged)
      collectionView?.refreshControl = refreshControl
      
      GalleryDependencies.configure(view: self)
      interactor.configure()
      configureSubviews()
   }
   
   override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      
      let searchText = searchBar.text ?? ""
      self.interactor.fetchData(searchText: searchText) { _ in
         
      }
   }
   
   override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      presenter.prepare(for: segue, sender: sender)
   }
   
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      self.view.endEditing(true)
      searchBar.resignFirstResponder()
   }
   
   @objc func simulateRefresh() {
      DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
         self.refreshControl?.endRefreshing()
      }
   }
}

// MARK: - Provate methods

extension GalleryViewController {
   
   private func configureSubviews() {
      configure(searchBar)
      configure(newPostButton)
      configure(collectionView!)
      configure(searchBackgroundView)
      setUp3DPreviewPhoto()
   }
   
   private func configure(_ view: UIView) {
      switch view {
      case newPostButton:
         newPostButton.layer.cornerRadius = newPostButton.frame.width / 2.0
         newPostButton.backgroundColor = GlobalColors.kBrandNavBarColor
      case collectionView!:
         collectionView!.backgroundColor = UIColor.clear
         collectionView!.contentInset = UIEdgeInsets(top: 23, left: 10, bottom: 10, right: 10)
         if let layout = collectionView!.collectionViewLayout as? GalleryLayout {
            layout.delegate = layoutDelegate
         }
      case searchBackgroundView:
         searchBackgroundView.backgroundColor = GlobalColors.kBrandNavBarColor
      case searchBar:
         searchBar.delegate = self
         searchBar.tintColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundColor = GlobalColors.kBrandNavBarColor
         searchBar.backgroundImage = UIImage()
         searchBar.placeholder = "Search template".localized
      default:
         break
      }
   }
   
   private func setUp3DPreviewPhoto() {
      if traitCollection.forceTouchCapability == .available {
         registerForPreviewing(with: self, sourceView: collectionView!)
      }
   }
   
   private func setUpHeaderSize() {
      let headerSize = CGSize(width: self.view.frame.width, height: GalleryViewController.kHeaderHeight)
      (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.headerReferenceSize = headerSize
   }
   
   private func setUpFooterSize() {
      let footerSize = CGSize(width: self.view.frame.width, height: GalleryViewController.kHeaderHeight)
      (collectionView?.collectionViewLayout as? UICollectionViewFlowLayout)?.footerReferenceSize = footerSize
   }
}

// MARK: - View Protocol

extension GalleryViewController: GalleryViewProtocol {
   
   var galleryCollectionView: UICollectionView? {
      return self.collectionView
   }
   
   func startProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.startAnimating()
      }
   }
   
   func stopProgress() {
      DispatchQueue.main.async {
         self.activityIndicatorView.stopAnimating()
      }
   }
}

// MARK: - Hide/Show search bar while scrolling up/down

extension GalleryViewController {
   
   public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      hideKeyboard()
      if(scrollView.panGestureRecognizer.translation(in: scrollView.superview).y > 0)
      {
         searchBaxckgroundViewTopConstraint.constant = 0.0
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      }
      else
      {
         searchBaxckgroundViewTopConstraint.constant = -64.0
         UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
            self.view.layoutIfNeeded()
         }, completion: nil)
      }
   }
}

// MARK: - UISearchBarDelegate

extension GalleryViewController: UISearchBarDelegate {
   
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
         interactor.startSearch(text) { _ in
         }
         return true
      } else {
         return false
      }
   }
   
   private func needStopSearch(for text: String) -> Bool {
      if text.isEmpty {
         interactor.stopSearch()
         return true
      } else {
         return false
      }
   }
   
   fileprivate func hideKeyboard() {
      searchBar.resignFirstResponder()
   }
}

// MARK: - UIViewControllerPreviewingDelegate

extension GalleryViewController: UIViewControllerPreviewingDelegate {
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing,
                          commit viewControllerToCommit: UIViewController) {
      
   }
   
   func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
      return presenter.previewPhoto(for: location)
   }
}
