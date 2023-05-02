//
//  Loadable.swift
//
//  Created by David Muñoz on 29/01/2022.
//

import Foundation
import Combine

public enum LoadableState: Equatable {
    case idle
    case syncing
    case didSuccess
    case didFail

    public static func == (left: LoadableState, right: LoadableState) -> Bool {
        switch (left, right) {
        case (.syncing, .syncing):
            return true
        case (.idle, .idle):
            return true
        case (.didSuccess, .didSuccess):
            return true
        case (.didFail, .didFail):
            return true
        default:
            return false
        }
    }
}
