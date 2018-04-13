//
//  ParserRunes.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

/// Functor Operator
/// a -> b -> m a -> m b
public func <^><A, B>(lhs: @escaping (A) throws -> B, rhs: Parser<A>) -> Parser<B> {
    return rhs.map(lhs)
}


/// Monad
///  m a -> (a -> m b) -> m b
public func >>-<A, B>(lhs: Parser<A>, rhs: @escaping (A) throws -> Parser<B>) -> Parser<B> {
    
    return lhs.then(rhs)
}


/// applicative
/// m (a -> b) -> m a -> m b
public func <*><A, B>(lhs: Parser<(A) throws -> B>, rhs: Parser<A>) -> Parser<B> {
    
    return rhs.apply(lhs)
}

/// Ignoring Left
/// ma -> mb -> mb
public func *><A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<B> {
    
    return curry({ _, y in y }) <^> lhs <*> rhs
}


/// Ignoring Right
/// ma -> mb -> ma
public func <*<A, B>(lhs: Parser<A>, rhs: Parser<B>) -> Parser<A > {
    
    return curry({ x, _ in x }) <^> lhs <*> rhs
}


/// or
/// m a -> m a -> m a
public func <|><A>(lhs: Parser<A>, rhs: Parser<A>) -> Parser<A> {
    
    return Parser {
        do {
            return try lhs.parse($0)
        } catch {
            return try rhs.parse($0)
        }
    }
}

