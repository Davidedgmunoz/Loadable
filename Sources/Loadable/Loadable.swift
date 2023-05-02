//
//  Loadable.swift
//
//  Created by David Muñoz on 29/01/2022.
//

import Foundation
import Combine

open class Loadable: LoadableProtocol, ObservableObject {

    public var state: LoadableState = .idle {
        didSet {
            DispatchQueue.global().asyncAfter(deadline: .now()+0.2) {
                self.objectWillChange.send()
            }
        }
    }

    public var className: String { "\(type(of: self))" }

    public var needsSync: Bool { state != .didSuccess }

    public func doSync() { fatalError("Must be overriden") }

    public func notifyDataDidChanged(if shouldNotify: Bool = true) {
        guard shouldNotify else { return }
        notifyDataDidChanged()
    }

    public func syncIfNeeded() {
        guard needsSync else { return }
        doSync()
    }

    public func notifyDataDidChanged() {
        objectWillChange.send()
    }

    public func startSyncing() {
        state = .syncing
    }
}
