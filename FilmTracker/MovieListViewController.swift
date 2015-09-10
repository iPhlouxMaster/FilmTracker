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
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest()
        
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: self.managedObjectContext)
        fetchRequest.entity = entity
        
        let sortDescriptor1 = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor1]
        
        fetchRequest.fetchBatchSize = 20
        
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext, sectionNameKeyPath: nil, cacheName: "Film")
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    @IBAction func addButtenPressed(sender: UIBarButtonItem) {
        performSegueWithIdentifier("AddMovie", sender: nil)
    }
    
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let fetchRequest = NSFetchRequest()
        let entity = NSEntityDescription.entityForName("Film", inManagedObjectContext: managedObjectContext)
        fetchRequest.entity = entity
        
        var error: NSError?
        let foundObjects = managedObjectContext.executeFetchRequest(fetchRequest, error: &error)
        if foundObjects == nil {
            fatalCoreDataError(error)
            return
        }
        
        performFetch()
        
        var cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
        tableView.rowHeight = 140
    }
    
    func performFetch() {
        var error: NSError?
        if !fetchedResultsController.performFetch(&error) {
            fatalCoreDataError(error)
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "ShowFilmDetail" {
            let controller = segue.destinationViewController as! DetailViewController
            var film = fetchedResultsController.objectAtIndexPath(sender as! NSIndexPath) as! Film
            var movie = Movie()
            film.convertToMovieObject(movie)
            controller.movie = movie
            controller.managedObjectContext = managedObjectContext
        } else if segue.identifier == "AddMovie" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! EditTitleViewController
            var movie = Movie()
            movie.id = Movie.nextMovieID()
            controller.movie = movie
            controller.isEditingMovie = false
            controller.delegate = self
            controller.title = "Add Title"
        }
    }
}

// MARK: - UITableView Delegate / Data Source

extension MovieListViewController: UITableViewDelegate {
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("ShowFilmDetail", sender: indexPath)
    }
}

extension MovieListViewController: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let sectionInfo = fetchedResultsController.sections![section] as! NSFetchedResultsSectionInfo
        return sectionInfo.numberOfObjects
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("SearchResultCell", forIndexPath: indexPath) as! SearchResultCell
        let film = fetchedResultsController.objectAtIndexPath(indexPath) as! Film
        var movie = Movie()
        film.convertToMovieObject(movie)
        cell.configureForSearchResult(movie)
        
        return cell
    }
}

// MARK: - NSFetchedResultsControllerDelegate

extension MovieListViewController: NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerWillChangeContent")
        tableView.beginUpdates()
    }
    
    func controller(controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath?) {
        switch type {
        case .Insert:
            println("*** NSFetchedResultsChangeInsert (object)")
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        case .Delete:
            println("*** NSFetchedResultsChangeDelete (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
        case .Update:
            println("*** NSFetchedResultsChangeUpdate (object)")
            if let cell = tableView.cellForRowAtIndexPath(indexPath!) as? SearchResultCell {
                let film = controller.objectAtIndexPath(indexPath!) as! Film
                var movie = Movie()
                film.convertToMovieObject(movie)
                cell.configureForSearchResult(movie)
            }
        case .Move:
            println("*** NSFetchedResultsChangeMove (object)")
            tableView.deleteRowsAtIndexPaths([indexPath!], withRowAnimation: .Fade)
            tableView.insertRowsAtIndexPaths([newIndexPath!], withRowAnimation: .Fade)
        }
    }
    
//    func controller(controller: NSFetchedResultsController, didChangeSection sectionInfo: NSFetchedResultsSectionInfo, atIndex sectionIndex: Int, forChangeType type: NSFetchedResultsChangeType) {
//        switch type {
//        case .Insert:
//            println("*** NSFetchedResultsChangeInsert (section)")
//            tableView.insertSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Delete:
//            println("*** NSFetchedResultsChangeDelete (section)")
//            tableView.deleteSections(NSIndexSet(index: sectionIndex), withRowAnimation: .Fade)
//        case .Update:
//            println("*** NSFetchedResultsChangeUpdate (section)")
//        case .Move:
//            println("*** NSFetchedResultsChangeMove (section)")
//        }
//    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        println("*** controllerDidChangeContent")
        tableView.endUpdates()
    }
}

extension MovieListViewController: EditTitleViewControllerDelegate {
    func editTitleViewControllerDidCancel(controller: EditTitleViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editTitleViewControllerDidFinishEditingMovieTitle(controller: EditTitleViewController, movieTitle: Movie) {
        var film = NSEntityDescription.insertNewObjectForEntityForName("Film", inManagedObjectContext: managedObjectContext) as! Film
        
        movieTitle.convertToFilmObject(film)
        movieTitle.film = film
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
        dismissViewControllerAnimated(true, completion: nil)
    }
}

