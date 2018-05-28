//
//  ModelData.swift
//  eMia
//
//  Created by Сергей Кротких on 27/05/2018.
//  Copyright © 2018 Coded I/S. All rights reserved.
//

import UIKit
import RxSwift
import Firebase

typealias UserObserverClosure = (UserModel) -> Void
typealias DidUpdateObserverClosure = () -> ()

protocol UsersDataUpdating {
    func newUserItem()
    func updatedUserItem(_ userItem: UserItem)
    func removedUserItem()
}

protocol PostsDataBaseObservable {
    func addItem(_ item: PostItem)
    func deleteItem(_ item: PostItem)
    func editItem(_  item: PostItem)
}

protocol FavoritesDataBaseObservable {
    func addItem(_ item: FavoriteItem)
    func deleteItem(_ item: FavoriteItem)
    func editItem(_  item: FavoriteItem)
}

protocol CommentsDataBaseObservable {
    func addItem(_ item: CommentItem)
    func deleteItem(_ item: CommentItem)
    func editItem(_  item: CommentItem)
}

internal let ModelData = FetchingWorker.sharedInstance

class FetchingWorker: NSObject {
    
    let FETCHING_DATA_ASYNC = true
    let disposeBag = DisposeBag()
    
    static let sharedInstance: FetchingWorker = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.fetchingManager
    }()
    
    fileprivate var _users = [UserItem]()
    fileprivate var _posts = [PostItem]()
    fileprivate var _favorities = [FavoriteItem]()
    
    fileprivate var usersObserver = UsersObserver()
    fileprivate var postsObserver = PostsObserver()
    fileprivate var favoritiesObserver = FavoritiesObserver()
    
    fileprivate var dataFetched = false
    
    var usersOutput: UsersDataUpdating!
    var postsOutput: PostsDataBaseObservable?
    var favoritiesOutput: FavoritesDataBaseObservable?
    var commentsOutput: CommentsDataBaseObservable?
    
    let queueUsers = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).usersQueue")
    let queuePosts = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).postsQueue")
    let queueFavorities = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).favoritiesQueue")
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var users: [UserItem] {
        return queueUsers.sync{_users}
    }
    
    var posts: [PostItem] {
        return queuePosts.sync{_posts}
    }
    
    var favorities: [FavoriteItem] {
        return queuePosts.sync{_favorities}
    }
    
    func fetchData(completion: @escaping () -> Void) {
        if dataFetched {
            completion()
            return
        }
        semaphore.wait()
        
        var fetchDataFunc: (@escaping() -> Void) -> Void
        
        if FETCHING_DATA_ASYNC {
            fetchDataFunc = fetchDataAsync
        } else {
            fetchDataFunc = fetchDataSync
        }
        fetchDataFunc() {
            self.dataFetched = true
            self.semaphore.signal()
            self.didDownloadAllData(completion)
        }
    }
    
    private func didDownloadAllData(_ completion: @escaping () -> Void) {
        print("users=\(self.users.count);posts=\(self.posts.count);favorities=\(self.favorities.count)")
        self.startListeners()
        DispatchQueue.main.async {
            completion()
        }
    }
    
    private func startListeners() {
        startUsersListener()
        startPostListener()
        startFavoritiesListener()
    }

    private func startUsersListener() {
        self.usersOutput = UsersManager
        let o = self.usersObserver.addObserver()
        _ = o.add.subscribe({ addedItem in
            self.addUserListener(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editUserListener(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deleteUserListener(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
    }
    
    private func startPostListener() {
        self.postsOutput = PostsManager
        let o = self.postsObserver.addObserver()
        _ = o.add.subscribe({ addedItem in
            self.addPostsListener(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editPostsListener(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deletePostsListener(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
    }

    private func startFavoritiesListener() {
        self.favoritiesOutput = FavoritsManager
        let o = self.favoritiesObserver.addObserver()
        _ = o.add.subscribe({ addedItem in
            self.addFavorite(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editFavorite(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deleteFavorite(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
    }
}

extension FetchingWorker {
    
    fileprivate func fetchDataSync(completion: @escaping () -> Void) {
        var x = CFAbsoluteTimeGetCurrent()
        
        self.fetchAllUsers(){
            self.fetchAllPosts(){
                self.fetchAllFavorities(){
                    
                    x = (CFAbsoluteTimeGetCurrent() - x) * 1000.0
                    print("Fetching all dats took \(x) milliseconds")
                    
                    completion()
                }
            }
        }
    }
    
    fileprivate func fetchDataAsync(completion: @escaping () -> Void) {
        var x = CFAbsoluteTimeGetCurrent()
        
        DispatchQueue.main.async {
            let usersRef = FireBaseManager.firebaseRef.child(UserFields.users)
            let postsRef = FireBaseManager.firebaseRef.child(PostItemFields.posts)
            let favoritiesRef = FireBaseManager.firebaseRef.child(FavoriteItemFields.favorits)
            let fetchingGroup = DispatchGroup()
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllUsers(usersRef){
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllPosts(postsRef){
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllFavorities(favoritiesRef){
                    fetchingGroup.leave()
                }
            })
            
            fetchingGroup.notify(queue: DispatchQueue.main) {
                
                x = (CFAbsoluteTimeGetCurrent() - x) * 1000.0
                print("Fetching all dats took \(x) milliseconds")
                
                completion()
            }
        }
    }
}

// MARK: - Fetching data

extension FetchingWorker {
    
    fileprivate func fetchAllUsers(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let usersRef = dbRef ?? FireBaseManager.firebaseRef.child(UserFields.users).queryOrdered(byChild: "\\")
        usersRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = UserItem(childSnap)
                        self.queueUsers.async {
                            self._users.append(item)
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
    
    fileprivate func fetchAllPosts(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let postsRef = FireBaseManager.firebaseRef.child(PostItemFields.posts).queryOrdered(byChild: "\\")
        postsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = PostItem(childSnap)
                        self.queuePosts.async {
                            self._posts.append(item)
                        }
                    }
                }
                completion()
           }).disposed(by: disposeBag)
    }
    
    fileprivate func fetchAllFavorities(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let favoritiesRef = FireBaseManager.firebaseRef.child(FavoriteItemFields.favorits).queryOrdered(byChild: "\\")
        favoritiesRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if let _ = childSnap.value as? Dictionary<String, String> {
                            let item = FavoriteItem(childSnap)
                            self.queueFavorities.async {
                                self._favorities.append(item)
                            }
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
    
    func fetchAllComments(_ dbRef: DatabaseReference? = nil, for post: PostModel, addComment: @escaping (CommentItem) -> Void, completion: @escaping () -> Void) {
        guard let postId = post.id else {
            completion()
            return
        }
        let commentsRef = dbRef ?? FireBaseManager.firebaseRef.child(CommentItemFields.comments).child(postId).queryOrdered(byChild: "\\")
        commentsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = CommentItem(childSnap)
                        addComment(item)
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
}

// MARK: - changes on the firebase database listeners

// users database updated

extension FetchingWorker {
    
    func addUserListener(_ item: UserItem) {
        if let _ = usersIndex(of: item) {
            return
        } else {
            self.queueUsers.async {
                self._users.append(item)
                self.usersOutput.newUserItem()
            }
        }
    }
    
    func deleteUserListener(_ item: UserItem) {
        if let index = usersIndex(of: item) {
            self.queueUsers.async {
                self._users.remove(at: index)
                self.usersOutput.removedUserItem()
            }
        }
    }
    
    func editUserListener(_  item: UserItem) {
        if let index = usersIndex(of: item) {
            self.queueUsers.async {
                self._users[index] = item
                self.usersOutput.updatedUserItem(item)
            }
        }
    }
    
    fileprivate func usersIndex(of item: UserItem) -> Int? {
        let index = users.index(where: {$0 == item})
        return index
    }
}

// Posts database updated

extension FetchingWorker {
    
    func addPostsListener(_ item: PostItem) {
        if let _ = postsIndex(of: item) {
        } else {
            self.queuePosts.async {
                self._posts.append(item)
                self.postsOutput?.addItem(item)
            }
        }
    }
    
    func deletePostsListener(_ item: PostItem) {
        if let index = postsIndex(of: item) {
            self.queuePosts.async {
                self._posts.remove(at: index)
                self.postsOutput?.deleteItem(item)
            }
        }
    }
    
    func editPostsListener(_  item: PostItem) {
        if let index = postsIndex(of: item) {
            self.queuePosts.async {
                self._posts[index] = item
                self.postsOutput?.editItem(item)
            }
        }
    }
    
    fileprivate func postsIndex(of item: PostItem) -> Int? {
        let index = posts.index(where: {$0 == item})
        return index
    }
}

// favorities database updated

extension FetchingWorker {
    
    func addFavorite(_ item: FavoriteItem) {
        if let _ = favoritiesIndex(of: item) {
        } else {
            self.queueFavorities.async {
                self._favorities.append(item)
                self.favoritiesOutput?.addItem(item)
            }
        }
    }
    
    func deleteFavorite(_ item: FavoriteItem) {
        if let index = favoritiesIndex(of: item) {
            self.queueFavorities.async {
                self._favorities.remove(at: index)
                self.favoritiesOutput?.deleteItem(item)
            }
        }
    }
    
    func editFavorite(_  item: FavoriteItem) {
        if let index = favoritiesIndex(of: item) {
            self.queueFavorities.async {
                self._favorities[index] = item
                self.favoritiesOutput?.editItem(item)
            }
        }
    }
    
    fileprivate func favoritiesIndex(of item: FavoriteItem) -> Int? {
        let index = favorities.index(where: {$0 == item})
        return index
    }
}
