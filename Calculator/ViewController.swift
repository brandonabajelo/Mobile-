//
//  ViewController.swift
//  Calculator
//
//  Created by Brandon Abajelo on 6/6/17.
//  Copyright © 2017 Brandon Abajelo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        variable.delegate = self as? UITextFieldDelegate
        variableVal.delegate = self as? UITextFieldDelegate
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**
     * Called when 'return' key pressed. return NO to ignore.
     */
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /**
     * Called when the user click on the view (outside the UITextField).
     */
     func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        self.view.endEditing(true)
    }

    
    
    
    // declaring  with ! allows you to omit ! everywhere else var is used
    @IBOutlet fileprivate weak var display: UILabel!
    
    fileprivate var userIsInMiddleOfTyping = false
    
    // function is called every time a digit button is clicked, including .
    @IBAction fileprivate func touchDigit(_ sender: UIButton) {
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
    fileprivate var numberFormatter = NumberFormatter()
    
    // computed property
    fileprivate var displayValue: Double {
        get {
            return Double(display.text!)!
        }
        set {
            display.text = String(newValue)
        }
    }

    fileprivate var brain = CalculatorBrain()
    
    // function is called every time there is an operation or equals sign
    @IBAction fileprivate func performAction(_ sender: UIButton) {
        if userIsInMiddleOfTyping {
            brain.setOperand(displayValue)
            userIsInMiddleOfTyping = false
        }
        if let mathematicalSymbol = sender.currentTitle {
            brain.performOperation(mathematicalSymbol)
        }
        displayValue = brain.result
        
        if sender.currentTitle == "=" {
            print("Operation: \(brain.description) = \(displayValue)")
            brain.clearPrintStack()
        }
    }
    
    @IBOutlet weak var variable: UITextField!
    @IBOutlet weak var variableVal: UITextField!
    
   
 
    @IBAction func use(_ sender: UIButton) {
        variableVal.text! = ""
        brain.setOperandVar(variable.text!)
        displayValue = brain.variableValues[variable.text!]!
        // brain.accumulator += Double(displayValue)
    }
    
    
    @IBAction func create(_ sender: UIButton) {
        if let str = variable.text{
            if let num = Double(variableVal.text!){
                brain.addVariable(str, value: num)
            }
        }
       
    }
}







