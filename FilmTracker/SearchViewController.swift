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
    
    // Set KVO to monitor if any managedObject changed, fetch the objects for the performSearch() and reload tableView.
    
    var managedObjectContext: NSManagedObjectContext!
    
    let search = Search()
    var films = [Film]()
    var observer: AnyObject!
    var sidebarMenuOpen = false
    
    struct TableViewCellIdentifiers {
        static let searchResultCell = "SearchResultCell"
        static let nothingFoundCell = "NoResultCell"
        static let loadingCell = "LoadingCell"
    }
    
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBAction func segmentValueChanged(sender: AnyObject) {
        performSearch()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        listenForMOCObjectsDidChangeNotification()
        
        title = "Search Title"
        tableView.rowHeight = 140
        searchBar.tintColor = UIColor(red: 141.0 / 255.0, green: 141.0 / 255.0, blue: 141.0 / 255.0, alpha: 1.0)
        searchBar.becomeFirstResponder()
        
        revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            // Uncomment to change the width of menu
            //self.revealViewController().rearViewRevealWidth = 62
        }
        
        var cellNib = UINib(nibName: TableViewCellIdentifiers.searchResultCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.searchResultCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.nothingFoundCell)
        cellNib = UINib(nibName: TableViewCellIdentifiers.loadingCell, bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: TableViewCellIdentifiers.loadingCell)
  
        performFetch()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        print("*** SearchViewController deinited")
    }
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Help methods
    
    func performFetch() {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        let foundObjects: [AnyObject]
        
        do {
            foundObjects = try managedObjectContext.executeFetchRequest(fetchRequest)
        } catch let error as NSError {
            fatalCoreDataError(error)
            return
        }
        
        films = foundObjects as! [Film]
    }
    
    func listenForMOCObjectsDidChangeNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(NSManagedObjectContextObjectsDidChangeNotification, object: nil, queue: NSOperationQueue.mainQueue()) { [weak self]_ in
            if let strongSelf = self {
                strongSelf.performFetch()
                strongSelf.tableView.reloadData()
            }
        }
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
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.loadingCell, forIndexPath: indexPath) 
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            return cell
        case .NoResults:
            let cell = tableView.dequeueReusableCellWithIdentifier(TableViewCellIdentifiers.nothingFoundCell, forIndexPath: indexPath) 
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
        searchBar.resignFirstResponder()
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
        
        // If the film exists, read the film object instead of the movie while they have the save id.
        
        search.performSearchForText(searchBar.text!, type: segmentedControl.selectedSegmentIndex, films: films, completion: { success in
            if !success {
                print("*** performSearchForText error")
            }
            self.tableView.reloadData()
        })
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
            searchBar.performSelector(Selector("resignFirstResponder"), withObject: nil, afterDelay: 0)
        }
    }
}

// MARK: - SWRevealViewControllerDelegate

extension SearchViewController: SWRevealViewControllerDelegate {
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            searchBar.userInteractionEnabled = true
            segmentedControl.userInteractionEnabled = true
            tableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            searchBar.resignFirstResponder()
            searchBar.userInteractionEnabled = false
            segmentedControl.userInteractionEnabled = false
            tableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            searchBar.userInteractionEnabled = true
            segmentedControl.userInteractionEnabled = true
            tableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            searchBar.userInteractionEnabled = false
            segmentedControl.userInteractionEnabled = false
            tableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
}

