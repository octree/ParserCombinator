//
//  Parser.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation
import FP

public struct Parser<Stream, T> {
    
    public let parse: (Stream) -> Reply<Stream, T>
    
    public init(parse: @escaping (Stream) -> Reply<Stream, T>) {
        
        self.parse = parse
    }
    
}

// Functor

public extension Parser {
    
    static func unit(_ x: T) -> Parser<Stream, T> {
        
        return Parser { .done($0, x) }
    }
    
    static var ignore: Parser<Stream, ()> {
        
        return .unit(())
    }
    
//    Functor
    func map<U>(_ f: @escaping (T) -> U) -> Parser<Stream, U> {
        
        return Parser<Stream, U> { self.parse($0).map(f) }
    }
    
    
//    Monad
    func then<U>(_ f: @escaping (T) -> Parser<Stream, U>) -> Parser<Stream, U> {
        
        return Parser<Stream, U> {
            
            switch self.parse($0) {
            case let .done(remainder, out):
                return f(out).parse(remainder)
            case let .fail(e):
                return .fail(e)
            }
        }
    }
    
//    Applicative
    func apply<U>(_ mf: Parser<Stream, (T) -> U>) -> Parser<Stream, U> {
        
        return mf.then(map)
    }
}
