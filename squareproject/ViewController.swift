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
    var sortType: Field = .noneSpecified
    var imageCache: [Int:UIImage?] = [:]
    var searchText: String = ""
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var noResultsLabel: UIView!
    
    private let refreshControl: UIRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.searchBar.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.setupKeyboard()
        self.noResultsLabel.isHidden = true
        self.setupRefreshControl()
        
        DispatchQueue.main.async { self.fetchData(with: .directory) }
    }
}

//MARK: - Helper Functions

extension ViewController {
    func setupRefreshControl() {
        if #available(iOS 10.0, *) { self.tableView.refreshControl = self.refreshControl }
        else { self.tableView.addSubview(self.refreshControl) }
        self.refreshControl.addTarget(self, action: #selector(refreshDirectory(_:)), for: .valueChanged)
    }

    func imageForCell(employee: Employee, at index: IndexPath, completion: @escaping CompletionHandler) {
        if let image = self.imageCache[index.row], let image = image {
            completion(image)
        } else { self.addImageToCache(employee.photo_url_small, at: index, completion: completion) }
    }
    
    func addImageToCache(_ employeeUrl: String, at index: IndexPath, completion: @escaping CompletionHandler) {
        guard let url = URL(string: employeeUrl) else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let strongSelf = self else { return }
            guard let imageData = try? Data(contentsOf: url) else { return }
            guard let loadedImage  = UIImage(data: imageData) else { return }
            strongSelf.imageCache.updateValue(loadedImage, forKey: index.row)
            completion(loadedImage)
        }
    }
    
    func fetchData(with urlType: UrlType) {
        self.directory = nil
        self.searchDirectory = nil
        self.tableView.reloadData()
        
        AF.request(self.directoryURL).responseDecodable(of: Directory.self) { response in
            guard response.error == nil else { self.alert(errorType: .malformed); return }
            guard let directory = response.value else { self.alert(errorType: .malformed); return }
            guard !directory.isEmpty() else { self.alert(errorType: .empty); return }
            
            self.directory = directory
            self.searchDirectory = directory

            self.tableView.reloadData()
            DispatchQueue.main.async { self.refreshControl.endRefreshing() }
        }
    }
    
    //MARK: - Sort and Search Functions
    
    public func search(_ directory: Directory, by searchText: String) -> Directory {
        guard !searchText.isEmpty else { return directory }
        
        let employees = directory.employees.filter { $0.full_name.lowercased().contains(searchText.lowercased()) }
        
        var directory: Directory = Directory()
        
        employees.forEach { employee in
            directory.append(employee: employee)
        }
        
        return directory
    }
    
