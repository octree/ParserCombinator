//
//  Future.swift
//
//
//  Created by Octree on 2016/10/28.
//  Copyright © 2016年 Octree. All rights reserved.
//

import Foundation

public struct Future<T> {
    
    let trunck: (@escaping (Result<T>) -> Void) -> Void
    
    public init(f: @escaping (@escaping (Result<T>) -> Void) -> Void) {
        
        trunck = f
    }
}


public extension Future {
    
    // execute
    
    public func execute(callback: @escaping (Result<T>) -> Void) {
        
        trunck(callback)
    }

    // pure
    
    public static func unit<T>(_ v: T) -> Future<T> {
    
        return Future<T> { f in f(Result<T>.unit(v)) }
    }
    
    public static func fail<T>(_ error: Error) -> Future<T> {
        
        return Future<T> { f in f(Result<T>.failure(error)) }
    }
    
    // Functor
    
    public func fmap<U>(f: @escaping (T) -> U) -> Future<U> {
        
        return then { Future.unit(f($0)) }
    }
    
    // Applicative
    
    // Monad
    
    public func then<U>(f: @escaping (T) -> Future<U>) -> Future<U> {
        
        return Future<U> {
            cont in
            self.execute {
            
                switch $0.fmap(f: f) {
                    
                    case .success(let Future):
                        Future.execute(callback: cont)
                    case .failure(let e):
                        cont(.failure(e))
                }
            }
        }
    }
    
}


//  Operator

public func <^> <T, U>(f: @escaping (T) -> U, v: Future<T>) -> Future<U> {

    return v.fmap(f: f)
}

public func >>- <T, U>(v: Future<T>, f: @escaping (T) -> Future<U>) -> Future<U> {

    return v.then(f: f)
}

public func -<< <T, U>(f: @escaping (T) -> Future<U>, v: Future<T>) -> Future<U> {
    
    return v.then(f: f)
}

public func >-> <T, U, V>(f: @escaping (T) -> Future<U>, g: @escaping (U) -> Future<V>) -> (T) -> Future<V> {

    return { x in f(x) >>- g }
}

public func <-< <T, U, V>(f: @escaping (U) -> Future<V>, g: @escaping (T) -> Future<U>) -> (T) -> Future<V> {

    return { x in g(x) >>- f }
}
