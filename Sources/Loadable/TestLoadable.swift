//
//  TestLoadable.swift
//  Vidgo
//
//  Created by David Muñoz on 27/12/2022.
//

import Foundation
import Combine

open class TestLoadable: LoadableProtocol, ObservableObject {

    public init() {}

    var syncIfNeededCounter: Int = 0
    var syncCounter: Int = 0

    public var className: String { "\(type(of: self))" }
    public var state: LoadableState = .idle
    public var needsSync: Bool = true

    public func syncIfNeeded() {
        syncIfNeededCounter += 1
        doSync()
    }

    public func doSync() {
        syncCounter += 1
        // To override
    }

    public func notifyDataDidChanged() {
        objectWillChange.send()
    }

    public func notifyDataDidChanged(if shouldNotify: Bool) {
        guard shouldNotify else { return }
        notifyDataDidChanged()
    }

    public func startSyncing() {
        state = .syncing
    }

    public func resetCounters() {
        syncIfNeededCounter = 0
        syncCounter = 0
    }
}
