//
//  FirebaseFetcher.swift
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

enum PostServiceError: Error {
    case creationFailed
    case updateFailed(PostModel)
    case deletionFailed(PostModel)
    case toggleFailed(PostModel)
    case updateUserFailed(UserModel)
    case deletionUserFailed(UserModel)
    case toggleUserFailed(UserModel)
}

internal let gFirebaseFetcher = FirebaseFetcher.default

class FirebaseFetcher: NSObject {
    
    static let `default` = FirebaseFetcher()
    
    private override init() {
        super.init()
    }
    
    let kFetchingDataAsync = true
    let disposeBag = DisposeBag()
    
    private let usersObserver = UsersObserver()
    private let postsObserver = PostsObserver()
    private let favoritiesObserver = FavoritiesObserver()
    private let commnetsObserver = CommentsObserver()

    private let localDB = LocalBaseController()
    
    let semaphore = DispatchSemaphore(value: 1)
    
    func downloadAllData(completion: @escaping () -> Void) {
        if localDB.isDataBaseFetched {
            startListeners()
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
            print("users=\(self.localDB.users.count);posts=\(self.localDB.posts.count);favorities=\(self.localDB.favorities.count)")
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
}

extension FirebaseFetcher {
    
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
            let usersRef = gDataBaseRef.child(UserItem.TableName)
            let postsRef = gDataBaseRef.child(PostItem.TableName)
            let favoritiesRef = gDataBaseRef.child(FavoriteItem.TableName)
            let commentsRef = gDataBaseRef.child(CommentItem.TableName)
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

extension FirebaseFetcher {
    
    private func fetchAllUsers(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let usersRef = dbRef ?? gDataBaseRef.child(UserItem.TableName).queryOrdered(byChild: "\\")
        usersRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if let item = UserItem(childSnap) {
                            self.localDB.addUser(item)
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllPosts(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let postsRef = dbRef ?? gDataBaseRef.child(PostItem.TableName).queryOrdered(byChild: "\\")
        postsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if let item = PostItem(childSnap) {
                            self.localDB.addPost(item)
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
    
    private func fetchAllFavorities(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let favoritiesRef = dbRef ?? gDataBaseRef.child(FavoriteItem.TableName).queryOrdered(byChild: "\\")
        favoritiesRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if childSnap.value as? [String: String] != nil {
                            if let item = FavoriteItem(childSnap) {
                                self.localDB.addFavorite(item)
                            }
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
    
    func fetchAllComments(_ dbRef: DatabaseReference? = nil, completion: @escaping () -> Void) {
        let commentsRef = dbRef ?? gDataBaseRef.child(CommentItem.TableName).queryOrdered(byChild: "\\")
        commentsRef
            .rx
            .observeSingleEvent(.value)
            .subscribe(onNext: { snapshot in
                _ = snapshot.children.map { child in
                    if let childSnap = child as? DataSnapshot {
                        if let item = CommentItem(childSnap) {
                            self.localDB.addComment(item)
                        }
                    }
                }
                completion()
            }).disposed(by: disposeBag)
    }
}
