//
//  LoadableProxy.swift
//
//  Created by David Muñoz on 28/04/2022.
//

import Foundation
import Combine

open class LoadableProxy: LoadableProxyProtocol, ObservableObject {
    
    public var shouldShowError: Bool  {
        get { _shouldShowError || loadable.shouldShowError }
        set { _shouldShowError = newValue }
    }
    
    private var _shouldShowError: Bool = false {
        didSet { notifyDataDidChanged() }
    }

    public var error: Error? { loadable.error }
    

    public init(loadable: LoadableProtocol) {
        self.loadable = loadable
        
    }

    public var className: String { "\(type(of: self))" }

    open var needsSync: Bool { loadable.needsSync }

    private var cancellable: AnyCancellable?
    public var loadable: LoadableProtocol {
        didSet {
            cancellable?.cancel()
             cancellable = loadable.objectWillChange
                .sink { [weak self] in  self?.notifyDataDidChanged() }
            proxyDidChange()
        }
    }

    open var state: LoadableState { loadable.state }

    open func syncIfNeeded() {
        guard needsSync else { return }
        doSync()
    }

    open func doSync() {
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

    open func proxyDidChange() {}

    // It depends on their model, its not really a loadable.
    public func startSyncing() {
        fatalError()
    }
}
