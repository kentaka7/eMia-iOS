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

typealias UserObserverClosure = (UserModel) -> Void
typealias DidUpdateObserverClosure = () -> ()

protocol UsersDataUpdating {
    func newUserItem()
    func updatedUserItem(_ userItem: UserItem)
    func removedUserItem()
}

protocol CommentsDataBaseObservable {
    func addItem(_ item: CommentItem)
    func deleteItem(_ item: CommentItem)
    func editItem(_  item: CommentItem)
}

internal let DataModel = FetchingWorker.sharedInstance

class FetchingWorker: NSObject {
    
    let FETCHING_DATA_ASYNC = true
    let disposeBag = DisposeBag()
    
    static let sharedInstance: FetchingWorker = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.fetchingManager
    }()
    
    fileprivate var _users = [UserItem]()
    fileprivate var _posts = [PostModel]()
    fileprivate var _favorities = [FavoriteItem]()
    
    fileprivate var usersObserver = UsersObserver()
    fileprivate var postsObserver = PostsObserver()
    fileprivate var favoritiesObserver = FavoritiesObserver()
    
    fileprivate var dataFetched = false
    
    var usersOutput: UsersDataUpdating!

    var favAdd = Variable<FavoriteItem>(FavoriteItem())
    var favRemove = Variable<FavoriteItem>(FavoriteItem())
    var favUpdate = Variable<FavoriteItem>(FavoriteItem())
    
    var postFull = Variable<Bool>(false)
    var postAdd = Variable<PostModel>(PostModel())
    var postRemove = Variable<PostModel>(PostModel())
    var postUpdate = Variable<PostModel>(PostModel())
    
    let queueUsers = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).usersQueue")
    let queuePosts = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).postsQueue")
    let queueFavorities = DispatchQueue(label: "\(AppConstants.ManufacturingName).\(AppConstants.ApplicationName).favoritiesQueue")
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var users: [UserItem] {
        return queueUsers.sync{_users}
    }
    
    var posts: [PostModel] {
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
            print("users=\(self.users.count);posts=\(self.posts.count);favorities=\(self.favorities.count)")
            self.postFull.value = true
            
            self.startListeners()
            DispatchQueue.main.async {
                completion()
            }
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
            self.addUser(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editUser(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deleteUser(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
    }
    
    private func startPostListener() {
        let o = self.postsObserver.addObserver()
        _ = o.add.subscribe({ addedItem in
            self.addPost(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editPost(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deletePost(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
    }

    private func startFavoritiesListener() {
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
    
    private func fetchAllUsers(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
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
    
    private func fetchAllPosts(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let postsRef = FireBaseManager.firebaseRef.child(PostItemFields.posts).queryOrdered(byChild: "\\")
        postsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = PostItem(childSnap)
                        
                        let post = PostModel(postItem: item)
                        self.queuePosts.async {
                            self._posts.append(post)
                        }
                        
                    }
                }
                completion()
           }).disposed(by: disposeBag)
    }
    
    private func fetchAllFavorities(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
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
    private func addUser(_ item: UserItem) {
        if let _ = usersIndex(of: item) {
            return
        } else {
            self.queueUsers.async {
                self._users.append(item)
                self.usersOutput.newUserItem()
            }
        }
    }
    
    private func deleteUser(_ item: UserItem) {
        if let index = usersIndex(of: item) {
            self.queueUsers.async {
                self._users.remove(at: index)
                self.usersOutput.removedUserItem()
            }
        }
    }
    
    private func editUser(_  item: UserItem) {
        if let index = usersIndex(of: item) {
            self.queueUsers.async {
                self._users[index] = item
                self.usersOutput.updatedUserItem(item)
            }
        }
    }
    
    private func usersIndex(of item: UserItem) -> Int? {
        let index = users.index(where: {$0 == item})
        return index
    }
}

// Posts database updated

extension FetchingWorker {
    
    private func addPost(_ item: PostItem) {
        let post = PostModel(postItem: item)
        if let _ = postsIndex(of: post) {
        } else {
            self.queuePosts.async {
                self._posts.append(post)
                self.postAdd.value = post
            }
        }
    }
    
    private func deletePost(_ item: PostItem) {
        let post = PostModel(postItem: item)
        if let index = postsIndex(of: post) {
            self.queuePosts.async {
                self._posts.remove(at: index)
                self.postRemove.value = post
            }
        }
    }
    
    private func editPost(_  item: PostItem) {
        let post = PostModel(postItem: item)
        if let index = postsIndex(of: post) {
            self.queuePosts.async {
                self._posts[index] = post
                self.postUpdate.value = post
            }
        }
    }
    
    private func postsIndex(of post: PostModel) -> Int? {
        let index = posts.index(where: {$0 == post})
        return index
    }
}

// favorities database updated

extension FetchingWorker {
    
    private func addFavorite(_ item: FavoriteItem) {
        if let _ = favoritiesIndex(of: item) {
        } else {
            self.queueFavorities.async {
                self._favorities.append(item)
                self.favAdd.value = item
            }
        }
    }
    
    private func deleteFavorite(_ item: FavoriteItem) {
        if let index = favoritiesIndex(of: item) {
            self.queueFavorities.async {
                self._favorities.remove(at: index)
                self.favRemove.value = item
            }
        }
    }
    
    private func editFavorite(_  item: FavoriteItem) {
        if let index = favoritiesIndex(of: item) {
            self.queueFavorities.async {
                self._favorities[index] = item
                self.favUpdate.value = item
            }
        }
    }
    
    private func favoritiesIndex(of item: FavoriteItem) -> Int? {
        let index = favorities.index(where: {$0 == item})
        return index
    }
}
