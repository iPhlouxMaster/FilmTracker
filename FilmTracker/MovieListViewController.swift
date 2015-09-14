//
//  MovieListViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit
import CoreData

class MovieListViewController: UIViewController {
    
    
    var managedObjectContext: NSManagedObjectContext!
    var fetchedResultsController: NSFetchedResultsController!
    var searchController: UISearchController!
    var searchPredicate: NSPredicate?
    var filteredObjects : [Film]? = nil
    var sidebarMenuOpen = false
    
    @IBOutlet weak var searchBarView: UIView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sectionNameKeyPathSegmentedControl: UISegmentedControl!
    
    @IBAction func addButtenPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("AddMovie", sender: nil)
    }

    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        fetchedResultsController = nil
        
        switch sectionNameKeyPathSegmentedControl.selectedSegmentIndex {
        case 0:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("titleSection", withSortDescriptorKey: "title")
        case 1:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("watchStatusSection", withSortDescriptorKey: "watchStatus")
        case 2:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("yourRatingSection", withSortDescriptorKey: "yourRating")
        case 3:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("releaseDateSection", withSortDescriptorKey: "releaseDate")
        default:
            return
        }
        
        performFetch()
        
        tableView.reloadData()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        searchBarView.addSubview(searchController.searchBar)
        searchController.searchBar.frame = CGRectMake(0, 0, searchBarView.bounds.size.width, 44)
        searchController.searchBar.tintColor = view.tintColor
        searchController.searchBar.placeholder = "Search film title..."
        searchController.searchBar.barTintColor = UIColor.lightGrayColor()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Film List"
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            // Uncomment to change the width of menu
            //self.revealViewController().rearViewRevealWidth = 62
        }
        
        revealViewController().delegate = self
        
        fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("titleSection", withSortDescriptorKey: "title")
        performFetch()
        
        tableView.sectionIndexBackgroundColor = UIColor.clearColor()

        searchController = UISearchController(searchResultsController: nil)
        searchController.dimsBackgroundDuringPresentation = false
        searchController.hidesNavigationBarDuringPresentation = false
        searchController.searchResultsUpdater = self
        searchController.delegate = self
        definesPresentationContext = true
        
        let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
        tableView.rowHeight = 140
    }
    
    deinit {
        NSFetchedResultsController.deleteCacheWithName("Film")
        print("*** MovieListViewController deinited")
    }
    
    func createFetchedResultsControllerWithSectionNameKeyPath(sectionNameKeyPath: String, withSortDescriptorKey: String) -> NSFetchedResultsController {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor1 = NSSortDescriptor(key: withSortDescriptorKey, ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
        fetchRequest.predicate = nil
        fetchRequest.fetchBatchSize = 20
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: sectionNameKeyPath, cacheName: "Film")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }
    
    func performFetch() {
        do {
            try fetchedResultsController.performFetch()
        } catch let error as NSError {
            fatalCoreDataError(error)
        }
    }
    
    func showWatchStatusMenu(film: Film) {
        let alertController = UIAlertController(title: "Choose Your Watch Status:", message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.view.tintColor = view.tintColor
        alertController.addAction(cancelAction)
        
        let selectWantToWatchAction = UIAlertAction(title: "I wanna watch", style: .Default, handler: {
            _ in
            film.watchStatus = Movie.Status.wantToWatch.rawValue
            if film.watchedDate != nil {
                film.watchedDate = nil
            }
            self.tableView.reloadData()
        })
        
        let selectWatchingAction = UIAlertAction(title: "I'm watching", style: .Default, handler: {
            _ in
            film.watchStatus = Movie.Status.watching.rawValue
            if film.watchedDate != nil {
                film.watchedDate = nil
            }
            self.tableView.reloadData()
        })
        
        
        let selectWatchedAction = UIAlertAction(title: "I've watched", style: .Default, handler: {
            _ in
            film.watchStatus = Movie.Status.watched.rawValue
            film.watchedDate = NSDate()
            self.tableView.reloadData()
        })
        
        switch film.watchStatus {
        case Movie.Status.wantToWatch.rawValue:
            alertController.addAction(selectWatchingAction)
            alertController.addAction(selectWatchedAction)
        case Movie.Status.watched.rawValue:
            alertController.addAction(selectWantToWatchAction)
            alertController.addAction(selectWatchingAction)
        case Movie.Status.watching.rawValue:
            alertController.addAction(selectWantToWatchAction)
            alertController.addAction(selectWatchedAction)
        default:
            alertController.addAction(selectWantToWatchAction)
            alertController.addAction(selectWatchingAction)
            alertController.addAction(selectWatchedAction)
        }
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func saveFilmObject() {
        do {
            try managedObjectContext.save()
            print("*** managedObjectContext saved")
        } catch let error as NSError {
            fatalCoreDataError(error)
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowFilmDetail" {
            let controller = segue.destinationViewController as! DetailViewController
            let film = fetchedResultsController.objectAtIndexPath(sender as! NSIndexPath) as! Film
            let movie = Movie()
            film.convertToMovieObject(movie)
            controller.movie = movie
            controller.managedObjectContext = managedObjectContext
        } else if segue.identifier == "AddMovie" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! EditTitleViewController
            let movie = Movie()
            movie.id = Movie.nextMovieID()
            controller.movie = movie
            controller.isEditingMovie = false
            controller.delegate = self
            controller.title = "Add Title"
        } else if segue.identifier == "EditMovie" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! EditTitleViewController
            let film = fetchedResultsController.objectAtIndexPath(sender as! NSIndexPath) as! Film
            let movie = Movie()
            film.convertToMovieObject(movie)
            controller.movie = movie
            controller.isEditingMovie = true
            controller.delegate = self
        }
    }
}

