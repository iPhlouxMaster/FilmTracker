//
//  MenuViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 13/09/15.
//  Copyright © 2015 Yunhan Yang. All rights reserved.
//

import UIKit

protocol MenuTableViewControllerDelegate: class {
    func menuTableViewController(controller: MenuTableViewController, didSelectRow row: Int)
}

class MenuTableViewController: UITableViewController {
    weak var delegate: MenuTableViewControllerDelegate?
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        delegate?.menuTableViewController(self, didSelectRow: indexPath.row)
    }
}