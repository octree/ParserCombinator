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
let integer = digit.many1.map { Int(String($0))! }
let star = character { $0 == "*" }
let plus = character { $0 == "+" }
let hyphen = character { $0 == "-" }
let slash = character { $0 == "/" }


let multiOp = { _ in { (x:Int, y: Int) in x * y }} <^> star
let divOp = { _ in { (x:Int, y: Int) in x / y }} <^> slash
let addOp = { _ in { (x:Int, y: Int) in x + y }} <^> plus
let subOp = { _ in { (x:Int, y: Int) in x - y }} <^> hyphen

let leftParentheses =  character { $0 == "(" }
let rightParentheses =  character { $0 == ")" }

struct Interpreter {
    
    
    private var parentExpr: Parser<Int> {
        
        return (leftParentheses >>- { _ in return self.expression })  <* rightParentheses
    }
    
    private var item: Parser<Int> {
        
        return integer <|> parentExpr
    }
    
    private var multiplicationAndDivision: Parser<Int> {
        
        return item.chainl1(op: multiOp <|> divOp )
    }
    
    private var additionAndSubtraction: Parser<Int> {
        
        return multiplicationAndDivision.chainl1(op: addOp <|> subOp)
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



