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
    
    public func `repeat`(_ n: Int) -> Parser<[T]> {
        
        return Parser<[T]> {
            
            var result = [T]()
            var remainder = $0
            for _ in 0 ..< n {
                
                let (t, r) = try self.parse(remainder)
                remainder = r
                result.append(t)
            }
            return (result, remainder)
        }
    }
    
    public func sep<U>(by other: Parser<U>) -> Parser<[T]> {
        
        return sep1(by: other) <|> .unit([])
    }
    
    public func sep1<U>(by other: Parser<U>) -> Parser<[T]> {
        
        return curry({ [$0] + $1 }) <^> self <*>  (other *> self).many
    }
    
//    EBNF: (p (sep p)* sep?)?
    public func sepEnd<U>(by other: Parser<U>) -> Parser<[T]> {
        
        return sep1(by: other) <|> .unit([])
    }
//    EBNF: p (sep p)* sep?
    public func sepEnd1<U>(by other: Parser<U>) -> Parser<[T]> {
        
        return sep1(by: other) <* other.optional
    }
    
    public func many<U>(till other: Parser<U>) -> Parser<[T]> {
        
        return difference(other).many
    }
    
    public func many1<U>(till other: Parser<U>) -> Parser<[T]> {
        
        return difference(other).many1
    }
}


