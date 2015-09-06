//
//  PickerTableViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 6/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class PickerViewController: UITableViewController {
    
    var countriesArray: [String]?
    var countryList = [String]()
    var genresArray: [String]?
    var genreList = [String]()
    let userDefault = NSUserDefaults.standardUserDefaults()
    var isSelected: [Bool]?
    var numberOfItems = 0

    override func viewDidLoad() {
        super.viewDidLoad()
        var rightDoneBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneButtonPressed:")
        var buttonTitle = ""
        if countriesArray != nil && genresArray == nil {
            buttonTitle = "Add Country"
            countryList = userDefault.valueForKey("CountryList") as! [String]
            numberOfItems = countryList.count
        } else {
            buttonTitle = "Add Genre"
            genreList = userDefault.valueForKey("GenreList") as! [String]
            numberOfItems = genreList.count
        }
        
        var rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .Plain, target: self, action: "addButtonPressed:")
        
        navigationItem.setRightBarButtonItems([rightDoneBarButtonItem, rightAddBarButtonItem], animated: false)
    }
    
    func doneButtonPressed(sender: UIButton) {
        
    }
    
    func addButtonPressed(button: UIButton) {
        
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell") as! UITableViewCell
        if countriesArray != nil && genresArray == nil {
            cell.textLabel!.text = countryList[indexPath.row]
        } else {
            cell.textLabel!.text = genreList[indexPath.row]
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
}
