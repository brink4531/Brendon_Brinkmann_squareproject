//
//  ViewController.swift
//  squareproject
//
//  Created by Brendon Brinkmann on 4/5/22.
//

import UIKit
import Alamofire

class ViewController: UIViewController {
    let directoryURL: String = "https://s3.amazonaws.com/sq-mobile-interview/employees.json"
    let malformedURL: String = "https://s3.amazonaws.com/sq-mobile-interview/employees_malformed.json"
    let emptyURL: String = "https://s3.amazonaws.com/sq-mobile-interview/employees_empty.json"
    
    var directory: Directory? = nil
    var searchDirectory: Directory? = nil
    
    var imageCache: [Int:UIImage?] = [:]
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    
    
    @IBOutlet var headShot: UIImageView!
    @IBOutlet var fullName: UILabel!
    @IBOutlet var team: UILabel!
    @IBOutlet var employeeType: UILabel!
    @IBOutlet var email: UILabel!
    @IBOutlet var cellPhone: UILabel!
    @IBOutlet var biography: UILabel!

    
    //MARK: - TODO: Pull to refresh (or reset button), Sort Bttn, Loading Animation, Empty List View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        
        self.headShot.layer.cornerRadius = self.headShot.frame.size.width / 2
        self.headShot.clipsToBounds = true

        DispatchQueue.main.async { self.alert(launch: true) }
    }
}

//MARK: - Helper Functions

extension ViewController {
    func updateUserInfoSheet(employee: Employee, at index: Int) {
        self.fullName.text = employee.full_name
        self.team.text = employee.team
        self.employeeType.text = "- " + (employee.employee_type == "FULL_TIME" ? "Full Time" : employee.employee_type == "PART_TIME" ? "Part Time" : "Contractor")
        self.email.text = "- " + employee.email_address
        self.biography.text = "- " + employee.biography
        self.cellPhone.text = "- " + employee.phone_number
        
        if let image = self.imageCache[index] {
            self.headShot.image = image
        } else { self.addImageToCache(employee.photo_url_small, at: index) }
        
        self.headShot.layer.borderWidth = 3.0
        self.headShot.layer.borderColor = self.fullName.textColor.cgColor
    }
    
    func addImageToCache(_ employeeUrl: String, at index: Int) {
        guard let url = URL(string: employeeUrl) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let loadedImage  = UIImage(data: imageData) else { return }
            strongSelf.headShot.image = loadedImage
            strongSelf.imageCache.updateValue(loadedImage, forKey: index)
        }
    }
    
    func fetchData(with urlType: UrlType) {
        self.directory = nil
        self.searchDirectory = nil
        
        self.tableView.reloadData()
        
        let url = urlType == .directory ? self.directoryURL : urlType == .empty ? self.emptyURL : self.malformedURL
        AF.request(url).response { response in
            guard response.error == nil else { self.alert(); return } // Alert Message
            guard let data = response.data else { self.alert(); return } // Alert Message
            guard let directory = try? JSONDecoder().decode(Directory.self, from: data) else { self.alert(); return } // Alert Message
            guard !directory.isEmpty() else { self.alert(errorType: .empty); return }
            
            self.directory = directory
            self.searchDirectory = directory
            
            if !directory.isEmpty(), let employee = directory.employee(at: 0) { self.updateUserInfoSheet(employee: employee, at: 0) }
            
            self.tableView.reloadData()
        }
    }
    
    //MARK: - Sort and Search Functions
    
    public func search(_ directory: Directory, by searchText: String) -> Directory {
        guard !searchText.isEmpty else { return directory }
        
        let employees = directory.employees.filter {
            $0.uuid.lowercased().contains(searchText.lowercased()) ||
            $0.full_name.lowercased().contains(searchText.lowercased()) ||
            $0.phone_number.lowercased().contains(searchText.lowercased()) ||
            $0.email_address.lowercased().contains(searchText.lowercased()) ||
            $0.photo_url_small.lowercased().contains(searchText.lowercased()) ||
            $0.photo_url_large.lowercased().contains(searchText.lowercased()) ||
            $0.team.lowercased().contains(searchText.lowercased()) ||
            $0.employee_type.lowercased().replacingOccurrences(of: "_", with: " ").contains(searchText.lowercased())
        }
        
        var directory: Directory = Directory()
        
        employees.forEach { employee in
            directory.append(employee: employee)
        }
        
        return directory
    }
    
    public func sort(_ directory: Directory, by field: Field) -> Directory {
        var employees: [Employee]
        
        switch field {
        case .uuid: employees = directory.employees.sorted { $0.uuid > $1.uuid }; break
        case .biography: employees = directory.employees.sorted { $0.biography > $1.biography }; break
        case .email: employees = directory.employees.sorted { $0.email_address > $1.email_address }; break
        case .employeeType: employees = directory.employees.sorted { $0.employee_type > $1.employee_type }; break
        case .team: employees = directory.employees.sorted { $0.team > $1.team }; break
        case .firstName: employees = directory.employees.sorted { $0.full_name.components(separatedBy: " ")[0] > $1.full_name }; break
        case .lastName: employees = directory.employees.sorted { $0.full_name.components(separatedBy: " ")[1] > $1.full_name }; break
        }
        
        var directory: Directory = Directory()
        
        employees.forEach { employee in
            directory.append(employee: employee)
        }
        
        return directory
    }
}

//MARK: - TableView Delegate and DataSource

extension ViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let count = directory?.employees.count else { return 0 } // alert
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let directory = self.directory {
            cell.textLabel?.text = directory.employees[indexPath.row].full_name
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let directory = self.directory, let employee = directory.employee(at: indexPath.row) { self.updateUserInfoSheet(employee: employee, at: indexPath.row) }
    }
}

