//
//  AboutViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 15/09/15.
//  Copyright © 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    let movie = Movie()
    var sidebarMenuOpen = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        revealViewController().delegate = self
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            // Uncomment to change the width of menu
            //self.revealViewController().rearViewRevealWidth = 62
        }
        
        let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
        tableView.registerNib(cellNib, forCellReuseIdentifier: "AboutCell")
        tableView.rowHeight = 140
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "AboutSegue" {
            let controller = segue.destinationViewController as! DetailViewController
            controller.movie = movie
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AboutCell", forIndexPath: indexPath) as! SearchResultCell
        
        movie.w92Poster = UIImage(named: "LaunchScreen")
        movie.w300Poster = UIImage(named: "LaunchScreen")
        movie.title = "Film Tracker"
        movie.productionCountries = ["NZ"]
        movie.directors = ["Yunhan Yang"]
        movie.releaseDate = movie.convertStringToDate("2015-09-15")
        movie.genres = ["Lifestyle"]
        movie.yourRating = 7.0
        movie.comments = "Film Tracker is an app helps to track watched films. Firstly, it searches the movie with movie title or actors / directors. Once selecting the watched movie, the movie will be added to the local database with detailed information retrieved from TMDB."
        
        cell.configureForSearchResult(movie)
        
        return cell
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        performSegueWithIdentifier("AboutSegue", sender: nil)
    }
    
}

// MARK: - SWRevealViewControllerDelegate

extension AboutViewController: SWRevealViewControllerDelegate {
    func revealController(revealController: SWRevealViewController!,  willMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            tableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            tableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
    
    func revealController(revealController: SWRevealViewController!,  didMoveToPosition position: FrontViewPosition){
        if position == FrontViewPosition.Left {
            tableView.userInteractionEnabled = true
            sidebarMenuOpen = false
        } else {
            tableView.userInteractionEnabled = false
            sidebarMenuOpen = true
        }
    }
}
