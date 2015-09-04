//
//  DetailViewController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 3/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {
    
    var movie: Movie?
    var imageDownloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var productionCountriesLabel: UILabel!
    @IBOutlet weak var releaseDateLabel: UILabel!
    @IBOutlet weak var genresLabel: UILabel!
    @IBOutlet weak var yourRatingLabel: UILabel!
    @IBOutlet weak var tmdbRatingLabel: UILabel!
    @IBOutlet weak var overviewTextView: UITextView!
    @IBOutlet weak var tmdbRatingView: FloatRatingView!
    @IBOutlet weak var yourRatingView: FloatRatingView!
    
    @IBOutlet weak var closeButton: UIButton!
    @IBOutlet weak var saveTitleButton: UIButton!
    @IBOutlet weak var showIMDBPageButton: UIButton!
    @IBOutlet weak var editTitleButton: UIButton!
    
    @IBAction func showIMDBButtonPressed(sender: UIButton) {
        if !movie!.imdbID.isEmpty {
            let url = NSURL(string: String(format: "http://www.imdb.com/title/%@", movie!.imdbID))
            UIApplication.sharedApplication().openURL(url!)
        }
    }
    
    @IBAction func editTitleButtonPressed(sender: UIButton) {
        
    }

    @IBAction func saveTitleButtonPressed(sender: UIButton) {
        
    }
    
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureFloatRatingView()
        configureButtons()
        configureView()
    }
    
    deinit {
        imageDownloadTask?.cancel()
    }
    
    func configureView() {
        if let image = movie!.w300Poster {
            posterImageView.image = image
        } else {
            imageDownloadTask = posterImageView.loadImageWithMovieObject(movie!, imageSize: 1)
        }
        
        titleLabel.text = movie!.title
        directorLabel.text = ", ".join(movie!.directors)
        productionCountriesLabel.text = ", ".join(movie!.productionCountries)
        releaseDateLabel.text = movie!.releaseDate
        tmdbRatingView.rating = Float(movie!.tmdbRating)
        yourRatingView.rating = Float(movie!.yourRating)
        
        if !movie!.genres.isEmpty {
            genresLabel.text = ", ".join(movie!.genres)
        } else {
            genresLabel.text = "Not Available"
        }
        
        overviewTextView.scrollRangeToVisible(NSMakeRange(0, 1))
        overviewTextView.text = movie!.overview
        
    }
    
    func configureFloatRatingView() {
        tmdbRatingView.delegate = self
        tmdbRatingView.emptyImage = UIImage(named: "StarEmpty")
        tmdbRatingView.fullImage = UIImage(named: "StarFull")
        tmdbRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        tmdbRatingView.maxRating = 10
        tmdbRatingView.minRating = 1
        tmdbRatingView.editable = false
        tmdbRatingView.floatRatings = true
        tmdbRatingLabel.text = String(format: "%.1f/10.0", movie!.tmdbRating)
        
        yourRatingView.delegate = self
        yourRatingView.emptyImage = UIImage(named: "StarEmpty")
        yourRatingView.fullImage = UIImage(named: "StarFull")
        yourRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        yourRatingView.maxRating = 10
        yourRatingView.minRating = 1
        yourRatingView.editable = true
        yourRatingView.floatRatings = true
        yourRatingLabel.text = String(format: "%.1f/10.0", movie!.yourRating)
    }
    
    func configureButtons() {
        closeButton.backgroundColor = UIColor.clearColor()
        closeButton.layer.borderColor = UIColor.whiteColor().CGColor
        closeButton.layer.borderWidth = 1
        closeButton.layer.cornerRadius = 5
        
        saveTitleButton.backgroundColor = UIColor.clearColor()
        saveTitleButton.layer.borderColor = UIColor.whiteColor().CGColor
        saveTitleButton.layer.borderWidth = 1
        saveTitleButton.layer.cornerRadius = 5
        
        editTitleButton.backgroundColor = UIColor.clearColor()
        editTitleButton.layer.borderColor = UIColor.whiteColor().CGColor
        editTitleButton.layer.borderWidth = 1
        editTitleButton.layer.cornerRadius = 5
        
        showIMDBPageButton.backgroundColor = UIColor.clearColor()
        showIMDBPageButton.layer.borderColor = UIColor.whiteColor().CGColor
        showIMDBPageButton.layer.borderWidth = 1
        showIMDBPageButton.layer.cornerRadius = 5
        
        if movie!.imdbID.isEmpty {
            showIMDBPageButton.hidden = true
        }
    }
}

extension DetailViewController: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        yourRatingLabel.text = String(format: "%.1f/10.0", rating)
        movie!.yourRating = Double(rating)
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func presentationControllerForPresentedViewController(presented: UIViewController, presentingViewController presenting: UIViewController!, sourceViewController source: UIViewController) -> UIPresentationController? {
        return DimmingPresentationController(presentedViewController: presented, presentingViewController: presenting)
    }
}
