//
//  ThemeManager.swift
//  ttPong
//
//  Created by Raul Costa Junior on 23.05.21.
//  Copyright © 2021 Raul Costa Junior. All rights reserved.
//

import Foundation

/**
 Responsabilities:

 + Keep track of current active theme set;
 + Allow switching active theme set;
 + Keep track of each theme set of resources.

 */
class ThemeManager {

    // MARK: - Singleton Support

    static let shared = ThemeManager()

    private init() {
        // TODO: load current active theme set from UserDefaults.
    }

}
