//: [Previous](@previous)

import UIKit
import RxSwift

example(of: "just, of, from") {
    
    // 1
    let one = 1
    let two = 2
    let three = 3
    
    // 2
    let observable: Observable<Int> = Observable<Int>.just(one)
    let observable2 = Observable.of(one, two, three)
    let observable3 = Observable.of([one, two, three])
    let observable4 = Observable.from([one, two, three])
}

example(of: "subscribe") {
    
    let one = 1
    let two = 2
    let three = 3
    
    let observable = Observable.of(one, two, three)
    
    observable.subscribe(onNext: { element in
        print(element)
    })
}

example(of: "empty") {
    
    let observable = Observable<Void>.empty()
    
    observable
        .subscribe(
            
            // 1
            onNext: { element in
                print(element)
        },
            
            // 2
            onCompleted: {
                print("Completed")
        }
    )
}

example(of: "never") {
    
    let observable = Observable<Any>.never()
    observable
        .subscribe(
            onNext: { element in
                print(element)
        },
            onCompleted: {
                print("Completed")
        }
    )
}

example(of: "range") {
    
    // 1
    let observable = Observable<Int>.range(start: 1, count: 10)
    observable
        .subscribe(onNext: { index in
            // 2
            let oubleIndex = Double(index)
            let fibonacci = Int(((pow(1.61803, oubleIndex) - pow(0.61803, oubleIndex)) /
                2.23606).rounded())
            print(fibonacci)
        })
}

example(of: "dispose") {
    
    // 1
    let observable = Observable.of("A", "B", "C")
    
    // 2
    let subscription = observable.subscribe { event in
        
        // 3
        print(event)
    }
    subscription.dispose()
}

example(of: "DisposeBag") {
    
    // 1
    let disposeBag = DisposeBag()
    
    // 2
    Observable.of("A", "B", "C")
        .subscribe { // 3
            print($0)
        }
        .disposed(by: disposeBag)
}

example(of: "create") {
    
    enum MyError: Error {
        case anError
    }
    
    let disposeBag = DisposeBag()
    
    Observable<String>.create { observer in
        // 1
        observer.onNext("1")
        //observer.onError(MyError.anError)
        
        // 2
        //observer.onCompleted()
        
        // 3
        observer.onNext("?")
        
        // 4
        return Disposables.create()
        }
        .subscribe(
            onNext: { print($0) },
            onError: { print($0) },
            onCompleted: { print("Completed") },
            onDisposed: { print("Disposed") }
        )
        .disposed(by: disposeBag)
}

example(of: "deferred") {
    
    let disposeBag = DisposeBag()
    
    // 1
    var flip = false
    
    // 2
    let factory: Observable<Int> = Observable.deferred {
        
        // 3
        flip = !flip
        
        // 4
        if flip {
            return Observable.of(1, 2, 3)
        } else {
            return Observable.of(4, 5, 6)
        }
    }
    
    for _ in 0...3 {
        factory.subscribe(onNext: {
            print($0, terminator: "")
        })
            .disposed(by: disposeBag)
        
        print()
    }
}


executeProcedure(for: "just"){
    
    let observable = Observable.just("Example of Just Operator!")
    observable.subscribe({ (event: Event<String>) in
        print(event)
    })
}

executeProcedure(for: "of"){
    
    let observable = Observable.of(10, 20, 30)
    
    observable.subscribe({
        print($0)
    })
}


executeProcedure(for: "from"){
    let disposeBag = DisposeBag()
    
    let subscribed = Observable.from([10, 20,30])
        .subscribe(onNext:{
            print($0)
        })
    subscribed.disposed(by: disposeBag)
    
    Observable.from([1, 2, 3])
        .subscribe(onNext: {print($0)},
                   onCompleted: {print("Completed the events")},
                   onDisposed: {print("Sequence terminated hence Disposed")}
        )
        .disposed(by: disposeBag)
}


executeProcedure(for: "error"){
    enum CustomError: Error{
        case defaultError
    }
    
    let disposeBag = DisposeBag()
    Observable<Void>.error(CustomError.defaultError)
        .subscribe(onError: {print($0)})
        .disposed(by: disposeBag)
}




