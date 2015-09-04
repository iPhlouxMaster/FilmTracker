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
    @IBOutlet weak var overViewTextView: UITextView!
    @IBOutlet weak var tmdbRatingView: FloatRatingView!
    @IBOutlet weak var yourRatingView: FloatRatingView!
    @IBAction func saveToListButtonPressed(sender: UIButton) {
        
    }
    @IBAction func closeButtonPressed(sender: UIButton) {
        dismissViewControllerAnimated(true, completion: nil)
    }
    override func viewDidLoad() {
        super.viewDidLoad()
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
        
        overViewTextView.text = movie!.overview
        
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
