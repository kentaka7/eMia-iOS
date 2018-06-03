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
typealias DidUpdateObserverClosure = () -> ()

protocol CommentsDataBaseObservable {
    func addItem(_ item: CommentItem)
    func deleteItem(_ item: CommentItem)
    func editItem(_  item: CommentItem)
}

enum EmiaServiceError: Error {
    case creationFailed
}

internal let DataModel = FetchingWorker.sharedInstance

class FetchingWorker: NSObject {
    
    let FETCHING_DATA_ASYNC = true
    let disposeBag = DisposeBag()
    
    static let sharedInstance: FetchingWorker = {
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        return appDelegate.fetchingManager
    }()
    
    private var usersObserver = UsersObserver()
    private var postsObserver = PostsObserver()
    private var favoritiesObserver = FavoritiesObserver()
    private var commnetsObserver = CommentsObserver()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    var rxPosts = Variable<[PostModel]>([])
    var rxFavorities = Variable<[FavoriteModel]>([])
    var rxUsers = Variable<[UserModel]>([])
    var rxComments = Variable<[CommentModel]>([])

    var rxNewCommentObserved = Variable<CommentModel?>(nil)
    
    var users: [UserModel] {
        do {
            let realm = try Realm()
            let users = realm.objects(UserModel.self)
            return users.toArray()
        } catch _ {
            return []
        }
    }

    var posts: [PostModel] {
        do {
            let realm = try Realm()
            let posts = realm.objects(PostModel.self)
            return posts.toArray()
        } catch _ {
            return []
        }
    }

    var favorities: [FavoriteModel] {
        do {
            let realm = try Realm()
            let favs = realm.objects(FavoriteModel.self)
            return favs.toArray()
        } catch _ {
            return []
        }
    }
    
    var comments: [CommentModel] {
        do {
            let realm = try Realm()
            let comms = realm.objects(CommentModel.self)
            return comms.toArray().sorted(by: {$0.created > $1.created})
        } catch _ {
            return []
        }
    }
    
