//
//  ParserCombinator.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation
import FP

public func choice<A>(_ sequence: [Parser<Stream, A>]) -> Parser<Stream, A> {
    
    return sequence.reduce(Parser.fail, <|>)
}

public extension Parser {
    
//    just fail
    static var fail: Parser<Stream, T> {
        return Parser<Stream, T> {
            _ in
            return .fail(ParserError.any)
        }
    }
    
    ///  执行 parse，但是不会改变 input
    var lookAhead: Parser<Stream, T> {

        return Parser<Stream, T> {
            let reply = self.parse($0)
            switch reply {
            case let .done(_, out):
                return .done($0, out)
            case .fail:
                return reply
            }
        }
    }
    
//    many, maybe empty
    var many: Parser<Stream, [T]> {
        
        return Parser<Stream, [T]> {
            input in
            
            var result: [T] = []
            var remainder = input
            
            while case let .done(r, out) = self.parse(remainder) {
                
                result.append(out)
                remainder = r
            }
            return .done(remainder, result)
        }
    }
    
    
// many, as leat 1
    
    var many1: Parser<Stream, [T]> {
        
        return curry({ x, y in [x] + y }) <^> self <*> many
    }
    
    var skipMany: Parser<Stream, ()> {
        
        return many *> .ignore
    }
    
    var skipMany1: Parser<Stream, ()> {
        
        return many1 *> .ignore
    }
    
    
//    optional
    var optional: Parser<Stream, T?> {
        return Parser<Stream, T?> {
            
            switch self.parse($0) {
            case let .done(remainder, out):
                return .done(remainder, out)
            case .fail(_):
                return .done($0, nil)
            }
        }
    }
    
    func otherwise(_ v: T) -> Parser<Stream, T> {
        
        return self <|> .unit(v)
    }
    
//    差集
    func difference<U>(_ other: Parser<Stream, U>) -> Parser<Stream, T> {
        
        return Parser<Stream, T> {
            if case .done(_) = other.parse($0) {
                return .fail(ParserError.notMatch)
            }
            return self.parse($0)
        }
    }
    
    func followed<U>(by other: Parser<Stream, U>) -> Parser<Stream, (T, U)> {
        
        return curry({ x, y in (x, y) }) <^> self <*> other
    }
    
    func `repeat`(_ n: Int) -> Parser<Stream, [T]> {
        
        return Parser<Stream, [T]> {
            
            var result = [T]()
            var remainder = $0
            for _ in 0 ..< n {
                
                guard case let .done(r, out) = self.parse(remainder) else {
                    return .fail(ParserError.notMatch)
                }
                remainder = r
                result.append(out)
            }
            return .done(remainder, result)
        }
    }
    
    
    func sep<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return sep1(by: other) <|> .unit([])
    }
    
    func sep1<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return curry({ [$0] + $1 }) <^> self <*>  (other *> self).many
    }
    
    func end<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return many <* other
    }
    
    func end1<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return many1 <* other
    }
    
///   separated and optionally ended by sep
///   EBNF: (p (sep p)* sep?)?
    func sepEnd<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return sep1(by: other) <|> .unit([])
    }
///   separated and optionally ended by sep
///   EBNF: p (sep p)* sep?
    func sepEnd1<U>(by other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return sep1(by: other) <* other.optional
    }
    
    func many<U>(till other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return difference(other).many
    }
    
    func many1<U>(till other: Parser<Stream, U>) -> Parser<Stream, [T]> {
        
        return difference(other).many1
    }
    
    func between<U, V>(open: Parser<Stream, U>, close: Parser<Stream, V>) -> Parser<Stream, T> {
        
        return open *> self <* close
    }
    
    
    /// self (op self)*
    /// 可以用来消除左递归
    ///
    /// - Parameter op: op parser
    /// - Returns: parser
    func chainl1(op: Parser<Stream, (T, T) -> T>) -> Parser<Stream, T> {

        func f(_ lhs: T) -> Parser<Stream, T> {
            
            let parser = op >>- {
                opf in
                self >>- { rhs in f(opf(lhs, rhs)) }
            }
            return parser <|> .unit(lhs)
        }
        
        return self >>- f
    }
    
    
    func chainr1(op: Parser<Stream, (T, T) -> T>) -> Parser<Stream, T> {
        
        func scan() -> Parser<Stream, T> {
            
            return self >>- f
        }
        
        func f(_ lhs: T) -> Parser<Stream, T> {
            
            let parser: Parser<Stream, T> = op >>- { opf in
                scan() >>- { rhs in
                    return Parser<Stream, T>.unit(opf(lhs, rhs))
                }
            }
            return parser <|> .unit(lhs)
        }
        
        return scan()
    }
    
}