executeProcedure(for: "PublishSubject"){
    
    enum CustomError: Error{
        case defaultError
    }
    let pubSubject = PublishSubject<String>()
    let disposeBag = DisposeBag()
    
    pubSubject.subscribe {
        print($0)
        }
        .disposed(by: disposeBag)
    
    pubSubject.on(.next("First Event"))
    //pubSubject.onError(CustomError.defaultError)
    //pubSubject.onCompleted()
    pubSubject.onNext("Second Event")
    
    let newSubcription = pubSubject.subscribe(onNext: {
        print("New Subscription", $0)
    })
    
    pubSubject.onNext("I am New!")
    newSubcription.dispose()
    pubSubject.onNext("Fourth Event")
}


executeProcedure(for: "BehaviorSubject"){
    let disposeBag = DisposeBag()
    
    let behSubject = BehaviorSubject(value: "Test")
    let initialSubscripton = behSubject.subscribe(onNext: {
        print("Line number is \(#line) and value is" , $0)
    })
    behSubject.onNext("Second Event")
    
    let subsequentSubscription = behSubject.subscribe(onNext: {
        print("Line number is \(#line) and value is" , $0)
    })
    
    initialSubscripton.disposed(by: disposeBag)
    subsequentSubscription.disposed(by: disposeBag)
}


executeProcedure(for: "ReplaySubject"){
    let disposeBag = DisposeBag()
    
    let repSubject = ReplaySubject<String>.create(bufferSize: 3)
    
    repSubject.onNext("First")
    repSubject.onNext("Second")
    repSubject.onNext("Third")
    
    repSubject.onNext("Fourth")
    
    repSubject.subscribe(onNext: {
        print($0)
    })
        .disposed(by: disposeBag)
    
    repSubject.onNext("Fifth")
    repSubject.subscribe(onNext: {
        print("New Subscription: ", $0)
    })
        .disposed(by: disposeBag)
}


executeProcedure(for: "Variable") {
    let disposeBag = DisposeBag()
    
    let variable = Variable(1)
    variable.asObservable()
        .subscribe{
            print($0)
        }
        .disposed(by: disposeBag)
    variable.value
    variable.value = 2
}




// Implementation for map operator
executeProcedure(for: "map") {
    Observable.of(10, 20, 30)
        .map{ $0 * $0 }
        .subscribe(onNext:{
            print($0)
        })
        .dispose()
}

// Implementation for flatMap and flatMapLatest operator
executeProcedure(for: "flatMap and flatMapLatest") {
    
    struct GamePlayer {
        let playerScore: Variable<Int>
    }
    let disposeBag = DisposeBag()
    
    let alex = GamePlayer(playerScore: Variable(70))
    let gemma = GamePlayer(playerScore: Variable(85))
    
    var currentPlayer = Variable(alex)
    
    currentPlayer.asObservable()
        .flatMapLatest{ $0.playerScore.asObservable() }
        .subscribe(onNext:{
            print($0)
        })
        .disposed(by: disposeBag)
    
    currentPlayer.value.playerScore.value = 90
    alex.playerScore.value = 95
    
    currentPlayer.value = gemma
    
    alex.playerScore.value = 96
}

// Implementation for scan and buffer operator
executeProcedure(for: "scan and buffer") {
    
    let disposeBag = DisposeBag()
    
    let gameScore = PublishSubject<Int>()
    
    gameScore
        .buffer(timeSpan: 0.0, count: 3, scheduler: MainScheduler.instance)
        .map {
            print($0, "--> ", terminator: "")
            return $0.reduce(0, +)
        }
        .scan(501, accumulator: -)
        .map { max($0, 0) }
        .subscribe(onNext:{
            print($0)
        })
        .disposed(by: disposeBag)
    
    gameScore.onNext(60)
    gameScore.onNext(13)
    gameScore.onNext(50)
}


// Implementation for filter operator
executeProcedure(for: "filter") {
    
    let disposeBag = DisposeBag()
    
    let integers = Observable.generate(initialState: 1,
                                       condition: { $0 < 101 },
                                       iterate: { $0 + 1 }
    )
    
    integers
        .filter { $0.isPrime() }
        .toArray()
        .subscribe({
            print( $0 )
        })
        .disposed(by: disposeBag)
}

