//
//  LoadableProtocol.swift
//  cvmedia
//
//  Created by David Muñoz on 28/04/2022.
//

import Foundation
import Combine

public protocol AnyObservableObject: AnyObject {
    var objectWillChange: ObservableObjectPublisher { get }
}

public protocol LoadableProtocol: AnyObservableObject {
    var className: String { get }

    var state: LoadableState { get }
    // This var is intended to prevent us to syncing many times,
    // if we don't believe a loadable needs to sync every time.
    // This var also is intended to be overwritten,
    // if we desired to have a custom criteria in order to sync.

    // EG: in a loadable that has an array of Items we could override this to make it
    // needsSync { items.isEmpty }
    /// Var to control if needs to sync, logic starts with `state != .didSuccess`
    var needsSync: Bool { get }

    func syncIfNeeded()
    /// Try to sync no matter what.
    func doSync()

    /// Notifies subscribers when a change has made to the loadable.
    func notifyDataDidChanged()

    /// Only notifies subscribers if the condition is pleased.
    func notifyDataDidChanged(if shouldNotify: Bool)

    // Not sure about this one, but its good to have all logic together,
    // if we need to do multiple things when this event happens
    func startSyncing()
}
