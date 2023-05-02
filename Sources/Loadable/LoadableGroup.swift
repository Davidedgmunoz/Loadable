//
//  LoadableGroupProtocol.swift
//
//  Created by David Muñoz on 14/06/2022.
//

import Foundation
import Combine

public enum LoadableGroupFailurePolicy {
    /// If one loadable fails, the entire group will considered as failed
    case strict
    /// this never fails whenever a loadable fail within the group,
    /// only fails if every loadable fails
    case never
}

public protocol LoadableGroupProtocol: LoadableProtocol {
    var loadables: [LoadableProtocol] { get }
    var failurePolicy: LoadableGroupFailurePolicy { get set }

    func groupDidChange()
}

// MARK: - Default

public final class LoadableGroup: LoadableGroupProtocol, ObservableObject {
    public var loadables: [LoadableProtocol] = []
    public var failurePolicy: LoadableGroupFailurePolicy
    internal init(
        loadables: [LoadableProtocol],
        failurePolicy: LoadableGroupFailurePolicy = .strict
    ) {
        self.failurePolicy = failurePolicy
        setLoadables(loadables)
    }

    public var state: LoadableState { _state }
    public var _state: LoadableState = .idle

    public var needsSync: Bool { loadables.allSatisfy { !$0.needsSync } }

    public var className: String {
        var loadablesName = ""
        loadables.forEach { loadablesName += "\($0.className)," }
        var loadableGroupName = "LoadableGroup: [\(loadablesName)]"
        return loadableGroupName
    }

    public func syncIfNeeded() {
        loadables.forEach { $0.syncIfNeeded() }
    }

    public func doSync() {
        NSLog("%@: doSync", className)
        loadables.forEach { $0.doSync() }
    }

    public func notifyDataDidChanged() {
        self.objectWillChange.send()
    }

    public func notifyDataDidChanged(if shouldNotify: Bool) {
        guard shouldNotify else { return }
        notifyDataDidChanged()
    }

    public func startSyncing() {
        updateState()
    }

    var cancellables = Set<AnyCancellable>()
    private func setLoadables(_ loadables: [LoadableProtocol]) {
        cancellables.forEach { $0.cancel() }
        let publishers: [ObservableObjectPublisher] = loadables.map { $0.objectWillChange }

        self.loadables = loadables
        Publishers.MergeMany(publishers)
            .sink { [weak self] _ in
                self?.updateState()
            }
            .store(in: &cancellables)
        updateState()
    }

    private func updateState() {
        var failedCount = 0
        var syncedCount = 0
        var syncingCount = 0

        NSLog("%@: updateState", className)

        loadables.forEach {
            switch failurePolicy {
            case .strict:
                if $0.state == .didFail {
                    failedCount += 1
                } else if $0.state == .didSuccess {
                    syncedCount += 1
                } else if $0.state == .syncing {
                    syncingCount += 1
                }
            case .never:
                if $0.state == .didFail || $0.state == .didSuccess {
                    syncedCount += 1
                } else if $0.state == .syncing {
                    syncingCount += 1
                }
            }
        }

        print(
            String(
                format:"%@:  syncingCount: %d, syncedCount: %d,failedCount %d:",
                className, syncingCount, syncedCount, failedCount
            )
        )

        var newLoadableState: LoadableState
        if failedCount > 0 {
            newLoadableState = .didFail
        } else if syncingCount > 0 {
            newLoadableState = .syncing
        } else if syncedCount > 0 && syncedCount == loadables.count {
            newLoadableState = .didSuccess
        } else {
            newLoadableState = .idle
        }

        let stateString = "\(newLoadableState)"
        print(String(format: "%@: newLoadable state: %@", className, stateString))

        if newLoadableState != _state || newLoadableState == .didSuccess {
            print(String(format: "%@: Notifying", className))
            _state = newLoadableState
            notifyDataDidChanged()
            groupDidChange()
        } else {
            print(className + " not notifying")
        }

    }

    public func groupDidChange() {
        // This can be overwritten in case that we want to track each update individually
    }
}
