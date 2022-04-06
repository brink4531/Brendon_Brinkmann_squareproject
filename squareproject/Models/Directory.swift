//
//  Directory.swift
//  squareproject
//
//  Created by Brendon Brinkmann on 4/5/22.
//

import Foundation

struct Directory: Codable {
    var employees: [Employee]
    
    public init() {
        self.employees = []
    }
    
    public func employee(at index: Int) -> Employee? {
        guard index < self.employees.count else { return nil }
        return self.employees[index]
    }
    
    public mutating func append(employee: Employee) {
        var temp = employees; temp.append(employee); self.employees = temp
    }
    
    public mutating func remove(employee: Employee) {
        let temp = self.employees.filter { $0.uuid != employee.uuid }; self.employees = temp
    }
    
    public func isEmpty() -> Bool {
        return self.employees.isEmpty
    }
}
