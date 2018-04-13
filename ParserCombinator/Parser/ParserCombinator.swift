//
//  ParserCombinator.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

public func character(matching condition: @escaping (Character) -> Bool) -> Parser<Character> {
    
    return Parser{ input in
        
        guard let ch = input.first else {
            throw ParserError.eof
        }
        
        guard condition(ch) else {
            throw ParserError.notMatch
        }
        
        return (ch, input.dropFirst())
    }
}

public func string(_ text: String) -> Parser<String> {
    
    return Parser<String> {
        
        if $0.hasPrefix(text) {
            
            return (text, $0.dropFirst(text.count))
        }
        throw ParserError.notMatch
    }
}

public func choice<A>(_ sequence: [Parser<A>]) -> Parser<A> {
    
    return sequence.reduce(Parser.fail, <|>)
}

