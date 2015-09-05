//
//  EditTitleViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 4/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

protocol EditTitleViewControllerDelegate: class {
    func editTitleViewControllerDidCancel(controller: EditTitleViewController)
    func editTitleViewControllerDidFinishEditingMovieTitle(controller: EditTitleViewController, movieTitle: Movie)
}

class EditTitleViewController: UITableViewController {
    
    var movieToBeEdit: Movie?
    var delegate: EditTitleViewControllerDelegate?

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        delegate?.editTitleViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        if let editedMovie = movieToBeEdit {
            delegate?.editTitleViewControllerDidFinishEditingMovieTitle(self, movieTitle: editedMovie)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source / delegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return super.tableView(tableView, numberOfRowsInSection: section)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        if indexPath.section == 1 && indexPath.row == 2 {
            let cell = super.tableView(tableView, cellForRowAtIndexPath: indexPath)
            cell.accessoryType = .None
            return cell
        } else {
        
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }

   
}
