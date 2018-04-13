//
//  main.swift
//  ParserCombinator
//
//  Created by Octree on 2018/4/13.
//  Copyright © 2018年 Octree. All rights reserved.
//

import Foundation

extension CharacterSet {
    
    func contains(_ c: Character) -> Bool {
        
        let scalars = String(c).unicodeScalars
        guard scalars.count == 1 else {
            return false
        }
        return contains(scalars.first!)
    }
}

let digit = character(matching: { CharacterSet.decimalDigits.contains($0) })
let integer = digit.many.map { Int(String($0))! }
let star = character { $0 == "*" }
let plus = character { $0 == "+" }
let hyphen = character { $0 == "-" }
let slash = character { $0 == "/" }


func multiOrDivide(_ x: Int, _ others: [(Character, Int)]?) -> Int {
    
    return (others ?? []).reduce(x) {
        
        return $1.0 == "*" ? $0 * $1.1 : $0 / $1.1
    }
}

func plusOrMinus(_ x: Int, _ others: [(Character, Int)]?) -> Int {
    
    return (others ?? []).reduce(x) {
        
        return $1.0 == "+" ? $0 + $1.1 : $0 - $1.1
    }
}

let leftParentheses =  character { $0 == "(" }
let rightParentheses =  character { $0 == ")" }

extension Parser {
    
    func followed<U>(by other: Parser<U>) -> Parser<(T, U)> {
        
        return curry({ x, y in (x, y) }) <^> self <*> other
    }
}

struct Interpreter {
    
    
    private var parentExpr: Parser<Int> {
        
        return ({ _ in return self.expression } >>- leftParentheses) <* rightParentheses
    }
    
    private var item: Parser<Int> {
        
        return integer <|> parentExpr
    }
    
    private var multiplicationAndDivision: Parser<Int> {
        return curry(multiOrDivide)
            <^> item
            <*> ((star <|> slash).followed(by: item)).many.optional
    }
    
    private var additionAndSubtraction: Parser<Int> {
        return curry(plusOrMinus)
            <^> multiplicationAndDivision
            <*> ((plus <|> hyphen).followed(by: multiplicationAndDivision)).many.optional
    }
    
    private var expression: Parser<Int> {
        
        return additionAndSubtraction
    }
    
    func execute(_ s: String) throws -> Int {
        
        return try expression.parse(Substring(s)).0
    }
}

do {
    try print(Interpreter().execute("1+2*(3+4)"))
} catch {
    print(error)
}



