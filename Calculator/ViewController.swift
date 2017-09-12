//
//  ViewController.swift
//  Calculator
//
//  Created by Brandon Abajelo on 6/6/17.
//  Copyright © 2017 Brandon Abajelo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    // declaring  with ! allows you to omit ! everywhere else var is used
    @IBOutlet private weak var display: UILabel!
    
    private var userIsInMiddleOfTyping = false
    
    @IBAction private func touchDigit(_ sender: UIButton) {
        let digit = sender.currentTitle!
        
        if userIsInMiddleOfTyping {
            // ensure proper floating point operations 
            if (digit == ".") && (display.text!.range(of: ".") != nil){ return }
            let textCurrentlyInDisplay = display.text!
            display.text = textCurrentlyInDisplay + digit
        }
        else {
            if digit == "." {
                display.text = "0."
            }else {
                display.text = digit
            }
        userIsInMiddleOfTyping = true
    }
}
    private var numberFormatter = NumberFormatter()
    
    // computed property
    private var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    private var brain = CalculatorBrain()
    
    @IBAction private func performAction(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            brain.setOperand(operand: displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(symbol: mathematicalSymbol)
        }
        displayValue = brain.result
        
        if sender.currentTitle == "=" {
            print("Operation: \(brain.description) = \(displayValue)")
            brain.clearPrintStack()
        }
    }
}






