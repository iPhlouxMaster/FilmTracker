//
//  SearchableExtensions.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 19/09/15.
//  Copyright © 2015 Yunhan Yang. All rights reserved.
//

import UIKit
import CoreSpotlight
import MobileCoreServices

extension Film {
    @available(iOS 9.0, *)
    var searchableAttributeSet: CSSearchableItemAttributeSet {
        let attributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeContent as String)
        if comments != nil {
            attributeSet.contentDescription = comments
        } else if id.integerValue > 0 {
            attributeSet.contentDescription = overview
        } else if id.integerValue < 0 {
            attributeSet.contentDescription = nil
        }
        
        attributeSet.title = title
        attributeSet.displayName = title
        
        attributeSet.keywords = [title, "watch", "movie", "film"]
        
        if genres != nil {
            attributeSet.keywords! += genres as! [String]
        }
        
        if w92Poster != nil {
            attributeSet.thumbnailData = w92Poster
        } else {
            attributeSet.thumbnailData = UIImageJPEGRepresentation(UIImage(named: "no-poster.jpeg")!, 0.7)
        }
        
        return attributeSet
    }
    
    @available(iOS 9.0, *)
    var searchableItem: CSSearchableItem {
        return CSSearchableItem(uniqueIdentifier: id.stringValue, domainIdentifier: movieListDomainID, attributeSet: searchableAttributeSet)
    }
    
    @available(iOS 9.0, *)
    func indexFilmObject() {
        CSSearchableIndex.defaultSearchableIndex().indexSearchableItems([searchableItem]) {
            error in
            if let error = error {
                print("Error indexing film object: \(error.localizedDescription)")
            } else {
                print("*** Index film object successful")
            }
        }
    }
    
    @available(iOS 9.0, *)
    func removeFilmObjectFromIndex() {
        CSSearchableIndex.defaultSearchableIndex().deleteSearchableItemsWithIdentifiers([id.stringValue]) {
            error in
            if let error = error {
                print("*** Error deleting film object: \(error.localizedDescription)")
            } else {
                print("*** Deindex film object successful")
            }
        }
    }
    
}