// MARK: - UITableView Delegate / Data Source

extension MovieListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, willSelectRowAtIndexPath indexPath: NSIndexPath) -> NSIndexPath? {
        if sidebarMenuOpen == true {
            return nil
        } else {
            return indexPath
        }
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        searchController.searchBar.resignFirstResponder()
        performSegueWithIdentifier("ShowFilmDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editMovieAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: " Edit ") { _ in
            self.performSegueWithIdentifier("EditMovie", sender: indexPath)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        editMovieAction.backgroundColor = UIColor.grayColor()
        
        let deleteMovieAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { _ in
            if self.searchPredicate == nil {
                self.managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Film)
            } else {
                self.managedObjectContext.deleteObject(self.filteredObjects![indexPath.row])
                self.filteredObjects!.removeAtIndex(indexPath.row)
            }
            // self.tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        deleteMovieAction.backgroundColor = UIColor.blackColor()
        
        let changeMovieStatusAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Status") { _ in
            let film = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Film
            self.showWatchStatusMenu(film)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        changeMovieStatusAction.backgroundColor = UIColor.lightGrayColor()
        
        return [deleteMovieAction, editMovieAction, changeMovieStatusAction]
        
    }
    
}

extension MovieListViewController: UITableViewDataSource {
    
    func sectionIndexTitlesForTableView(tableView: UITableView) -> [String]? {
        if searchPredicate == nil {
            switch sectionNameKeyPathSegmentedControl.selectedSegmentIndex {
            case 0:
                return Constants.titleIndex
            case 1:
                return Constants.statusIndex
            case 2:
                return Constants.ratingIndex
            case 3:
                return Constants.yearIndex
            default:
                return nil
            }
        } else {
            return nil
        }
    }
    
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if searchPredicate == nil {
            let sectionInfo = fetchedResultsController.sections?[section]
            return sectionInfo?.name
        } else {
            return nil
        }
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if searchPredicate == nil {
            return fetchedResultsController.sections?.count ?? 0
        } else {
            return filteredObjects?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searchPredicate == nil {
            let sectionInfo = fetchedResultsController.sections![section]
            return sectionInfo.numberOfObjects
        } else {
            return filteredObjects?.count ?? 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        var film: Film
        if searchPredicate == nil {
            film = fetchedResultsController.objectAtIndexPath(indexPath) as! Film
        } else {
            film = filteredObjects![indexPath.row]
        }
        let movie = Movie()
        film.convertToMovieObject(movie)
        cell.configureForSearchResult(movie)

        return cell
    }
    
    func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        if searchPredicate == nil {
            return true
        } else {
            return false
        }
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MovieListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        var tableView = UITableView()
        
        if searchPredicate == nil {
            tableView = self.tableView
        } else {
            tableView  = (searchController.searchResultsUpdater as! MovieListViewController).tableView
        }
        
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (object)")
            self.saveFilmObject()
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (object)")
            self.saveFilmObject()
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (object)")
            self.saveFilmObject()
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? SearchResultCell {
                if searchPredicate == nil {
                    let film = controller.objectAtIndexPath(indexPath!) as! Film
                    let movie = Movie()
                    film.convertToMovieObject(movie)
                    cell.configureForSearchResult(movie)
                } else {
                    if filteredObjects?.count > 0 {
                        let film = filteredObjects![indexPath!.row]
                        let movie = Movie()
                        film.convertToMovieObject(movie)
                        cell.configureForSearchResult(movie)
                    }
                }
                // tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            }
        case .Move:
            print("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
        switch type {
        case .Insert:
            print("*** NSFetchedResultsChangeInsert (section)")
            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Delete:
            print("*** NSFetchedResultsChangeDelete (section)")
            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
        case .Update:
            print("*** NSFetchedResultsChangeUpdate (section)")
        case .Move:
            print("*** NSFetchedResultsChangeMove (section)")
        }
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerDidChangeContent")
        tableView.reloadData()
        tableView.endUpdates()
    }
}

// MARK: - EditTitleViewControllerDelegate

extension MovieListViewController: EditTitleViewControllerDelegate {
    func editTitleViewControllerDidCancel(controller: EditTitleViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editTitleViewControllerDidFinishEditingMovieTitle(controller: EditTitleViewController, movieTitle: Movie) {
        var film: Film
        var hudView: HudView
        
        if movieTitle.film == nil {
            hudView = HudView.hudInView(controller.navigationController!.view, animated: true)
            hudView.text = "Added"
            film = NSEntityDescription.insertNewObjectForEntityForName("Film", inManagedObjectContext: managedObjectContext) as! Film
        } else {
            hudView = HudView.hudInView(controller.navigationController!.view, animated: true)
            hudView.text = "Edited"
            film = movieTitle.film!
        }
        
        movieTitle.convertToFilmObject(film)
        
        hudView.afterDelay(0.8, closure: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}

// MARK: - UISearchResultsUpdating

extension MovieListViewController: UISearchResultsUpdating {
    func updateSearchResultsForSearchController(searchController: UISearchController) {
        let searchText = self.searchController?.searchBar.text
        if let searchText = searchText {
            searchPredicate = NSPredicate(format: "title contains[c] %@", searchText)
            filteredObjects = fetchedResultsController.fetchedObjects!.filter() {
                return self.searchPredicate!.evaluateWithObject($0)
            } as? [Film]
            self.tableView.reloadData()
        }
    }
}

extension MovieListViewController: UISearchControllerDelegate {
    func didDismissSearchController(searchController: UISearchController) {
        searchPredicate = nil
        filteredObjects = nil
        tableView.reloadData()
    }
}

// MARK: - SWRevealViewControllerDelegate

extension MovieListViewController: SWRevealViewControllerDelegate {
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            searchController.searchBar.userInteractionEnabled = true
            tableView.userInteractionEnabled = true
            sectionNameKeyPathSegmentedControl.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            // searchController.searchBar.resignFirstResponder()
            searchController.searchBar.userInteractionEnabled = false
            sectionNameKeyPathSegmentedControl.userInteractionEnabled = false
            tableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            searchController.searchBar.userInteractionEnabled = true
            tableView.userInteractionEnabled = true
            sectionNameKeyPathSegmentedControl.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            searchController.searchBar.userInteractionEnabled = false
            tableView.userInteractionEnabled = false
            sectionNameKeyPathSegmentedControl.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
}

