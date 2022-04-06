//
//  Employee.swift
//  squareproject
//
//  Created by Brendon Brinkmann on 4/5/22.
//

struct Employee: Codable {
    let uuid: String
    let full_name: String
    let phone_number: String
    let email_address: String
    let biography: String
    let photo_url_small: String
    let photo_url_large: String
    let team: String
    let employee_type: String
    
    public init(uuid: String, full_name: String, phone_number: String, email_address: String, biography: String, photo_url_small: String, photo_url_large: String, team: String, employee_type: String) {
        self.uuid = uuid
        self.full_name = full_name
        self.phone_number = phone_number
        self.email_address = email_address
        self.biography = biography
        self.photo_url_small = photo_url_small
        self.photo_url_large = photo_url_large
        self.team = team
        self.employee_type = employee_type
    }
}
