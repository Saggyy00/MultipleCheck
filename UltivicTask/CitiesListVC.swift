//
//  ViewController.swift
//  UltivicTask
//
//  Created by Mob-07 on 08/09/22.
//

import UIKit

class CitiesListVC: UIViewController, UITextFieldDelegate {
    
    //MARK: IBOutlets
    @IBOutlet weak var txtFldSearch: UITextField!
    @IBOutlet weak var tblVwCity: UITableView!
    @IBOutlet weak var txtVwCityTags: UITextView!
    
    var citiesList = [String]()
    var filteredList = [String]()
    var selectedCity = NSMutableArray()
    
    //MARK: View Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        txtFldSearch.addTarget(self, action: #selector(editingChanged), for: .editingChanged)
        
        fetchCities {
            self.tblVwCity.reloadData()
        }
    }
    
    //MARK: IBActions
    @IBAction func actionSelectAll(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        sender.isSelected ? selectedCity = NSMutableArray.init(array: self.filteredList.map({$0})) : selectedCity.removeAllObjects()
        txtVwCityTags.text = sender.isSelected ? "All Selected" : ""
        self.tblVwCity.reloadData()
    }
    
    func fetchCities(_ completion: @escaping() -> Void) {
        if let path = Bundle.main.path(forResource: "cities-name-list", ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                print(jsonResult)
                if let jsonResult = jsonResult as? [String] {
                    jsonResult.map { city in
                        citiesList.append(city)
                    }
                    filteredList = citiesList
                    completion()
                }
            } catch {
                debugPrint("Error while fetching the json data")
            }
        }
    }
    
    @objc func editingChanged(_ textField: UITextField) {
        if textField.text?.count == 1 {
            if textField.text?.first == " " {
                textField.text = ""
                return
            }
        }
        guard let searchedText = textField.text, !searchedText.isEmpty else {
            filteredList = citiesList
            return
        }
        
        filteredList = citiesList.filter { $0.lowercased().contains(searchedText) }
        self.tblVwCity.reloadData()
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        return false
    }
}

extension CitiesListVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredList.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let name = filteredList[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "CityTVC") as! CityTVC
        cell.lblTitle.text = filteredList[indexPath.row]
        cell.imgVwSelection.isHighlighted = selectedCity.contains(name)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let name = filteredList[indexPath.row]
        selectedCity.contains(name) ? selectedCity.remove(name) : selectedCity.add(name)
        txtVwCityTags.text = selectedCity.componentsJoined(by: ", ")
        tblVwCity.reloadData()
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
}
