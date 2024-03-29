//
//  SearchResultCell.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 2/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class SearchResultCell: UITableViewCell {

    var imageDownloadTask: NSURLSessionDownloadTask?
    var directorDownloadTask: NSURLSessionDownloadTask?
    var productionCountriesDownloadTask: NSURLSessionDownloadTask?
    
    @IBOutlet weak var movieTitleLabel: UILabel!
    @IBOutlet weak var productionCountriesLabel: UILabel!
    @IBOutlet weak var directorLabel: UILabel!
    @IBOutlet weak var posterImageView: UIImageView!
    @IBOutlet weak var floatRatingView: FloatRatingView!
    @IBOutlet weak var watchStatusLabel: UILabel!
    @IBOutlet weak var rateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        watchStatusLabel.transform = CGAffineTransformMakeRotation(CGFloat(-M_PI_2))
        
        floatRatingView.emptyImage = UIImage(named: "StarEmpty")
        floatRatingView.fullImage = UIImage(named: "StarFull")

        floatRatingView.delegate = self
        floatRatingView.contentMode = UIViewContentMode.ScaleAspectFit
        floatRatingView.maxRating = 10
        floatRatingView.minRating = 1
        floatRatingView.editable = false
        floatRatingView.halfRatings = true
        floatRatingView.floatRatings = true
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    func configureForSearchResult(movie: Movie) {
        movieTitleLabel.text = movie.title
        
        if movie.id > 0 {
            if let yourRating = movie.yourRating {
                rateLabel.text = "Your Rate:"
                floatRatingView.rating = yourRating
            } else if let tmdbRating = movie.tmdbRating {
                floatRatingView.rating = tmdbRating
                rateLabel.text = "TMDB Rate:"
            }
        } else if movie.id <= 0 {
            rateLabel.text = "Your Rate:"
            if let yourRating = movie.yourRating {
                floatRatingView.rating = yourRating
            } else {
                floatRatingView.rating = 0.0
            }
        }
    
        if let directors = movie.directors {
            if directors.isEmpty {
                directorLabel.text = "Not Available"
            } else {
                directorLabel.text = directors.joinWithSeparator(", ")
            }
        } else {
            if movie.id > 0 && movie.film == nil {
                directorDownloadTask = directorLabel.loadCreditsWithMovieObject(movie)
            } else {
                directorLabel.text = "Not Available"
            }
        }
        
        if let countries = movie.productionCountries {
            if countries.isEmpty {
                productionCountriesLabel.text = "Not Available"
            } else {
                productionCountriesLabel.text = countries.joinWithSeparator(", ")
            }
        } else {
            if movie.id > 0 && movie.film == nil {
                productionCountriesDownloadTask = productionCountriesLabel.loadDetailsWithMovieObject(movie)
            } else {
                productionCountriesLabel.text = "Not Available"
            }
        }
        
        if let image = movie.w92Poster {
            posterImageView.image = image
        } else {
            if movie.posterAddress != nil && movie.film == nil {
                imageDownloadTask = posterImageView.loadImageWithMovieObject(movie, imageSize: Movie.ImageSize.w92)
            } else {
                posterImageView.image = UIImage(named: "no-poster.jpeg")
            }
        }
        
        if movie.film != nil || movie.id == 0 {
            switch movie.watchStatus {
            case .wantToWatch:
                watchStatusLabel.hidden = false
                watchStatusLabel.text = "Wanna See"
                watchStatusLabel.font = UIFont.boldSystemFontOfSize(18.0)
            case .watched:
                watchStatusLabel.hidden = false
                watchStatusLabel.text = "Watched"
                watchStatusLabel.font = UIFont.boldSystemFontOfSize(21.0)
            case .watching:
                watchStatusLabel.hidden = false
                watchStatusLabel.text = "Watching"
                watchStatusLabel.font = UIFont.boldSystemFontOfSize(21.0)
            default:
                watchStatusLabel.hidden = true
            }
        } else {
            watchStatusLabel.hidden = true
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageDownloadTask?.cancel()
        directorDownloadTask?.cancel()
        productionCountriesDownloadTask?.cancel()
        
        movieTitleLabel.text = nil
        productionCountriesLabel.text = nil
        directorLabel.text = nil
        watchStatusLabel.text = nil
        posterImageView.image = nil
        floatRatingView.delegate = nil
    }
    
}

// MARK: - FloatRatingViewDelegate

extension SearchResultCell: FloatRatingViewDelegate {
    func floatRatingView(ratingView: FloatRatingView, isUpdating rating:Float) {
        
    }
    
    func floatRatingView(ratingView: FloatRatingView, didUpdate rating: Float) {
        // floatRatingView.rating = rating
    }

}
