//
//  Parser.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

public struct Parser<T> {
    typealias Stream = Substring
    
    let parse: (Stream) throws -> (T, Stream)
}

// Functor

public extension Parser {
    
    public static func unit(_ x: T) -> Parser<T> {
        
        return Parser { (x, $0) }
    }
    
//    Functor
    public func map<U>(_ f: @escaping (T) throws -> U) -> Parser<U> {
        
        return Parser<U> {
            let result = try self.parse($0)
            return try (f(result.0), result.1)
        }
    }
    
    
//    Monad
    public func then<U>(_ f: @escaping (T) throws -> Parser<U>) -> Parser<U> {
        
        return Parser<U> {
            let result = try self.parse($0)
            return try f(result.0).parse(result.1)
        }
    }
    
//    Applicative
    public func apply<U>(_ mf: Parser<(T) throws -> U>) -> Parser<U> {
        
        return mf.then(map)
    }
}
