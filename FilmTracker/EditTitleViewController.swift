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
    
    var movieToEdit: Movie?
    var delegate: EditTitleViewControllerDelegate?
    var isEditingReleaseDate = false
    var isEditingWatchStatus = false
    var isEditingWatchedDate = false
    let pickerData = ["Want to watch", "Watching", "Watched", "None"]
    var isEditingRow = false

    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var imageLabel: UILabel!
    @IBOutlet weak var movieTitleTextField: UITextField!
    @IBOutlet weak var directorsTextField: UITextField!
    @IBOutlet weak var countriesLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var tmdbFloatRatingView: FloatRatingView!
    @IBOutlet weak var tmdbRatingLabel: UILabel!
    @IBOutlet weak var yourRatingFloatRatingView: FloatRatingView!
    @IBOutlet weak var yourRatingLabel: UILabel!
    @IBOutlet weak var watchStatusLabel: UILabel!
    @IBOutlet weak var watchDateLabel: UILabel!
    @IBOutlet weak var watchedDateTitleLabel: UILabel!
    @IBOutlet weak var commentsTextField: UITextField!

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        delegate?.editTitleViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        if movieToEdit != nil {
            delegate?.editTitleViewControllerDidFinishEditingMovieTitle(self, movieTitle: movieToEdit!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let movie = movieToEdit {
            configureCellsContent(movie)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source / delegate

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 3 {
            if let movie = movieToEdit {
                if movie.id > 0 {
                    return 2
                } else {
                    return 0
                }
            } else {
                return 0
            }
        } else {
            return super.tableView(tableView, numberOfRowsInSection: section)
        }
    }
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        if let movie = movieToEdit {
            if movie.id > 0 {
                return 4
            } else {
                return 3
            }
        } else {
            return 3
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        switch (indexPath.section, indexPath.row) {
        case (1, 3):
            isEditingReleaseDate = !isEditingReleaseDate
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 1)], withRowAnimation: .Fade)
        case (1, 8):
            isEditingWatchStatus = !isEditingWatchStatus
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 9, inSection: 1)], withRowAnimation: .Fade)
        case (1, 10):
            isEditingWatchedDate = !isEditingWatchedDate
            tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 11, inSection: 1)], withRowAnimation: .Fade)
        case (3, 0):
            if let movie = movieToEdit {
                if movie.id > 0 {
                    let url = NSURL(string: String(format: "https://www.themoviedb.org/movie/%d", movie.id))
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
        case (3, 1):
            if let movie = movieToEdit {
                if !movie.imdbID.isEmpty {
                    let url = NSURL(string: String(format: "http://www.imdb.com/title/%@", movie.imdbID))
                    UIApplication.sharedApplication().openURL(url!)
                }
            }
        default:
            tableView.deselectRowAtIndexPath(indexPath, animated: true)
        }
        
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 1 && indexPath.row == 4 && isEditingReleaseDate {
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("ReleaseDatePickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "ReleaseDatePickerCell")
                cell.selectionStyle = .None
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 216))
                datePicker.datePickerMode = .Date
                if let movie = movieToEdit {
                    if !movie.releaseDate.isEmpty {
                        datePicker.date = movie.convertStringToDate(movie.releaseDate)!
                    } else {
                        datePicker.date = NSDate()
                    }
                }
                cell.contentView.addSubview(datePicker)
                datePicker.addTarget(self, action: Selector("releaseDateChanged:"), forControlEvents: .ValueChanged)
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 9 && isEditingWatchStatus {
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("WatchStatusPickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "WatchStatusPickerCell")
                cell.selectionStyle = .None
                let statusPicker = UIPickerView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 150))
                statusPicker.delegate = self
                statusPicker.dataSource = self
                cell.contentView.addSubview(statusPicker)
            }
            return cell
        } else if indexPath.section == 1 && indexPath.row == 11 && isEditingWatchedDate {
            var cell: UITableViewCell! = tableView.dequeueReusableCellWithIdentifier("WatchedDatePickerCell") as? UITableViewCell
            if cell == nil {
                cell = UITableViewCell(style: .Default, reuseIdentifier: "WatchedDatePickerCell")
                cell.selectionStyle = .None
                let datePicker = UIDatePicker(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 216))
                datePicker.datePickerMode = .Date
                if let movie = movieToEdit {
                    datePicker.date = NSDate()
                }
                cell.contentView.addSubview(datePicker)
                datePicker.addTarget(self, action: Selector("watchedDateChanged:"), forControlEvents: .ValueChanged)
            }
            return cell
        } else {
            return super.tableView(tableView, cellForRowAtIndexPath: indexPath)
        }
    }
    
    override func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        switch (indexPath.section, indexPath.row) {
        case (0, 0):
            if imageView.hidden {
                imageLabel.hidden = false
                return 44
            } else {
                imageLabel.hidden = true
                return 320
            }
            
        case (1, 4):
            if isEditingReleaseDate {
                return 216
            } else {
                return 0
            }
        case (1, 9):
            if isEditingWatchStatus {
                return 150
            } else {
                return 0
            }
        case (1, 10):
            if watchStatusLabel.text == "Watched" {
                watchedDateTitleLabel.hidden = false
                watchDateLabel.hidden = false
                let date = NSDate()
                watchDateLabel.text = convertDateToString(date)
                return 44
            } else {
                watchedDateTitleLabel.hidden = true
                watchDateLabel.hidden = true
                if let movie = movieToEdit {
                    movie.watchedDate = nil
                }
                return 0
            }
        case (1, 11):
            if isEditingWatchedDate {
                return 216
            } else {
                return 0
            }
            
        case (2, 0):
            return 132
        default:
            return 44
        }
    }
    
    override func tableView(tableView: UITableView, editingStyleForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCellEditingStyle {
        if indexPath.section == 1 && indexPath.row == 3 {
            return .Delete
        } else {
            return .None
        }
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
    }
    
    override func tableView(tableView: UITableView, editActionsForRowAtIndexPath indexPath: NSIndexPath) -> [AnyObject]? {
        if indexPath.section == 1 && indexPath.row == 3 {
            var clearReleaseDateAction = UITableViewRowAction(style: UITableViewRowActionStyle.Default, title: "Clear") { _ in
                self.editing = false
                self.releaseDateLabel.text = "Tap to add"
                if let movie = self.movieToEdit {
                    movie.releaseDate = ""
                }
                
                if self.isEditingReleaseDate {
                    self.isEditingReleaseDate = false
                    self.tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 4, inSection: 1)], withRowAnimation: .Fade)
                }
            }
            
            
            return [clearReleaseDateAction]
        }
        return nil
    }
    
    // MARK: - Helper methods
    
    func configureCellsContent(movie: Movie) {
        
        if movie.w300Poster != nil {
           imageView.image = movie.w300Poster
        } else {
            imageView.hidden = true
        }
        
        movieTitleTextField.text = movie.title
        
        if !movie.directors.isEmpty {
            directorsTextField.text = ", ".join(movie.directors)
        }
        
        if !movie.productionCountries.isEmpty {
            countriesLabel.text = ", ".join(movie.productionCountries)
        }
        
        if !movie.releaseDate.isEmpty {
            releaseDateLabel.text = movie.releaseDate
        }
        
        if !movie.genres.isEmpty {
            genreLabel.text = ", ".join(movie.genres)
        }
        
        tmdbFloatRatingView.delegate = self
        tmdbFloatRatingView.emptyImage = UIImage(named: "StarEmpty")
        tmdbFloatRatingView.fullImage = UIImage(named: "StarFull")
        tmdbFloatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        tmdbFloatRatingView.maxRating = 10
        tmdbFloatRatingView.minRating = 1
        tmdbFloatRatingView.editable = false
        tmdbFloatRatingView.floatRatings = true
        tmdbFloatRatingView.rating = movie.tmdbRating
        tmdbRatingLabel.text = String(format: "%.1f/10.0", movie.tmdbRating)
        
        yourRatingFloatRatingView.delegate = self
        yourRatingFloatRatingView.emptyImage = UIImage(named: "StarEmpty")
        yourRatingFloatRatingView.fullImage = UIImage(named: "StarFull")
        yourRatingFloatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        yourRatingFloatRatingView.maxRating = 10
        yourRatingFloatRatingView.minRating = 1
        yourRatingFloatRatingView.editable = true
        yourRatingFloatRatingView.floatRatings = true
        yourRatingFloatRatingView.rating = movie.yourRating
        yourRatingLabel.text = String(format: "%.1f/10.0", movie.yourRating)
        
        watchStatusLabel.text = configureWatchStatusLabel(movie.watchStatus)
        
        if movie.watchStatus == .watched {
            watchedDateTitleLabel.hidden = false
            watchDateLabel.hidden = false
        } else {
            watchedDateTitleLabel.hidden = true
            watchDateLabel.hidden = true
        }
        
    }
    
    func configureWatchStatusLabel(status: Movie.Status) -> String {
        switch status {
        case .wantToWatch:
            return pickerData[0]
        case .watching:
            return pickerData[1]
        case .watched:
            return pickerData[2]
        case .other:
            return pickerData[3]
        }
    }
    
    func releaseDateChanged(datePicker: UIDatePicker) {
        if let movie = movieToEdit {
            movie.releaseDate = convertDateToString(datePicker.date)
            releaseDateLabel.text = movie.releaseDate
        }
    }
    
    func watchedDateChanged(datePicker: UIDatePicker) {
        if let movie = movieToEdit {
            movie.watchedDate = datePicker.date
            watchDateLabel.text = convertDateToString(movie.watchedDate!)
        }
    }
    
    func convertDateToString(date: NSDate) -> String {
        let formatter = NSDateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.stringFromDate(date)
    }
}

// MARK: - FloatRatingViewDelegate

extension EditTitleViewController: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
        if movieToEdit != nil {
            movieToEdit!.yourRating = rating
        }
    }
}

extension EditTitleViewController: UIPickerViewDelegate {
    func pickerView(pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String! {
        return pickerData[row]
    }
    
    func pickerView(pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        watchStatusLabel.text = pickerData[row]
        if let movie = movieToEdit {
            switch row {
            case 0:
               movie.watchStatus = .wantToWatch
            case 1:
                movie.watchStatus = .watching
            case 2:
                movie.watchStatus = .watched
            case 3:
                movie.watchStatus = .other
            default:
                break
            }
        }
        tableView.reloadRowsAtIndexPaths([NSIndexPath(forRow: 11, inSection: 1)], withRowAnimation: .Fade)
    }
}

extension EditTitleViewController: UIPickerViewDataSource {
    
    func pickerView(pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return pickerData.count
    }
    
    func numberOfComponentsInPickerView(pickerView: UIPickerView) -> Int {
        return 1
    }
}
