//
//  ViewController.swift
//  Demo
//
//  Created by Octree on 2018/8/23.
//  Copyright © 2018年 Octree. All rights reserved.
//
import UIKit
import FP
import ParserCombinator

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
    
    private var parentExpr: Parser<Substring, Int> {
        
        return (leftParentheses >>- { _ in return self.expression })  <* rightParentheses
    }
    
    private var item: Parser<Substring, Int> {
        
        return integer <|> parentExpr
    }
    
    private var multiplicationAndDivision: Parser<Substring, Int> {
        
        return item.chainl1(op: multiOp <|> divOp )
    }
    
    private var additionAndSubtraction: Parser<Substring, Int> {
        
        return multiplicationAndDivision.chainl1(op: addOp <|> subOp)
    }
    
    private var expression: Parser<Substring, Int> {
        
        return additionAndSubtraction
    }
    
    func execute(_ s: String) throws -> Int {
        
        switch expression.parse(Substring(s)) {
        case let .done (_, out):
            return out
        case let .fail(e):
            throw e
        }
    }
}

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        do {
            try print(Interpreter().execute("1+2*(3+4)"))
        } catch {
            print(error)
        }
        
        
    }
    
    
}