// Implementation for distinctUntilChanged operator
executeProcedure(for: "distinctUntilChanged") {
    
    let disposeBag = DisposeBag()
    
    let stringToSearch = Variable("")
    stringToSearch.asObservable()
        .map({
            $0.lowercased()
        })
        .distinctUntilChanged()
        .subscribe({
            print($0)
        })
        .disposed(by: disposeBag)
    
    stringToSearch.value = "TINTIN"
    stringToSearch.value = "tintin"
    stringToSearch.value = "noDDy"
    stringToSearch.value = "TINTIN"
}


// Implementation for takeWhile operator
executeProcedure(for: "takeWhile") {
    let disposeBag = DisposeBag()
    
    let integers = Observable.of(10, 20, 30, 40, 30, 20, 10)
    integers
        .takeWhile({
            $0 < 40
        })
        .subscribe(onNext: {
            print( $0 )
        })
        .disposed(by: disposeBag)
}

/*
 executeProcedure(for: "startWith") {
 let disposeBag = DisposeBag()
 
 Observable.of("String 2", "String 3", "String 4")
 .startWith("String 0", "String 1")
 .startWith("String -1")
 .startWith("String -2")
 .subscribe(onNext:{
 print($0)
 })
 .disposed(by: disposeBag)
 }
 
 
 executeProcedure(for: "merge") {
 
 let disposeBag = DisposeBag()
 
 let pubSubject1 = PublishSubject<String>()
 let pubSubject2 = PublishSubject<String>()
 let pubSubject3 = PublishSubject<String>()
 
 Observable.of(pubSubject1, pubSubject2, pubSubject3)
 .merge()
 .subscribe(onNext:{
 print($0)
 })
 .disposed(by: disposeBag)
 
 pubSubject1.onNext("First Element from Subject 1")
 
 pubSubject2.onNext("First Element from Subject 2")
 
 pubSubject3.onNext("First Element from  Subject 3")
 
 pubSubject1.onNext("Second Element from Subject 1")
 
 pubSubject3.onNext("Second Element from Subject 3")
 
 pubSubject2.onNext("Second Element from Subject 2")
 
 }
 
 
 executeProcedure(for: "zip") {
 
 let disposeBag = DisposeBag()
 
 let intPubSubject1 = PublishSubject<Int>()
 let stringPubSubject1 = PublishSubject<String>()
 let intPubSubject2 = PublishSubject<Int>()
 let stringPubSubject2 = PublishSubject<String>()
 
 Observable.zip(intPubSubject1, stringPubSubject1,intPubSubject2, stringPubSubject2) { intSub1, strSub1, intSub2, stringSub2 in
 "\(intSub1) : \(strSub1) AND \(intSub2) : \(stringSub2)"
 }
 .subscribe(onNext:{
 print($0)
 })
 .disposed(by: disposeBag)
 
 stringPubSubject1.onNext("is the first String element on stringPubSubject1")
 
 stringPubSubject1.onNext("is the second String element on stringPubSubject1")
 
 stringPubSubject2.onNext("is the first String element on stringPubSubject2")
 
 stringPubSubject2.onNext("is the cecond String element on stringPubSubject2")
 
 intPubSubject1.onNext(1)
 
 intPubSubject1.onNext(2)
 
 intPubSubject2.onNext(3)
 
 intPubSubject2.onNext(4)
 
 intPubSubject1.onNext(5)
 stringPubSubject1.onNext("is the third String element on stringPubSubject1")
 intPubSubject2.onNext(3)
 stringPubSubject2.onNext("is the third String element on stringPubSubject2")
 
 }
 
 */

executeProcedure(for: "do(on....:)") {
    
    //let disposeBag = DisposeBag()
    
    let temperatureInFahrenheit = PublishSubject<Int>()
    
    temperatureInFahrenheit
        .do(onNext: {
            $0 * $0
        })
        .do(onNext: {
            print("\($0)℉ = ", terminator: "")
        })
        .map{
            Double($0 - 32) * 5 / 9.0
        }
        .do(onError: {
            print($0)
        },
            onCompleted: {
                print("Completed the sequence")
        },
            onSubscribe: {
                print("Subscribed to sequence")
        },
            onDispose: {
                print("Sequence Disposed")
        })
        .subscribe(onNext: {
            print(String(format: "%.1f℃", $0))
        })
    //        .disposed(by: disposeBag)
    
    temperatureInFahrenheit.onNext(-40)
    temperatureInFahrenheit.onNext(0)
    temperatureInFahrenheit.onNext(37)
    
    temperatureInFahrenheit.onCompleted()
}


executeProcedure(for: "test") {
    
}
