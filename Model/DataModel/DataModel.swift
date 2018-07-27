//
//  DataModel.swift
//  eMia
//
//  Created by Сергей Кротких on 27/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import Firebase
import RealmSwift
import RxRealm

typealias UserObserverClosure = (UserModel) -> Void
typealias DidUpdateObserverClosure = () -> Void

protocol CommentsDataBaseObservable {
    func addItem(_ item: CommentItem)
    func deleteItem(_ item: CommentItem)
    func editItem(_  item: CommentItem)
}

enum PostServiceError: Error {
    case creationFailed
    case updateFailed(PostModel)
    case deletionFailed(PostModel)
    case toggleFailed(PostModel)
}

internal let gDataModel = DataModelInteractor.sharedInstance

class DataModelInteractor: NSObject {
    
    let kFetchingDataAsync = true
    let disposeBag = DisposeBag()
    
    static let sharedInstance: DataModelInteractor = {
        return AppDelegate.instance.fetchingManager
    }()
    
    private var usersObserver = UsersObserver()
    private var postsObserver = PostsObserver()
    private var favoritiesObserver = FavoritiesObserver()
    private var commnetsObserver = CommentsObserver()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    func fetchData(completion: @escaping () -> Void) {
        if PostModel.rxPosts.value.count > 0 {
            completion()
            return
        }
        semaphore.wait()
        
        var fetchDataFunc: (@escaping() -> Void) -> Void
        
        if kFetchingDataAsync {
            fetchDataFunc = fetchDataAsync
        } else {
            fetchDataFunc = fetchDataSync
        }
        fetchDataFunc {
            self.semaphore.signal()
            print("users=\(UserModel.rxUsers.value.count);posts=\(PostModel.rxPosts.value.count);favorities=\(FavoriteModel.rxFavorities.value.count)")
            self.startListeners()
            DispatchQueue.main.async {
                completion()
            }
        }
    }
    
    private func startListeners() {
        self.usersObserver.startListening()
        self.postsObserver.startListening()
        self.favoritiesObserver.startListening()
        self.commnetsObserver.startListening()
    }
    
    class func withRealm<T>(_ operation: String, action: (Realm) throws -> T) -> T? {
        do {
            let realm = try Realm()
            return try action(realm)
        } catch let err {
            print("Failed \(operation) realm with error: \(err)")
            return nil
        }
    }

    class func saveWithRealm(_ closure: () -> Void) {
        do {
            let realm = try Realm()
            try realm.write {
                closure()
            }
        } catch let err {
            print("Failed save to user realm with error: \(err)")
            return
        }
    }
}

extension DataModelInteractor {
    
    fileprivate func fetchDataSync(completion: @escaping () -> Void) {
        var currentTime = CFAbsoluteTimeGetCurrent()
        
        self.fetchAllUsers {
            self.fetchAllPosts {
                self.fetchAllFavorities {
                    self.fetchAllComments {

                        currentTime = (CFAbsoluteTimeGetCurrent() - currentTime) * 1000.0
                        print("Fetching all dats took \(currentTime) milliseconds")
                        
                        completion()
                        
                    }
                }
            }
        }
    }
    
    fileprivate func fetchDataAsync(completion: @escaping () -> Void) {
        var currentTime = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.async {
            let usersRef = gFireBaseManager.firebaseRef.child(UserFields.users)
            let postsRef = gFireBaseManager.firebaseRef.child(PostItemFields.posts)
            let favoritiesRef = gFireBaseManager.firebaseRef.child(FavoriteItemFields.favorits)
            let commentsRef = gFireBaseManager.firebaseRef.child(CommentItemFields.comments)
            let fetchingGroup = DispatchGroup()
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllUsers(usersRef) {
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllPosts(postsRef) {
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllFavorities(favoritiesRef) {
                    fetchingGroup.leave()
                }
            })

            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllComments(commentsRef) {
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.notify(queue: DispatchQueue.main) {
                
                currentTime = (CFAbsoluteTimeGetCurrent() - currentTime) * 1000.0
                print("Fetching all dats took \(currentTime) milliseconds")
                
                completion()
            }
        }
    }
}

// MARK: - Fetching data

extension DataModelInteractor {
    
    private func fetchAllUsers(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let usersRef = dbRef ?? gFireBaseManager.firebaseRef.child(UserFields.users).queryOrdered(byChild: "\\")
        usersRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = UserItem(childSnap)
                        UserModel.addUser(item)
                    }
                }
                UserModel.rxUsers.value.append(contentsOf: UserModel.users)
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllPosts(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let postsRef = dbRef ?? gFireBaseManager.firebaseRef.child(PostItemFields.posts).queryOrdered(byChild: "\\")
        postsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = PostItem(childSnap)
                        PostModel.addPost(item)
                    }
                }
                PostModel.rxPosts.value.append(contentsOf: PostModel.posts)
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllFavorities(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let favoritiesRef = dbRef ?? gFireBaseManager.firebaseRef.child(FavoriteItemFields.favorits).queryOrdered(byChild: "\\")
        favoritiesRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if childSnap.value as? [String: String] != nil {
                            let item = FavoriteItem(childSnap)
                            FavoriteModel.addFavorite(item)
                        }
                    }
                }
                FavoriteModel.rxFavorities.value.append(contentsOf: FavoriteModel.favorities)
                completion()
            }).disposed(by: disposeBag)
    }
    
    func fetchAllComments(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let commentsRef = dbRef ?? gFireBaseManager.firebaseRef.child(CommentItemFields.comments).queryOrdered(byChild: "\\")
        commentsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = CommentItem(childSnap)
                        CommentModel.addComment(item)
                    }
                }
                CommentModel.rxComments.value.append(contentsOf: CommentModel.comments)
                completion()
            }).disposed(by: disposeBag)
    }
}
