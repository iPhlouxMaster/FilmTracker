//
//  DetailViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit
import CoreData

class DetailViewController: UIViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    var movie: Movie!
    var imageDownloadTask: NSURLSessionDownloadTask?
    var observer: AnyObject!
    
    //MARK: - IBOutlets
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var productionCountriesLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yourRatingLabel: UILabel!
    @IBOutlet weak var tmdbRatingLabel: UILabel!
    @IBOutlet weak var tmdbRatingTitleLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var overviewTitleLabel: UILabel!
    @IBOutlet weak var tmdbRatingView: FloatRatingView!
    @IBOutlet weak var yourRatingView: FloatRatingView!
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveTitleButton: UIButton!
    @IBOutlet weak var showTMDBPageButton: UIButton!
    @IBOutlet weak var showIMDBPageButton: UIButton!
    @IBOutlet weak var editTitleButton: UIButton!
    @IBOutlet weak var watchStatusLabel: UILabel!
    
    
    //MARK: - IBActions
    
    @IBAction func showTMDBButtonPressed(sender: UIButton) {
        let url = NSURL(string: String(format: "https://www.themoviedb.org/movie/%d", movie.id))
        UIApplication.sharedApplication().openURL(url!)
    }
    
    @IBAction func showIMDBButtonPressed(sender: UIButton) {
        if let imdbID = movie.imdbID {
            let url = NSURL(string: String(format: "http://www.imdb.com/title/%@", imdbID))
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    @IBAction func saveTitleButtonPressed(sender: UIButton) {
        showWatchStatusMenu()
    }
    
    @IBAction func editTitleButtonPressed(sender: UIButton) {
        performSegueWithIdentifier("EditTitle", sender: nil)
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    // MARK: - KVO
    
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
    
    // MARK: - Funcs
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        listenForBackgroundNotification()
        
        let swipeDownGestureRecognizer = UISwipeGestureRecognizer(target: self, action: Selector("closeButtonPressed:"))
        swipeDownGestureRecognizer.direction = UISwipeGestureRecognizerDirection.Down
        view.addGestureRecognizer(swipeDownGestureRecognizer)
        
        configureFloatRatingView()
        configureButtons()
        configureView()
        handleCountrieAndGenreList()
    }
    
    deinit {
        imageDownloadTask?.cancel()
        NSNotificationCenter.defaultCenter().removeObserver(observer)
        println("*** DetailViewController deinited")
    }
    
    func configureView() {
        if let posterAddress = movie.posterAddress {
            if let image = movie.w300Poster {
                posterImageView.image = image
            } else {
                imageDownloadTask = posterImageView.loadImageWithMovieObject(movie, imageSize: Movie.ImageSize.w300)
            }
        } else {
            posterImageView.image = UIImage(named: "no-poster.jpeg")
        }
        
        titleLabel.text = movie.title
        
        if let directors = movie.directors {
            directorLabel.text = ", ".join(directors)
        } else {
            directorLabel.text = "Not Available"
        }
        
        if let countries = movie.productionCountries {
            productionCountriesLabel.text = ", ".join(countries)
        } else {
            productionCountriesLabel.text = "Not Available"
        }
        
        if let releaseDate = movie.releaseDate {
            releaseDateLabel.text = movie.convertDateToString(releaseDate)
        } else {
            releaseDateLabel.text = "Not Available"
        }
        
        if let tmdbRating = movie.tmdbRating {
            tmdbRatingView.rating = tmdbRating
        } else {
            tmdbRatingView.rating = 0.0
        }
        
        if let yourRating = movie.yourRating {
            yourRatingView.rating = yourRating
        } else {
            yourRatingView.rating = 0.0
        }
        
        if let genres = movie.genres {
            genresLabel.text = ", ".join(genres)
        } else {
            genresLabel.text = "Not Available"
        }
        
        if let film = movie.film {
            switch movie.watchStatus {
            case .watching:
                watchStatusLabel.text = "Watching"
            case .watched:
                watchStatusLabel.text = String(format: "Watched on %@", movie.convertDateToString(movie.watchedDate!))
            case .wantToWatch:
                watchStatusLabel.text = "Want to watch"
            default:
                watchStatusLabel.hidden = true
            }
        } else {
            watchStatusLabel.hidden = true
        }
        
        overviewTextView.scrollRangeToVisible(NSMakeRange(0, 1))
        
        if movie.id > 0 {
            overviewTextView.text = movie.overview
        } else {
            overviewTitleLabel.text = "Comments:"
            overviewTextView.text = movie.comments
        }
        
    }
    
    func configureFloatRatingView() {
        if movie.id > 0 {
            tmdbRatingView.delegate = self
            tmdbRatingView.emptyImage = UIImage(named: "StarEmpty")
            tmdbRatingView.fullImage = UIImage(named: "StarFull")
            tmdbRatingView.contentMode = UIViewContentMode.ScaleAspectFit
            tmdbRatingView.maxRating = 10
            tmdbRatingView.minRating = 1
            tmdbRatingView.editable = false
            tmdbRatingView.floatRatings = true
            if let tmdbRating = movie.tmdbRating {
                tmdbRatingLabel.text = String(format: "%.1f/10.0", tmdbRating)
            } else {
                tmdbRatingLabel.text = "0.0/10.0"
            }
        } else {
            tmdbRatingLabel.hidden = true
            tmdbRatingView.hidden = true
            tmdbRatingTitleLabel.hidden = true
        }
        
        yourRatingView.delegate = self
        yourRatingView.emptyImage = UIImage(named: "StarEmpty")
        yourRatingView.fullImage = UIImage(named: "StarFull")
        yourRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        yourRatingView.maxRating = 10
        yourRatingView.minRating = 1
        yourRatingView.editable = true
        yourRatingView.floatRatings = true
        if let yourRating = movie.yourRating {
            yourRatingLabel.text = String(format: "%.1f/10.0", yourRating)
        } else {
            yourRatingLabel.text = "0.0/10.0"
        }
        
    }
    
    func configureButtons() {
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.borderWidth = 0.7
        closeButton.layer.cornerRadius = 5
        
        if movie.film != nil {
            saveTitleButton.hidden = true
        } else {
            saveTitleButton.backgroundColor = UIColor.clearColor()
            saveTitleButton.layer.borderColor = UIColor.whiteColor().CGColor
            saveTitleButton.layer.borderWidth = 0.7
            saveTitleButton.layer.cornerRadius = 5
        }
        
        editTitleButton.backgroundColor = UIColor.clearColor()
        editTitleButton.layer.borderColor = UIColor.whiteColor().CGColor
        editTitleButton.layer.borderWidth = 0.7
        editTitleButton.layer.cornerRadius = 5
        
        if let film = movie.film {
            if movie.id > 0 {
                showTMDBPageButton.hidden = false
                showTMDBPageButton.backgroundColor = UIColor.clearColor()
                showTMDBPageButton.layer.borderColor = UIColor.whiteColor().CGColor
                showTMDBPageButton.layer.borderWidth = 0.7
                showTMDBPageButton.layer.cornerRadius = 5
            }
            
            if movie.imdbID == nil {
                showIMDBPageButton.hidden = true
            } else {
                showIMDBPageButton.hidden = false
                showIMDBPageButton.backgroundColor = UIColor.clearColor()
                showIMDBPageButton.layer.borderColor = UIColor.whiteColor().CGColor
                showIMDBPageButton.layer.borderWidth = 0.7
                showIMDBPageButton.layer.cornerRadius = 5
            }
        }

    }
    
    func showWatchStatusMenu() {
        let alertController = UIAlertController(title: "Please Select Your Watch Status:", message: nil, preferredStyle: .ActionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .Cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        let selectWantToWatchAction = UIAlertAction(title: "I wanna watch", style: .Default, handler: {
            _ in
            self.movie.watchStatus = .wantToWatch
            self.saveMovieObject(self.movie)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(selectWantToWatchAction)
        
        let selectWatchingAction = UIAlertAction(title: "I'm watching", style: .Default, handler: {
            _ in
            self.movie.watchStatus = .watching
            self.saveMovieObject(self.movie)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(selectWatchingAction)
        
        let selectWatchedAction = UIAlertAction(title: "I've watched", style: .Default, handler: {
            _ in
            self.movie.watchStatus = .watched
            self.movie.watchedDate = NSDate()
            self.saveMovieObject(self.movie)
            self.dismissViewControllerAnimated(true, completion: nil)
        })
        alertController.addAction(selectWatchedAction)
        
        self.presentViewController(alertController, animated: true, completion: nil)
    }
    
    func handleCountrieAndGenreList() {
        
        if movie.id > 0 {
            let userDefaults = NSUserDefaults.standardUserDefaults()
            
            if let genres = movie.genres {
                var genreList = userDefaults.valueForKey("GenreList") as! [String]
                let formerGenresCounter = genreList.count
                for genre in genres {
                    if !contains(genreList, genre) {
                        genreList.append(genre)
                    }
                }
                let newGenresCounter = genreList.count
                if newGenresCounter > formerGenresCounter {
                    userDefaults.setObject(genreList, forKey: "GenreList")
                }
                userDefaults.synchronize()
            }
            
            if let countries = movie.productionCountries {
                var countryList = userDefaults.valueForKey("CountryList") as! [String]
                let formerCountriesCounter = countryList.count
                for country in countries {
                    if !contains(countryList, country) {
                        countryList.append(country)
                    }
                }
                let newCountriesCounter = countryList.count
                if newCountriesCounter > formerCountriesCounter {
                    userDefaults.setObject(countryList, forKey: "CountryList")
                }
                userDefaults.synchronize()
            }
        }
    }
    
    func saveMovieObject(movieToSave: Movie) {
        var film: Film
        
        if let filmToSave = movieToSave.film {
            film = filmToSave
        } else {
            film = NSEntityDescription.insertNewObjectForEntityForName("Film", inManagedObjectContext: managedObjectContext) as! Film
        }
        
        movieToSave.convertToFilmObject(film)
        movieToSave.film = film
        
        var error: NSError?
        if !managedObjectContext.save(&error) {
            fatalCoreDataError(error)
            return
        }
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "EditTitle" {
            let navigationController = segue.destinationViewController as! UINavigationController
            let controller = navigationController.viewControllers[0] as! EditTitleViewController
            controller.movie = movie
            controller.isEditingMovie = true
            controller.delegate = self
        }
    }
}

//MARK: - FloatRatingViewDelegate

extension DetailViewController: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
        movie.yourRating = rating
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}

// MARK: - EditTitleViewControllerDelegate

extension DetailViewController: EditTitleViewControllerDelegate {
    func editTitleViewControllerDidCancel(controller: EditTitleViewController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func editTitleViewControllerDidFinishEditingMovieTitle(controller: EditTitleViewController, movieTitle: Movie) {
        saveMovieObject(movieTitle)
        dismissViewControllerAnimated(true, completion: {
            self.dismissViewControllerAnimated(true, completion: nil)
        })
    }
}