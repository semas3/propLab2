//
//  CalculatorImpl.swift
//  calculator
//
//  Created by student on 12.12.2023.
//  Copyright © 2023 Илья Лошкарёв. All rights reserved.
//

import Foundation

class CalculatorImpl: Calculator {
    weak var delegate: CalculatorDelegate?
    
    var result: Double?
    var operation: Operation?
    var input: Double?
    
    var expression: String = ""
    var inputStr: String = ""
    var leftStr: String = ""
    var mf: UInt
    var il: UInt
    
    required init(inputLength len: UInt, maxFraction frac: UInt) {
        mf = frac
        il = len
    }
    
    func addDigit(_ d: Int) {
        if inputStr.count >= il {
            return
        }
        if (inputStr.suffix(2) == ".0")
        {
            inputStr.removeLast()
        }

        inputStr = inputStr + "\(d)"
        delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: fractionDigits)
    }
    
    func addPoint() {
        
        if (inputStr.isEmpty)
        {
            return
        }
        
        if inputStr.count >= il {
            return
        }
        
        if (inputStr.contains("."))
        {
            return
        }
        
        inputStr = inputStr + ".0"
        delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: 1)
    }
    
    var hasPoint: Bool {
        if (inputStr.contains("."))
        {
            return true
        }

        return false
    }
    
    var fractionDigits: UInt {
        if (!inputStr.contains("."))
        {
            return 0
        }

        let c = inputStr.split(separator: ".")[1].count
        
        return UInt(c)
    }
    
    func addOperation(_ op: Operation) {
        if inputStr.isEmpty
        {
            operation = op
            return
        }
        
        if op == Operation.perc
        {
            leftStr = ""
            inputStr = String(Double(inputStr)! / 100)
            delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: fractionDigits)
            return
        }
        
        if op == Operation.sign
        {
            inputStr = String(Double(inputStr)! * (-1))
            delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: fractionDigits)
            return
        }

        if leftStr.isEmpty
        {
            leftStr = inputStr
            inputStr = ""
            operation = op
            delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: fractionDigits)
            return
        }

        let res = performOperation(left:Double(leftStr)!, right:Double(inputStr)!, operation:operation!)
        leftStr = String(res)

        operation = op
        inputStr = ""
        delegate?.calculatorDidUpdateValue(self, with: Double(res) , valuePrecision: fractionDigits)
    }
    
    func compute() {
        if leftStr.isEmpty
        {
            return
        }

        if inputStr.isEmpty
        {
            return
        }

        let res = performOperation(left: Double(leftStr)!, right: Double(inputStr)!, operation: operation!)
        leftStr = ""
        inputStr = String(res)
        delegate?.calculatorDidUpdateValue(self, with: res , valuePrecision: fractionDigits)
    }
    
    func clear() {
        inputStr = ""
        delegate?.calculatorDidUpdateValue(self, with: Double(inputStr) ?? 0.0, valuePrecision: fractionDigits)
    }
    
    func reset() {
        result = nil
        operation = nil
        input = nil
        expression = ""
        inputStr = ""
        leftStr = ""
        delegate?.calculatorDidClear(self, withDefaultValue: result, defaultPrecision: fractionDigits)
    }
    
    private func performOperation(left: Double, right: Double, operation: Operation) -> Double {
        switch operation {
        case .add:
            return left + right
        case .sub:
            return left - right
        case .mul:
            return left * right
        case .div:
            if right != 0 {
                return left / right
            } else {
                delegate?.calculatorDidNotCompute(self, withError: "Division by zero")
                return left
            }
        default:
            return left
        }
    }
}
