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
    weak var delegate: EditTitleViewControllerDelegate?
    var isEditingReleaseDate = false
    var isEditingWatchStatus = false
    var isEditingWatchedDate = false
    let pickerData = ["Want to watch", "Watching", "Watched", "None"]
    var isEditingRow = false
    var observer: AnyObject!
    var posterDownloadTask: NSURLSessionDownloadTask?

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
    @IBOutlet weak var commentsTextView: UITextView!

    @IBAction func cancelButtonPressed(sender: UIBarButtonItem) {
        delegate?.editTitleViewControllerDidCancel(self)
    }
    
    @IBAction func doneButtonPressed(sender: UIBarButtonItem) {
        
        if movieToEdit != nil {
            delegate?.editTitleViewControllerDidFinishEditingMovieTitle(self, movieTitle: movieToEdit!)
        }
    }
    
    // MARK: - KVO
    
    func listenForBackgroundNotification() {
        observer = NSNotificationCenter.defaultCenter().addObserverForName(UIApplicationDidEnterBackgroundNotification, object: nil, queue: NSOperationQueue.mainQueue(), usingBlock: {
            [weak self] _ in
            if let strongSelf = self {
                if strongSelf.presentedViewController != nil && !strongSelf.presentedViewController!.isMemberOfClass(UINavigationController) {
                    strongSelf.dismissViewControllerAnimated(false, completion: nil)
                }
                strongSelf.movieTitleTextField.resignFirstResponder()
                strongSelf.directorsTextField.resignFirstResponder()
                strongSelf.commentsTextView.resignFirstResponder()
            }
        })
    }
    
    // MARK: - Funcs
    
    override func viewDidLoad() {
        super.viewDidLoad()
        listenForBackgroundNotification()
        
        commentsTextView.delegate = self
        
        if let movie = movieToEdit {
            configureCellsContent(movie)
        }
        
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: Selector("hideKeyboard:"))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        posterDownloadTask?.cancel()
        println("*** EditTitleViewController deinited")
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
        case (1, 0):
            movieTitleTextField.becomeFirstResponder()
        case (1, 1):
            directorsTextField.becomeFirstResponder()
        case (2, 0):
            commentsTextView.becomeFirstResponder()
        case (0, 0):
            showPhotoMenu()
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
            
            clearReleaseDateAction.backgroundColor = UIColor.grayColor()
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
        
        commentsTextView.text = movie.comments
        
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
    
    func hideKeyboard(gestureRecognizer: UIGestureRecognizer) {
        let point = gestureRecognizer.locationInView(tableView)
        let indexPath = tableView.indexPathForRowAtPoint(point)
        
        if (indexPath != nil && ((indexPath!.section == 0 && indexPath!.row == 1) || (indexPath!.section == 0 && indexPath!.row == 2) || (indexPath!.section == 2 && indexPath!.row == 0))) {
            return
        }
        movieTitleTextField.resignFirstResponder()
        directorsTextField.resignFirstResponder()
        commentsTextView.resignFirstResponder()
    }
    
    // MARK: - Segue
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if let movie = movieToEdit {
            if segue.identifier == "PickGenre" {
                let controller = segue.destinationViewController as! PickerViewController
                controller.genresArray = movie.genres
                controller.delegate = self
            } else if segue.identifier == "PickCountry" {
                let controller = segue.destinationViewController as! PickerViewController
                controller.countriesArray = movie.productionCountries
                controller.delegate = self
            }
        }
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

// MARK: - UIPickerViewDelegate / Data Source

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

//MARK: - UIImagePickerControllerDelegate

extension EditTitleViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func showPhotoMenu() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        
        var alertActionTitle = ""
        
        if let movie = movieToEdit {
            if movie.id > 0 && !movie.posterAddress.isEmpty {
                let onlineRequest = UIAlertAction(title: "Request from TMDB", style: .Default, handler: {
                    _ in
                    self.requestPosterFromTMDB(self.imageView, movie: movie)
                })
                alertController.addAction(onlineRequest)
            }
        }
        
        if imageView.hidden {
            alertActionTitle = "Add from library"
        } else {
            alertActionTitle = "Replace from library"
        }
        
        let takePhotoAction = UIAlertAction(title: "Take Photo", style: .Default, handler: {
            _ in
            self.takePhotoWithCamera()
        })
        alertController.addAction(takePhotoAction)
        
        let pickFromLibraryAction = UIAlertAction(title: alertActionTitle, style: .Default, handler: {
            _ in
            self.choosePhotoFromLibrary()
        })
        alertController.addAction(pickFromLibraryAction)
        
        if !imageView.hidden {
            let deletePosterAction = UIAlertAction(title: "Delete Poster", style: .Default, handler: {
                _ in
                self.tableView.beginUpdates()
                self.imageView.hidden = true
                self.imageView.image = nil
                if let movie = self.movieToEdit {
                    movie.w300Poster = nil
                    movie.w92Poster = nil
                }
                self.tableView.reloadData()
                self.tableView.endUpdates()
            })
            alertController.addAction(deletePosterAction)
        }
            
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func requestPosterFromTMDB(imageView: UIImageView, movie: Movie) {
        posterDownloadTask = imageView.loadImageWithMovieObject(movie, imageSize: Movie.ImageSize.w300)
        if imageView.hidden {
            imageView.hidden = false
            tableView.reloadData()
        }
    }
    
    func takePhotoWithCamera() {
        let imagePicker = UIImagePickerController()
        imagePicker.showsCameraControls = true
        imagePicker.sourceType = .Camera
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func choosePhotoFromLibrary() {
        let imagePicker = UIImagePickerController()
        imagePicker.sourceType = .PhotoLibrary
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        presentViewController(imagePicker, animated: true, completion: nil)
    }
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        // optional because the key may not exist
        imageView.image = info[UIImagePickerControllerEditedImage] as? UIImage
        if let movie = movieToEdit {
            movie.w300Poster = info[UIImagePickerControllerEditedImage] as? UIImage
            movie.w92Poster = movie.w92Poster?.resizedImageWithBounds(CGSize(width: 92, height: 138))
        }
        
        if imageView.hidden == true {
            imageView.hidden = false
        }
        
        dismissViewControllerAnimated(true, completion: nil)
        tableView.reloadData()
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK: - UITextViewDelegate

extension EditTitleViewController: UITextViewDelegate {
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        if let movie = movieToEdit {
            movie.comments = (textView.text as NSString).stringByReplacingCharactersInRange(range, withString: text)
            return true
        } else {
            return false
        }
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        if let movie = movieToEdit {
            movie.comments = commentsTextView.text
        }
    }
}

extension EditTitleViewController: PickerViewControllerDelegate {
    func pickerViewControllerDidPickItems(controller: PickerViewController, items: [String], isPickingCountries: Bool) {
        if isPickingCountries {
            if let movie = movieToEdit {
                movie.productionCountries = items
                countriesLabel.text = ", ".join(movie.productionCountries)
                tableView.reloadData()
            }
        } else {
            if let movie = movieToEdit {
                movie.genres = items
                genreLabel.text = ", ".join(movie.genres)
                tableView.reloadData()
            }
        }
        navigationController!.popViewControllerAnimated(true)
    }
}
