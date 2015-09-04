//
//  ViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 30/08/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit
import CoreData

class SearchViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    let search = Search()
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NoResultCell"
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentValueChanged(sender: AnyObject) {
        performSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.contentInset = UIEdgeInsetsMake(108, 0, 0, 0)
        tableView.rowHeight = 140
        searchBar.becomeFirstResponder()
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowDetails" {
            switch search.state {
            case .Results(let results):
                let controller = segue.destinationViewController as! DetailViewController
                let indexPath = sender as! NSIndexPath
                controller.movie = results[indexPath.row]
                controller.managedObjectContext = managedObjectContext
            default:
                return
            }
        }
    }
}

// MARK: - UITableViewDataSource

extension SearchViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch search.state {
        case .Results(let results):
            return results.count
        case .NotSearchedYet:
            return 0
        default:
            return 1
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch search.state {
        case .Results(let results):
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.searchResultCell, forIndexPath: indexPath) as! SearchResultCell
            cell.configureForSearchResult(results[indexPath.row])
            return cell
        case .Loading:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) as! UITableViewCell
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .NoResults:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) as! UITableViewCell
            return cell
        case .NotSearchedYet:
            fatalError("*** You're not supposed to be here.")
        }
    }
}

// MARK: - UITableViewDelegate

extension SearchViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        switch search.state {
        case .NotSearchedYet, .Loading, .NoResults:
            return nil
        case .Results:
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowDetails", sender: indexPath)
    }
}

// MARK: - UISearchBarDelegate

extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        performSearch()
    }
    
    func positionForBar(bar: UIBarPositioning) -> UIBarPosition {
        return .TopAttached
    }
    
    func performSearch() {
        search.performSearchForText(searchBar.text, type: segmentedControl.selectedSegmentIndex, completion: { success in
            if !success {
                println("** performSearchForText error")
            }
            self.tableView.reloadData()
        })
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
}
