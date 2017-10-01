//
//  CalculatorBrain.swift
//  Calculator
//
//  Created by Brandon Abajelo on 6/12/17.
//  Copyright © 2017 Brandon Abajelo. All rights reserved.
//

import Foundation

// global function not inside class, more of a style preference 


func inverse(number x: Double) -> Double { return 1/x }

class CalculatorBrain
{
     var accumulator = 0.0
    
    fileprivate var touchEqualButton = false
    
    var result: Double
    {
        get {
            return accumulator
        }
    }
    
    // used for clear function
    fileprivate var isLastButtonClear = false
    
    
    fileprivate var printStack : [Any] = []
    
     var variableValues = [String : Double]()
    
    fileprivate var variableHistory = [Any]()
    
     func setOperand(_ operand: Double){
        //variableHistory.append(operand)
        printStack.append(operand)
        accumulator = operand
    }
    
     func setOperandVar(_ variableName: String){
        //variableHistory.append(variableName)
        printStack.append(variableName)
        accumulator = variableValues[variableName] ?? 0
        print("Variable: \(variableName) = \(String(describing: variableValues[variableName]))")
    }
    
     func addVariable(_ symbol : String, value : Double){
        variableValues[symbol] = value
    }
    
    fileprivate var numFormatter: NumberFormatter?
    
     var description: String {
        
        var resultString = ""
        
        for prop in printStack {
            if let operand = prop as? Double {
                let stringToAppend = numFormatter?.string(from: NSNumber(value: operand)) ?? String(operand)
                resultString = resultString + stringToAppend
            } else if let symbol = prop as? String {
                if let operation = operations[symbol]{
                    switch operation {
                    case .constant, .binaryOperation:
                        resultString = resultString + symbol
                    case .unaryOperation(let printSymbol, _):
                        switch printSymbol {
                        case .postfix(let symbol):
                            resultString = "(" + resultString + ")" + symbol
                        case .prefix(let symbol):
                            resultString = symbol + "(" + resultString + ")"
                        }
                    default:
                        break
                    }
                }
            }
        }
        return resultString
    }
    
        
    
    // trig functions altered so results are in degrees not radians 
    fileprivate var operations: Dictionary<String, Operations> = [
        
        "π" : Operations.constant(Double.pi),
        "e" : Operations.constant(M_E),
        "√" : Operations.unaryOperation(.prefix("√"), sqrt),
        "cos" : Operations.unaryOperation(.prefix("cos"), {cos($0*Double.pi/180)}),
        "×" : Operations.binaryOperation({$0 * $1}),
        "=" : Operations.equals,
        "+": Operations.binaryOperation({$0 + $1}),
        "−": Operations.binaryOperation({$0 - $1}),
        "÷": Operations.binaryOperation({$0 / $1}),
        "sin" : Operations.unaryOperation(.prefix("sin"), {sin($0*Double.pi/180)}),
        "tan" : Operations.unaryOperation(.prefix("tan"), {tan($0*Double.pi/180)}),
        "x²" : Operations.unaryOperation(.postfix("²")) { $0 * $0 },
        "1/x" : Operations.unaryOperation(.postfix("⁻¹")) { 1/$0 },
        "MC" : Operations.clearMemory,
        "MR" : Operations.memoryRecall,
        "MS" : Operations.memoryStore,
        "M+" : Operations.memoryAdd,
        "C" : Operations.clear
    ]
    
    // associated value of enums
    fileprivate enum Operations {
        case constant(Double)
        case unaryOperation(PrintSymbol, (Double) -> Double)
//        case VariableUnaryOperation(Double)
        case binaryOperation((Double, Double) -> Double)
        case equals
        case clearMemory
        case memoryRecall
        case memoryStore
        case memoryAdd
        case clear
        
        enum PrintSymbol {
            case prefix(String)
            case postfix(String)
        }
    }
    fileprivate func execPendingBinary() {
        if pending != nil {
            accumulator = pending!.binFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
        
        if touchEqualButton {
            printStack.append("\(String(accumulator))")
            touchEqualButton = false
        }
    }
    
    fileprivate var memory = 0.0
    
    // memory functions
    fileprivate func clearMemory() {
        memory = 0.0
    }
    
    fileprivate func memoryRecall() -> Double {
        return memory
    }
    
    fileprivate func memoryStore() {
        memory = accumulator
    }
    
    fileprivate func memoryAdd() {
        memory += accumulator
        
    }
    
    // creates struct
    fileprivate var pending: BinaryInfo?
    
    // constructor for struct uses all it's vars
    fileprivate struct BinaryInfo {
        var binFunction : (Double, Double) -> Double
        var firstOperand : Double
        
    }
    
     func clearPrintStack() {
        printStack.removeAll()
    }
    
    // clear function where if pressed once, it deletes the most recent operand, if pressed twice, it deletes the whole operation stack
    fileprivate func clear()  {
        if let _ = printStack.last as? Double{
            if(isLastButtonClear){
                accumulator = 0.0
                pending = nil
                clearPrintStack()
            }
            if(!isLastButtonClear){
                accumulator = 0.0
                printStack.removeLast()
                isLastButtonClear = true
            }
        }
        else{
            accumulator = 0.0
            pending = nil
            clearPrintStack()
        }
    }
    
    func performOperation(_ symbol: String){
        
        
        if let operation = operations[symbol]{
            
            switch operation {
                
            case .constant(let associatedValue):
                accumulator = associatedValue
                isLastButtonClear = false
                printStack.append(symbol)
                
                // 'let function' assigns generic function type to unary operator
            case .unaryOperation(_, let function):
                
                accumulator = function(accumulator)
                isLastButtonClear = false
                printStack.append(symbol)


                
            case .binaryOperation(let function):
                execPendingBinary()
                pending = BinaryInfo(binFunction: function, firstOperand: accumulator)
                isLastButtonClear = false
                printStack.append(symbol)


               
            case .equals:
               execPendingBinary()
               isLastButtonClear = false
                touchEqualButton = true
                

            
            case .clearMemory:
                clearMemory()
                isLastButtonClear = false

            
            case .memoryRecall:
                accumulator = memoryRecall()
                isLastButtonClear = false

            
            case .memoryAdd:
                memoryAdd()
                isLastButtonClear = false

                
            case .memoryStore:
                memoryStore()
                isLastButtonClear = false

                
            case .clear:
                clear()
            

            printStack.append(symbol)
            }
        }
    }
}