//MARK: - Alert Controller

extension ViewController {
    func alert(launch: Bool = false, errorType: UrlType = .malformed) {
        guard !launch else {
            let launchAlert = UIAlertController(title: "Launch", message: "", preferredStyle: .alert)
            
            launchAlert.addAction(UIAlertAction(title: "DirectoryURL", style: .default, handler: { _ in self.fetchData(with: .directory) }))
            launchAlert.addAction(UIAlertAction(title: "MalformedURL", style: .default, handler: { _ in self.fetchData(with: .malformed) }))
            launchAlert.addAction(UIAlertAction(title: "EmptyURL", style: .default, handler: { _ in self.fetchData(with: .empty) }))
            
            self.present(launchAlert, animated: true, completion: nil)
            return
        }
        
        let alert = UIAlertController(title: "Error", message: errorType == .malformed ? "Unable to fetch results, malformed data" : "Empty response", preferredStyle: .alert)
        let retryAlert = UIAlertController(title: "Retry", message: "", preferredStyle: .alert)
        
        retryAlert.addAction(UIAlertAction(title: "DirectoryURL", style: .default, handler: { _ in self.fetchData(with: .directory) }))
        retryAlert.addAction(UIAlertAction(title: "MalformedURL", style: .default, handler: { _ in self.fetchData(with: .malformed) }))
        retryAlert.addAction(UIAlertAction(title: "EmptyURL", style: .default, handler: { _ in self.fetchData(with: .empty) }))
        
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.present(retryAlert, animated: true, completion: nil) }))
        
        self.present(alert, animated: true, completion: nil)
    }
}


//MARK: - SearchBar Delegate

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if let directory = self.searchDirectory { self.directory = self.search(directory, by: searchText) }
        self.tableView.reloadData()
    }
}

// MARK: - Reset Button Delegate

extension ViewController {
    @IBAction func buttonPressed(_ sender: Any) {
        DispatchQueue.main.async { self.alert(launch: true) }
    }
}

// Temp
//employees: [
//    Employee(
//        uuid: "0d8fcc12-4d0c-425c-8355-390b312b909c",
//        full_name: "Justine Mason",
//        phone_number: "5553280123",
//        email_address: "jmason.demo@squareup.com",
//        biography: "Engineer on the Point of Sale team.",
//        photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/16c00560-6dd3-4af4-97a6-d4754e7f2394/small.jpg",
//        photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/16c00560-6dd3-4af4-97a6-d4754e7f2394/large.jpg",
//        team: "Point of Sale", employee_type: "FULL_TIME"
//    )
//]
//search [squareproject.Directory.Employee(uuid: "a98f8a2e-c975-4ba3-8b35-01f719e7de2d", full_name: "Camille Rogers", phone_number: "5558531970", email_address: "crogers.demo@squareup.com", biography: "Designer on the web marketing team.", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/5095a907-abc9-4734-8d1e-0eeb2506bfa8/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/5095a907-abc9-4734-8d1e-0eeb2506bfa8/large.jpg", team: "Public Web & Marketing", employee_type: "PART_TIME"), squareproject.Directory.Employee(uuid: "b8cf3382-ecf2-4240-b8ab-007688426e8c", full_name: "Richard Stein", phone_number: "5557223332", email_address: "rstein.demo@squareup.com", biography: "Product manager for the Point of sale app!", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/43ed39b3-fbc0-4eb8-8ed3-6a8de479a52a/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/43ed39b3-fbc0-4eb8-8ed3-6a8de479a52a/large.jpg", team: "Point of Sale", employee_type: "PART_TIME"), squareproject.Directory.Employee(uuid: "61b21d34-5499-401a-98b3-16f26e645d54", full_name: "Alaina Daly", phone_number: "5555442937", email_address: "adaly.demo@squareup.com", biography: "Product marketing manager for the Retail Point of Sale app in New York.", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/57bc7ed2-5f9e-4814-a7df-dea85c2ed97f/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/57bc7ed2-5f9e-4814-a7df-dea85c2ed97f/large.jpg", team: "Retail", employee_type: "FULL_TIME"), squareproject.Directory.Employee(uuid: "b6dea526-c571-4d43-8b41-375ca5cd9fdb", full_name: "Elisa Rizzo", phone_number: "5552234497", email_address: "erizzo.demo@squareup.com", biography: "iOS Engineer on the Restaurants team.", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/8ab10188-74d0-4843-9eb2-1938571f6830/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/8ab10188-74d0-4843-9eb2-1938571f6830/large.jpg", team: "Restaurants", employee_type: "FULL_TIME"), squareproject.Directory.Employee(uuid: "8623ba77-9d6a-4bcd-bd91-e19ae2c9dba2", full_name: "Ryan Gehani", phone_number: "5554047710", email_address: "rgehani.demo@squareup.com", biography: "Product manager for Invoices!", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/7959987e-0d64-4bf6-8b9e-da78deac3457/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/7959987e-0d64-4bf6-8b9e-da78deac3457/large.jpg", team: "Invoices", employee_type: "FULL_TIME"), squareproject.Directory.Employee(uuid: "7fb13023-d013-41ac-84f1-e554890ccb32", full_name: "Tim Nakamura", phone_number: "5557510409", email_address: "tnakamura.demo@squareup.com", biography: "Hardware packaging designer on the hardware team, working from LA.", photo_url_small: "https://s3.amazonaws.com/sq-mobile-interview/photos/e2b088e6-0b8d-4295-a66c-d7181cdec3d6/small.jpg", photo_url_large: "https://s3.amazonaws.com/sq-mobile-interview/photos/e2b088e6-0b8d-4295-a66c-d7181cdec3d6/large.jpg", team: "Hardware", employee_type: "CONTRACTOR")] by: R
