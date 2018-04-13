//
//  Parser+Extension.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation


public extension Parser {
    
//    just fail
    public static var fail: Parser<T> {
        return Parser<T> {
            _ in
            throw ParserError.any
        }
    }
    
//    many, maybe empty
    public var many: Parser<[T]> {
        
        return Parser<[T]> {
            input in
            
            var result: [T] = []
            var remainder = input
            
            while (true) {
                
                do {
                    let (t, r) = try self.parse(remainder)
                    result.append(t)
                    remainder = r
                } catch {
                    break
                }
            }
            return (result, remainder)
        }
    }
    
// many, as leat 1
    
    public var many1: Parser<[T]> {
        
        return curry({ x, y in [x] + y }) <^> self <*> many
    }
    
//    optional
    public var optional: Parser<T?> {
        return Parser<T?> {
            
            do {
                let rt = try self.parse($0)
                return (rt.0, rt.1)
            } catch {
                return (nil, $0)
            }
        }
    }
    
//    差集
    public func difference<U>(_ other: Parser<U>) -> Parser<T> {
        
        return Parser<T> {
            
            do {
                try _ = other.parse($0)
                throw ParserError.notMatch
            } catch {
                return try self.parse($0)
            }
        }
    }
    
    public func followed<U>(by other: Parser<U>) -> Parser<(T, U)> {
        
        return curry({ x, y in (x, y) }) <^> self <*> other
    }
    
}