    func fetchData(completion: @escaping () -> Void) {
        if self.rxPosts.value.count > 0 {
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
            self.semaphore.signal()
            print("users=\(self.rxUsers.value.count);posts=\(self.rxPosts.value.count);favorities=\(self.rxFavorities.value.count)")
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
    
    func startCommentsListener() {
        let o = self.commnetsObserver.addObserver()
        _ = o.add.subscribe({ addedItem in
            self.addComment(addedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.update.subscribe({ updatedItem in
            self.editComment(updatedItem.event.element!)
        }).disposed(by: self.disposeBag)
        _ = o.remove.subscribe({ removedItem in
            self.deleteComment(removedItem.event.element!)
        }).disposed(by: self.disposeBag)
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

extension FetchingWorker {
    
    fileprivate func fetchDataSync(completion: @escaping () -> Void) {
        var x = CFAbsoluteTimeGetCurrent()
        
        self.fetchAllUsers(){
            self.fetchAllPosts(){
                self.fetchAllFavorities(){
                    self.fetchAllComments(){

                        x = (CFAbsoluteTimeGetCurrent() - x) * 1000.0
                        print("Fetching all dats took \(x) milliseconds")
                        
                        completion()
                        
                    }
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
            let commentsRef = FireBaseManager.firebaseRef.child(CommentItemFields.comments)
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

            fetchingGroup.enter()
            DispatchQueue.global(qos: .utility).async(group: fetchingGroup, execute: {
                self.fetchAllComments(commentsRef){
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
                        self.addUser(item)
                    }
                }
                self.rxUsers.value.append(contentsOf: self.users)
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllPosts(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let postsRef = dbRef ?? FireBaseManager.firebaseRef.child(PostItemFields.posts).queryOrdered(byChild: "\\")
        postsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = PostItem(childSnap)
                        self.addPost(item)
                    }
                }
                self.rxPosts.value.append(contentsOf: self.posts)
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllFavorities(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let favoritiesRef = dbRef ?? FireBaseManager.firebaseRef.child(FavoriteItemFields.favorits).queryOrdered(byChild: "\\")
        favoritiesRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if let _ = childSnap.value as? Dictionary<String, String> {
                            let item = FavoriteItem(childSnap)
                            self.addFavorite(item)
                        }
                    }
                }
                self.rxFavorities.value.append(contentsOf: self.favorities)
                completion()
            }).disposed(by: disposeBag)
    }
    
    func fetchAllComments(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let commentsRef = dbRef ?? FireBaseManager.firebaseRef.child(CommentItemFields.comments).queryOrdered(byChild: "\\")
        commentsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        let item = CommentItem(childSnap)
                        self.addComment(item)
                    }
                }
                self.rxComments.value.append(contentsOf: self.comments)
                completion()
            }).disposed(by: disposeBag)
    }
}

// MARK: - changes on the firebase database listeners

// users database updated

extension FetchingWorker {
    private func addUser(_ item: UserItem) {
        let model = UserModel(item: item)
        if let _ = usersIndex(of: model) {
            return
        } else if !model.userId.isEmpty {
            _ = UserModel.createRealm(model: model)
            rxUsers.value.append(model)
        }
    }
    
    private func deleteUser(_ item: UserItem) {
        let model = UserModel(item: item)
        if let index = usersIndex(of: model) {
            rxUsers.value.remove(at: index)
        }
    }
    
    private func editUser(_  item: UserItem) {
        let model = UserModel(item: item)
        if let index = usersIndex(of: model) {
            // If the user alteady exists, it's replacing him
            //_ = UserModel.createRealm(model: model)
            rxUsers.value[index] = model
        }
    }
    
    private func usersIndex(of item: UserModel) -> Int? {
        let index = users.index(where: {$0 == item})
        return index
    }
    
}

// Posts database updated

extension FetchingWorker {
    
    private func addPost(_ item: PostItem) {
        let model = PostModel(item: item)
        guard let id = model.id, !id.isEmpty else {
            return
        }
        if let _ = postsIndex(of: model) {
            return
        } else {
            _ = PostModel.createRealm(model: model)
            rxPosts.value.append(model)
        }
    }
    
    private func deletePost(_ item: PostItem) {
        let post = PostModel(item: item)
        if let index = postsIndex(of: post) {
            rxPosts.value.remove(at: index)
        }
    }
    
    private func editPost(_  item: PostItem) {
        let post = PostModel(item: item)
        if let index = postsIndex(of: post) {
            rxPosts.value[index] = post
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
        let model = FavoriteModel(item: item)
        if let _ = favoritiesIndex(of: model) {
            return
        } else if !item.id.isEmpty {
            _ = FavoriteModel.createRealm(model: model)
            rxFavorities.value.append(model)
        }
    }
    
    private func deleteFavorite(_ item: FavoriteItem) {
        let model = FavoriteModel(item: item)
        if let index = favoritiesIndex(of: model) {
            rxFavorities.value.remove(at: index)
        }
    }
    
    private func editFavorite(_  item: FavoriteItem) {
        let model = FavoriteModel(item: item)
        if let index = favoritiesIndex(of: model) {
            //_ = FavoriteModel.createRealm(model: model)
            rxFavorities.value[index] = model
        }
    }
    
    private func favoritiesIndex(of model: FavoriteModel) -> Int? {
        let index = favorities.index(where: {$0 == model})
        return index
    }
}

// Comments database updated

extension FetchingWorker {
    
    private func addComment(_ item: CommentItem) {
        let model = CommentModel(item: item)
        if let _ = commentIndex(of: model) {
            return
        } else if !item.id.isEmpty {
            _ = CommentModel.createRealm(model: model)
            rxComments.value.append(model)
            // TODO: Remove it
            rxNewCommentObserved.value = model
        }
    }
    
    private func deleteComment(_ item: CommentItem) {
        let model = CommentModel(item: item)
        if let index = commentIndex(of: model) {
            rxComments.value.remove(at: index)
        }
    }
    
    private func editComment(_  item: CommentItem) {
        let model = CommentModel(item: item)
        if let index = commentIndex(of: model) {
            //_ = FavoriteModel.createRealm(model: model)
            rxComments.value[index] = model
        }
    }
    
    private func commentIndex(of model: CommentModel) -> Int? {
        let index = comments.index(where: {$0 == model})
        return index
    }
}
