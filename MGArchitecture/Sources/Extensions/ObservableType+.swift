//
//  ObservableType+.swift
//  MGArchitecture
//
//  Created by Tuan Truong on 4/1/19.
//  Copyright © 2019 Sun Asterisk. All rights reserved.
//

import RxSwift
import RxCocoa

extension ObservableType {
    
    public func catchErrorJustComplete() -> Observable<E> {
        return catchError { _ in
            return Observable.empty()
        }
    }
    
    public func asDriverOnErrorJustComplete() -> Driver<E> {
        return asDriver { _ in
            return Driver.empty()
        }
    }
    
    public func mapToVoid() -> Observable<Void> {
        return map { _ in }
    }
    
    public func mapToOptional() -> Observable<E?> {
        return map { value -> E? in value }
    }
    
    public func unwrap<T>() -> Observable<T> where E == T? {
        return flatMap { Observable.from(optional: $0) }
    }
}

extension ObservableType where E == Bool {
    public func not() -> Observable<Bool> {
        return map(!)
    }
    
    public static func or(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.reduce(false) { $0 || $1 } }
    }
    
    public static func and(_ sources: Observable<Bool>...)
        -> Observable<Bool> {
            return Observable.combineLatest(sources)
                .map { $0.reduce(true) { $0 && $1 } }
    }
}

private func getThreadName() -> String {
    if Thread.current.isMainThread {
        return "Main Thread"
    } else if let name = Thread.current.name {
        if name.isEmpty {
            return "Anonymous Thread"
        }
        return name
    } else {
        return "Unknown Thread"
    }
}

extension ObservableType {
    public func dump() -> Observable<Self.E> {
        return self.do(onNext: { element in
            let threadName = getThreadName()
            print("[D] \(element) received on \(threadName)")
        })
    }
    
    public func dumpingSubscription() -> Disposable {
        return self.subscribe(onNext: { element in
            let threadName = getThreadName()
            print("[S] \(element) received on \(threadName)")
        })
    }
}
