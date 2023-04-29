//
//  LoadableProxy.swift
//  cvmedia
//
//  Created by David Muñoz on 28/04/2022.
//

import Foundation
import Combine

public class LoadableProxy: LoadableProxyProtocol, ObservableObject {
    public var className: String { "\(type(of: self))" }

    public var needsSync: Bool { loadable.needsSync }

    private var cancellable: AnyCancellable?
    public weak var loadable: LoadableProtocol! {
        didSet {
            cancellable?.cancel()
             cancellable = loadable.objectWillChange
                .sink { [weak self] in  self?.notifyDataDidChanged() }
        }
    }

    public var state: LoadableState { loadable.state }

    public func syncIfNeeded() {
        guard needsSync else { return }
        doSync()
    }

    public func doSync() {
        loadable.doSync()
    }

    public func notifyDataDidChanged() {
        self.proxyDidChange()
        objectWillChange.send()
    }

    public func notifyDataDidChanged(if shouldNotify: Bool) {
        guard shouldNotify else { return }
        notifyDataDidChanged()
    }

    func proxyDidChange() {}

    // It depends on their model, its not really a loadable.
    public func startSyncing() {
        fatalError()
    }
}