    public func sort(_ directory: Directory, by field: Field = .noneSpecified) -> Directory {
        self.sortType = field
        var employees: [Employee]
        
        switch field {
        case .uuid: employees = directory.employees.sorted { $0.uuid < $1.uuid }; break
        case .biography: employees = directory.employees.sorted { $0.biography < $1.biography }; break
        case .email: employees = directory.employees.sorted { $0.email_address < $1.email_address }; break
        case .employeeType: employees = directory.employees.sorted { $0.employee_type < $1.employee_type }; break
        case .team: employees = directory.employees.sorted { $0.team < $1.team }; break
        case .firstName: employees = directory.employees.sorted { $0.full_name.components(separatedBy: " ").first ?? "" < $1.full_name.components(separatedBy: " ").first ?? "" }; break
        case .lastName: employees = directory.employees.sorted { $0.full_name.components(separatedBy: " ").last ?? "" < $1.full_name.components(separatedBy: " ").last ?? "" }; break
        case .phoneNumber: employees = directory.employees.sorted { $0.phone_number < $1.phone_number }; break
        case .noneSpecified: employees = directory.employees; break
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
        guard let count = directory?.employees.count else { return 0 }
        return count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell = self.tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        if let directory = self.directory, let employee = directory.employee(at: indexPath.row) {
            if let imageView = cell.contentView.subviews.first as? UIImageView {
                imageView.backgroundColor = .secondarySystemBackground
                
                self.imageForCell(employee: employee, at: indexPath) { image in
                    imageView.backgroundColor = .clear
                    imageView.image = image
                }
                
                imageView.layer.cornerRadius = imageView.frame.size.width / 2
                imageView.clipsToBounds = true
                imageView.layer.borderWidth = 2.0
                imageView.layer.borderColor = UIColor.tertiarySystemBackground.cgColor
            }

            if let namelabel = cell.contentView.subviews.first(where:  {$0.isMember(of: UILabel.self)}) as? UILabel { namelabel.text = employee.full_name }
            if let teamlabel = cell.contentView.subviews.last(where:  { $0.isMember(of: UILabel.self)}) as? UILabel { teamlabel.text = employee.team }
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.alert(employeeCard: indexPath.row)
    }
}

//MARK: - Alert Controller

extension ViewController {
    func sortAlert() -> UIAlertController {
        var message: String = ""
        switch self.sortType {
        case .noneSpecified: message = ""
        case .team: message = "Team"
        case .firstName: message = "First Team"
        case .lastName: message = "Last Name"
        case .employeeType: message = "Employee Type"
        case .phoneNumber: message = "Phone Number"
        case .uuid, .biography, .email: break
        }
        
        let sortAlert = UIAlertController(title: "Sort", message: message, preferredStyle: .alert)

        sortAlert.addAction(UIAlertAction(title: "Team", style: .default, handler: { _ in
            if let directory = self.directory { self.directory = self.sort(directory, by: .team) }
            guard !(self.directory?.isEmpty() ?? false) else {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }))
        sortAlert.addAction(UIAlertAction(title: "First Name", style: .default, handler: { _ in
            if let directory = self.directory { self.directory = self.sort(directory, by: .firstName) }
            guard !(self.directory?.isEmpty() ?? false) else {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }))
        sortAlert.addAction(UIAlertAction(title: "Last Name", style: .default, handler: { _ in
            if let directory = self.directory { self.directory = self.sort(directory, by: .lastName) }
            guard !(self.directory?.isEmpty() ?? false) else {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }))
        sortAlert.addAction(UIAlertAction(title: "Employee Type", style: .default, handler: { _ in
            if let directory = self.directory { self.directory = self.sort(directory, by: .employeeType) }
            guard !(self.directory?.isEmpty() ?? false) else {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }))
        sortAlert.addAction(UIAlertAction(title: "Reset", style: .cancel, handler: { _  in
            if let directory = self.searchDirectory { self.directory = self.sort(self.search(directory, by: self.searchText), by: .noneSpecified) }
            guard !(self.directory?.isEmpty() ?? false) else {
                self.noResultsLabel.isHidden = false
                self.tableView.isHidden = true
                return
            }
            self.tableView.isHidden = false
            self.tableView.reloadData()
        }))
        return sortAlert
    }
    
    func alert(sort: Bool = false, employeeCard: Int? = nil, errorType: UrlType = .malformed) {
        guard !sort else {
            self.present(self.sortAlert(), animated: true, completion: nil)
            return
        }
        
        guard employeeCard == nil else {
            if let directory = self.directory, let employee = directory.employee(at: employeeCard!) {
                let employeeAlert = UIAlertController(title: "\(employee.full_name)", message: "Team: \(employee.team)\nPhone Number: \(employee.phone_number)\nEmployee Type: \(employee.employee_type == "FULL_TIME" ? "Full Time" : employee.employee_type == "PART_TIME" ? "Part Time" : "Contractor")\n Email: \(employee.email_address)\nBio: \(employee.biography)", preferredStyle: .alert)
                
                employeeAlert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(employeeAlert, animated: true, completion: nil)
            }
            return
        }
        
        let alert = UIAlertController(title: "Error", message: errorType == .malformed ? "Unable to fetch results, malformed data" : "Empty response", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Retry", style: .default, handler: { _ in self.fetchData(with: .directory) }))
        
        self.present(alert, animated: true, completion: nil)
    }
}

//MARK: - Refresh Control

extension ViewController {
    @objc private func refreshDirectory(_ sender: Any) {
        self.sortType = .noneSpecified
        self.searchText = ""
        self.searchBar.text = ""
        self.searchBar.resignFirstResponder()
        self.fetchData(with: .directory)
    }
}

//MARK: - SearchBar Delegate

extension ViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
        if let directory = self.searchDirectory {
            self.directory = self.sort(self.search(directory, by: searchText), by: self.sortType)
        }
        guard !(self.directory?.isEmpty() ?? false) else {
            self.noResultsLabel.isHidden = false
            self.tableView.isHidden = true
            return
        }
        self.tableView.isHidden = false
        self.tableView.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
    func setupKeyboard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard(_:)))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }

    @objc func dismissKeyboard(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)

        if let nav = self.navigationController {
            nav.view.endEditing(true)
        }
    }
}

// MARK: - Sort Button Delegate

extension ViewController {
    @IBAction func buttonPressed(_ sender: Any) {
        DispatchQueue.main.async { self.alert(sort: true) }
    }
}

typealias CompletionHandler = (_ image: UIImage) -> Void
