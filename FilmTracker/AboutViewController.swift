//
//  AboutViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 15/09/15.
//  Copyright © 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class AboutViewController: UITableViewController {

    @IBOutlet weak var menuButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.revealViewController() != nil {
            menuButton.target = self.revealViewController()
            menuButton.action = "revealToggle:"
            self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
            
            let cellNib = UINib(nibName: "SearchResultCell", bundle: nil)
            tableView.registerNib(cellNib, forCellReuseIdentifier: "SearchResultCell")
            tableView.rowHeight = 140
            
            // Uncomment to change the width of menu
            //self.revealViewController().rearViewRevealWidth = 62
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("AboutCell", forIndexPath: indexPath) as! SearchResultCell
        let movie = Movie()
        movie.w92Poster = UIImage(named: "icon")
        movie.title = "Film Tracker"
        movie.directors = ["rivertea"]
        movie.productionCountries = ["NZ", "CN"]
        
        cell.configureForSearchResult(movie)
        
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }
    
}
