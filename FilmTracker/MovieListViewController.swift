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
    var observer: AnyObject!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var sectionNameKeyPathSegmentedControl: UISegmentedControl!
    @IBAction func addButtenPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("AddMovie", sender: nil)
    }
    
    @IBAction func segmentedControlValueChanged(sender: AnyObject) {
        switch sectionNameKeyPathSegmentedControl.selectedSegmentIndex {
        case 0:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("titleSection", withSortDescriptorKey: "title")
        case 1:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("releaseDateSection", withSortDescriptorKey: "releaseDate")
        default:
            fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("yourRatingSection", withSortDescriptorKey: "yourRating")
        }
        performFetch()
        tableView.reloadData()
    }
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil && !strongSelf.presentedViewController!.isMemberOfClass(UINavigationController) {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchedResultsController = createFetchedResultsControllerWithSectionNameKeyPath("watchStatus", withSortDescriptorKey: "watchStatus")
        performFetch()
        
        let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
        tableView.rowHeight = 140
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        print("*** EditTitleViewController deinited")
    }
    
    func createFetchedResultsControllerWithSectionNameKeyPath(sectionNameKeyPath: String, withSortDescriptorKey: String) -> NSFetchedResultsController {
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        let sortDescriptor1 = NSSortDescriptor(key: withSortDescriptorKey, ascending: true)
        let sortDescriptor2 = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1, sortDescriptor2]
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
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowFilmDetail", sender: indexPath)
    }
    
    func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [UITableViewRowAction]? {
        let editMovieAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Edit") { _ in
            self.performSegueWithIdentifier("EditMovie", sender: indexPath)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        editMovieAction.backgroundColor = UIColor.lightGrayColor()
        
        let deleteMovieAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Delete") { _ in
            self.managedObjectContext.deleteObject(self.fetchedResultsController.objectAtIndexPath(indexPath) as! Film)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        deleteMovieAction.backgroundColor = UIColor.redColor()
        
        let changeMovieStatusAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Status") { _ in
            let film = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Film
            self.showWatchStatusMenu(film)
            self.tableView.reloadRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        }
        
        changeMovieStatusAction.backgroundColor = UIColor.greenColor()
        
        return [deleteMovieAction, editMovieAction, changeMovieStatusAction]
        
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let sectionInfo = fetchedResultsController.sections![section] 
        return sectionInfo.name
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return fetchedResultsController.sections!.count
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section]
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        let film = fetchedResultsController.objectAtIndexPath(indexPath) as! Film
        let movie = Movie()
        film.convertToMovieObject(movie)
        cell.configureForSearchResult(movie)
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MovieListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        print("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
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
                let film = controller.objectAtIndexPath(indexPath!) as! Film
                let movie = Movie()
                film.convertToMovieObject(movie)
                cell.configureForSearchResult(movie)
            }
            tableView.reloadRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
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
        
        if movieTitle.film == nil {
            film = NSEntityDescription.insertNewObjectForEntityForName("Film", inManagedObjectContext: managedObjectContext) as! Film
        } else {
            film = movieTitle.film!
        }
        
        movieTitle.convertToFilmObject(film)
        
        dismissViewControllerAnimated(true, completion: nil)
    }
}

