//
//  Post.swift
//  eMia
//

import Foundation
import Firebase

// MARK: - Post

class Post: NSObject, Codable {
    
    var key: String?
    var ref: DatabaseReference?
    
    var author: String
    var body: String
    var created: Double
    var id: String
    var photosize: String
    var starCount: Int
    var title: String
    var userId: String

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        author = try container.decode(String.self, forKey: .author)
        body = try container.decode(String.self, forKey: .body)
        created = try container.decode(Double.self, forKey: .created)
        id = try container.decode(String.self, forKey: .id)
        photosize = try container.decode(String.self, forKey: .photosize)
        starCount = try container.decode(Int.self, forKey: .starCount)
        title = try container.decode(String.self, forKey: .title)
        userId = try container.decode(String.self, forKey: .userId)
//        published = try container.decodeIfPresent(Date.self, forKey: .published)
    }

    enum CodingKeys: String, CodingKey {
        case author
        case body
        case created
        case id
        case photosize
        case starCount
        case title
        case userId = "uid"
    }

    init(author: String, body: String, created: Double, id: String, photosize: String, starCount: Int, title: String, userId: String) {
        self.author = author
        self.body = body
        self.created = created
        self.id = id
        self.photosize = photosize
        self.starCount = starCount
        self.title = title
        self.userId = userId
    }
    
    func toDictionary() -> [String : Any] {
        return [
            PostItemFields.author: author,
            PostItemFields.body: body,
            PostItemFields.created: created,
            PostItemFields.id: id,
            PostItemFields.photosize: photosize,
            PostItemFields.starCount: starCount,
            PostItemFields.title: title,
            PostItemFields.uid: userId
        ]
    }
    
    func setRef(ref: Any?) {
        self.ref = ref as? DatabaseReference
    }
}

//MARK: - Save record

extension Post {
    
    func synchronize(completion: @escaping (Bool) -> Void) {
        if self.key!.isEmpty {
            save(completion: completion)
        } else {
            update(completion: completion)
        }
    }
    
    // Update exists data to Firebase Database
    private func update(completion: @escaping (Bool) -> Void) {
        let childUpdates = ["/\(PostItemFields.posts)/\(self.key!)": self.toDictionary()]
        FireBaseManager.firebaseRef.updateChildValues(childUpdates, withCompletionBlock: { (error, ref) in
            completion(true)
        })
    }
    
    // Save new data to Firebase Database
    private func save(completion: @escaping (Bool) -> Void) {
        let key = FireBaseManager.firebaseRef.child(PostItemFields.posts).childByAutoId().key
        self.key = key
        self.id = key
        update(completion: completion)
    }
    
    func remove() {
        self.ref?.removeValue()
    }
}

//MARK: -

func ==(lhs: Post, rhs: Post) -> Bool {
    let result = lhs.id == rhs.id
    return result
}
