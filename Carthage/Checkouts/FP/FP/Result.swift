//
//  Result.swift
//  RxDemo
//
//  Created by Octree on 2016/10/28.
//  Copyright © 2016年 Octree. All rights reserved.
//

import Foundation

public enum Result<T> {
    
    case success(T)
    case failure(Error)
}

public extension Result {
    
    public static func unit<U>(_ v: U) -> Result<U> {
    
        return .success(v)
    }
    
    // Functor
    public func fmap<U>(f: (T) -> U) -> Result<U> {
    
       
        switch self {
        case .success(let v):
            return .success(f(v))
        case .failure(let err):
            return .failure(err)
        }
    }
    
    // Applicative
    public func apply<U>(r: Result<(T) -> U>) -> Result<U> {

        return r.then(f: fmap)
    }

    // Monad
    public func then<U>(f: (T) -> Result<U>) -> Result<U> {
        
        switch self {
        case .success(let v):
            
            return f(v)
        case .failure(let e):
            
            return .failure(e)
        }
    }
}

public func <^> <T, U>(f: (T) -> U, v: Result<T>) -> Result<U> {

    return v.fmap(f: f)
}

//public func <*> <T, U>(f: Result<(T) -> U>, v: Result<T>) -> Result <U> {
//
//    return v.apply(r: f)
//}

public func >>- <T, U>(v: Result<T>, f: (T) -> Result<U>) -> Result<U> {

    return v.then(f: f)
}

public func -<< <T, U>(f: (T) -> Result<U>, v: Result<T>) -> Result<U> {

    return v.then(f: f)
}

public func >-> <T, U, V>(f: @escaping (T) -> Result<U>, g: @escaping (U) -> Result<V> ) -> (T) -> Result<V> {

    return { x in f(x) >>- g }
}


public func <-< <T, U, V>(f: @escaping (U) -> Result<V>, g: @escaping (T) -> Result<U>) -> (T) -> Result<V> {

    return { x in g(x) >>- f }
}
