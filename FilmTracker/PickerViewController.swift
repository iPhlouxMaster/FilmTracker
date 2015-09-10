//
//  PickerTableViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 6/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

protocol PickerViewControllerDelegate: class {
    func pickerViewControllerDidPickItems(controller: PickerViewController, items: [String], isPickingCountries: Bool)
}

class PickerViewController: UITableViewController {
    
    var countriesArray: [String]?
    var countryList = [String]()
    var genresArray: [String]?
    var genreList = [String]()
    var isPickingCountries = true
    
    let userDefault = NSUserDefaults.standardUserDefaults()
    var isSelected: [Bool]!
    var numberOfItems = 0
    
    weak var delegate: PickerViewControllerDelegate?
    
    var observer: AnyObject!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        
        if countriesArray != nil && genresArray == nil {
            isPickingCountries = true
        } else {
            isPickingCountries = false
        }
        
        configureBarButtonItems()
        configureList()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        print("*** PickerViewController deinited")
    }
    
    // MARK: - KVO
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil && strongSelf.presentedViewController!.isMemberOfClass(UIAlertView) {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
            }
        })
    }
    
    // MARK: - UIButtons
    
    func doneButtonPressed(sender: UIButton) {
        var selectedElements = [String]()
        for (index, selectedIndex) in isSelected.enumerate() {
            if selectedIndex {
                if isPickingCountries {
                    selectedElements.append(countryList[index])
                } else {
                    selectedElements.append(genreList[index])
                }
            }
        }
        selectedElements = selectedElements.sort()
        
        if let delegate = delegate {
            delegate.pickerViewControllerDidPickItems(self, items: selectedElements, isPickingCountries: isPickingCountries)
        }
    }
    
    func addButtonPressed(button: UIButton) {
        
        var title = ""
        if isPickingCountries {
            title = "Add production country"
        } else {
            title = "Add genre"
        }
        
        let addElementAlert = UIAlertController(title: title, message: nil, preferredStyle: .Alert)
        addElementAlert.addTextFieldWithConfigurationHandler({
            _ in
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Default, handler: {
            _ in
        })
        
        let addAction = UIAlertAction(title: "Add", style: .Default, handler: {
            _ in
            let textField = addElementAlert.textFields![0]
            self.addElement(textField.text!)
            self.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: self.numberOfItems - 1, inSection: 0), atScrollPosition: .Top, animated: true)
        })
        
        addElementAlert.addAction(cancelAction)
        addElementAlert.addAction(addAction)
        
        self.presentViewController(addElementAlert, animated: true, completion: nil)
    }
    
    // MARK: - Helper Methods
    
    func configureBarButtonItems() {
        let rightDoneBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: "Done", style: .Done, target: self, action: "doneButtonPressed:")
        
        var buttonTitle = ""
        if isPickingCountries {
            title = "Choose Countries"
            buttonTitle = "Add Country"
        } else {
            title = "Choose Genres"
            buttonTitle = "Add Genre"
        }
        
        let rightAddBarButtonItem: UIBarButtonItem = UIBarButtonItem(title: buttonTitle, style: .Plain, target: self, action: "addButtonPressed:")
        
        navigationItem.setRightBarButtonItems([rightDoneBarButtonItem, rightAddBarButtonItem], animated: false)
    }
    
    func configureList() {
        
        if isPickingCountries {
            countryList = userDefault.valueForKey("CountryList") as! [String]
            countryList = countryList.sort()
            numberOfItems = countryList.count
        } else {
            genreList = userDefault.valueForKey("GenreList") as! [String]
            genreList = genreList.sort()
            numberOfItems = genreList.count
        }
        
        isSelected = Array(count: numberOfItems, repeatedValue: false)
        
        if isPickingCountries {
            
            for (index, country) in countryList.enumerate() {
                if countriesArray!.contains(country) {
                    isSelected[index] = true
                }
            }
        } else {
            for (index, genre) in genreList.enumerate() {
                if genresArray!.contains(genre) {
                    isSelected[index] = true
                }
            }
        }
    }
    
    func addElement(element: String) {
        if isPickingCountries {
            if !countryList.contains(element) {
                countryList.append(element)
                isSelected.append(true)
                numberOfItems++
                userDefault.setObject(countryList, forKey: "CountryList")
                userDefault.synchronize()
            } else {
                isSelected[countryList.indexOf(element)!] = true
            }
        } else {
            if !genreList.contains(element) {
                genreList.append(element)
                isSelected.append(true)
                numberOfItems++
                userDefault.setObject(genreList, forKey: "GenreList")
                userDefault.synchronize()
            } else {
                isSelected[genreList.indexOf(element)!] = true
            }
        }
        tableView.reloadData()
    }
    
    // MARK: - TableView Delegate / Data Source
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("PickerCell")
        if isPickingCountries {
            cell!.textLabel!.text = countryList[indexPath.row]
        } else {
            cell!.textLabel!.text = genreList[indexPath.row]
        }
        
        if isSelected[indexPath.row] {
            cell!.accessoryType = .Checkmark
        } else {
            cell!.accessoryType = .None
        }
        
        return cell!
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return numberOfItems
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        isSelected[indexPath.row] = !isSelected[indexPath.row]
        tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        super.tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            if isPickingCountries {
                countryList.removeAtIndex(indexPath.row)
            } else {
                genreList.removeAtIndex(indexPath.row)
            }
            isSelected.removeAtIndex(indexPath.row)
            numberOfItems--
            tableView.reloadData()
        }
    }
    
}
