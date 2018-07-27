import UIKit

class Person: NSObject {
    let firstName: String
    let lastName: String
    let age: Int
    
    init(firstName: String, lastName: String, age: Int) {
        self.firstName = firstName
        self.lastName = lastName
        self.age = age
    }
    
    override var description: String {
        return "\(firstName) \(lastName)"
    }
}

let alice = Person(firstName: "Alice", lastName: "Smith", age: 24)
let bob = Person(firstName: "Bob", lastName: "Jones", age: 27)
let charlie = Person(firstName: "Charlie", lastName: "Smith", age: 33)
let quentin = Person(firstName: "Quentin", lastName: "Alberts", age: 31)
let people: [Person] = [alice, bob, charlie, quentin]
let bobs = people.filter { $0.firstName == "Bob"}
print("\(bobs)")

var view = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))
view.backgroundColor = UIColor.green
view.layer.borderColor = UIColor.blue.cgColor
view.layer.borderWidth = 10
view.layer.cornerRadius = 20
view

let view1 = UIView(frame: CGRect(x: 113, y: 111, width: 132, height: 194))
view1.backgroundColor = UIColor.black
print(view1)
let view2 = UIView(frame: view1.bounds.insetBy(dx: 10, dy: 10))
view2.backgroundColor = UIColor.red
view1.addSubview(view2)
print(view1.frame)
view2.bounds.origin.x += 10
view2.bounds.origin.y += 10
print(view1.frame)
print(view1.bounds)
view1
