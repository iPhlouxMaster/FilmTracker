//
//  DimmingPresentationController.swift
//  FilmTracker
//
//  Created by Yunhan Yang on 4/09/15.
//  Copyright (c) 2015 Yunhan Yang. All rights reserved.
//

import UIKit

class DimmingPresentationController: UIPresentationController {
    override func shouldRemovePresentersView() -> Bool {
        return false
    }
}
