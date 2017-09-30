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
    private var accumulator = 0.0
    
    var result: Double
    {
        get {
            return accumulator
        }
    }
    
    // used for clear function
    private var isLastButtonClear = false
    
    
    private var printStack : [Any] = []
    
     var variableValues = [String : Double]()
    
    private var variableHistory = [Any]()
    
     func setOperand(operand: Double){
        variableHistory.append(operand)
        printStack.append(operand)
        accumulator = operand
    }
    
     func setOperandVar(variableName: String){
        variableHistory.append(variableName)
        printStack.append(variableName)
    }
    
     func addVariable(symbol : String, value : Double){
        variableValues[symbol] = value
    }
    
    private var numFormatter: NumberFormatter?
    
     var description: String {
        
        var resultString = ""
        for prop in printStack {
            if let operand = prop as? Double {
                let stringToAppend = numFormatter?.string(from: NSNumber(value: operand)) ?? String(operand)
                resultString = resultString + stringToAppend
            } else if let symbol = prop as? String {
                if let operation = operations[symbol]{
                    switch operation {
                    case .Constant, .BinaryOperation:
                        resultString = resultString + symbol
                    case .UnaryOperation(let printSymbol, _):
                        switch printSymbol {
                        case .Postfix(let symbol):
                            resultString = "(" + resultString + ")" + symbol
                        case .Prefix(let symbol):
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
    private var operations: Dictionary<String, Operations> = [
        
        "π" : Operations.Constant(Double.pi),
        "e" : Operations.Constant(M_E),
        "√" : Operations.UnaryOperation(.Prefix("√"), sqrt),
        "cos" : Operations.UnaryOperation(.Prefix("cos"), {cos($0*Double.pi/180)}),
        "×" : Operations.BinaryOperation({$0 * $1}),
        "=" : Operations.Equals,
        "+": Operations.BinaryOperation({$0 + $1}),
        "−": Operations.BinaryOperation({$0 - $1}),
        "÷": Operations.BinaryOperation({$0 / $1}),
        "sin" : Operations.UnaryOperation(.Prefix("sin"), {sin($0*Double.pi/180)}),
        "tan" : Operations.UnaryOperation(.Prefix("tan"), {tan($0*Double.pi/180)}),
        "x²" : Operations.UnaryOperation(.Postfix("²")) { $0 * $0 },
        "1/x" : Operations.UnaryOperation(.Postfix("⁻¹")) { 1/$0 },
        "MC" : Operations.ClearMemory,
        "MR" : Operations.MemoryRecall,
        "MS" : Operations.MemoryStore,
        "M+" : Operations.MemoryAdd,
        "C" : Operations.Clear
    ]
    
    // associated value of enums
    private enum Operations {
        case Constant(Double)
        case UnaryOperation(PrintSymbol, (Double) -> Double)
//        case VariableUnaryOperation(Double)
        case BinaryOperation((Double, Double) -> Double)
        case Equals
        case ClearMemory
        case MemoryRecall
        case MemoryStore
        case MemoryAdd
        case Clear
        
        enum PrintSymbol {
            case Prefix(String)
            case Postfix(String)
        }
    }
    private func execPendingBinary() {
        if pending != nil {
            accumulator = pending!.binFunction(pending!.firstOperand, accumulator)
            pending = nil
        }
    }
    
    private var memory = 0.0
    
    // memory functions
    private func clearMemory() {
        memory = 0.0
    }
    
    private func memoryRecall() -> Double {
        return memory
    }
    
    private func memoryStore() {
        memory = accumulator
    }
    
    private func memoryAdd() {
        memory += accumulator
        
    }
    
    // creates struct
    private var pending: BinaryInfo?
    
    // constructor for struct uses all it's vars
    private struct BinaryInfo {
        var binFunction : (Double, Double) -> Double
        var firstOperand : Double
        
    }
    
     func clearPrintStack() {
        printStack.removeAll()
    }
    
    // clear function where if pressed once, it deletes the most recent operand, if pressed twice, it deletes the whole operation stack
    private func clear()  {
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
    
    func performOperation(symbol: String){
        
        
        if let operation = operations[symbol]{
            
            switch operation {
                
            case .Constant(let associatedValue):
                accumulator = associatedValue
                isLastButtonClear = false
                
                // 'let function' assigns generic function type to unary operator
            case .UnaryOperation(_, let function):
                
                accumulator = function(accumulator)
                isLastButtonClear = false

                
            case .BinaryOperation(let function):
                execPendingBinary()
                pending = BinaryInfo(binFunction: function, firstOperand: accumulator)
                isLastButtonClear = false

               
            case .Equals:
               execPendingBinary()
               isLastButtonClear = false

            
            case .ClearMemory:
                clearMemory()
                isLastButtonClear = false

            
            case .MemoryRecall:
                accumulator = memoryRecall()
                isLastButtonClear = false

            
            case .MemoryAdd:
                memoryAdd()
                isLastButtonClear = false

                
            case .MemoryStore:
                memoryStore()
                isLastButtonClear = false

                
            case .Clear:
                clear()
            

            printStack.append(symbol)
            }
        }
    }
}

