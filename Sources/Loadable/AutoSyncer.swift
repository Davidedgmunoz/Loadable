//
//  AutoSyncer.swift
//  Vidgo
//
//  Created by David Muñoz on 29/07/2022.
//

import Foundation
import UIKit

public protocol AutoSyncer: AnyObject {
    func stop()
}

public final class DefaultAutoSyncer: AutoSyncer {
    private var className: String { "\(type(of: self))" }

    private let loadableToSync: LoadableProtocol
    private let repeatTime: Int
    private let startDelay: Int

    public init(
        loadableToSync: LoadableProtocol,
        startSyncingAfter delay: Int,
        // nil means there is no repetition
        every repeatingTimeInSeconds: Int?
    ) {
        self.loadableToSync = loadableToSync
        self.startDelay = delay
        if let repeatingTimeInSeconds = repeatingTimeInSeconds {
            repeatTime = repeatingTimeInSeconds
        } else {
            repeatTime = 0
        }
        setupDidBecomeActiveObserver()
        startAutoSyncing(after: delay)
    }

    deinit {
        NSLog("%@ deinit", className)
        stop()
    }

    // We will use this lastUpdateDate to track when the last update was made,
    // so in case app goes to foreground, when coming back to be in foreground
    private var lastUpdateDate: Date?

    private var autoSyncingTimer: Timer?
    private var startAutoSyncingTimer: Timer?

    public func stop() {
        NSLog("%@ stopped", className)
        stopSyncingTimer()
        stopStartAutoSyncingTimer()
        removeDidBecomeActiveObserver()
    }

    private func startAutoSyncing(after delay: Int) {
        guard startAutoSyncingTimer == nil else { return }
        NSLog("%@: startingAutoSyncingTimer in: %d seconds", className, startDelay)

        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.startAutoSyncingTimer = Timer.scheduledTimer(
                timeInterval: TimeInterval(delay),
                target: self,
                selector: #selector(self.startSyncing),
                userInfo: nil, repeats: false
            )
        }
    }

    private func stopStartAutoSyncingTimer() {
        startAutoSyncingTimer?.invalidate()
        startAutoSyncingTimer = nil
    }

    private func setupDidBecomeActiveObserver() {
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(didBecomeActive),
            name: UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    private func removeDidBecomeActiveObserver() {
        NotificationCenter.default.removeObserver(
            self,
            name:  UIApplication.didBecomeActiveNotification,
            object: nil
        )
    }

    @objc private func didBecomeActive() {
        let nowDate = Date()

        // We check if the auto start time already finished
        guard startAutoSyncingTimer == nil else {
            return
        }

        guard let lastUpdateDate = lastUpdateDate else {
            sync()
            return
        }

//        if lastUpdateDate.minutesOfDifference(to: nowDate) > repeatTime/60 {
//            sync()
//        }
    }

    @objc private func startSyncing() {
        NSLog("%@: Starting to sync", className)

        stopStartAutoSyncingTimer()

        // we check if we need to repeat, if not we just sync and return
        guard repeatTime != 0 else {
            sync()
            return
        }

        sync()

        Timer.scheduledTimer(
            timeInterval: TimeInterval(repeatTime),
            target: self, selector: #selector(sync),
            userInfo: nil, repeats: repeatTime != 0
        )
    }

    @objc private func sync() {
        NSLog("%@: syncing: %@", className, loadableToSync.className)
        lastUpdateDate = Date()
        loadableToSync.doSync()
    }

    private func stopSyncingTimer() {
        autoSyncingTimer?.invalidate()
        autoSyncingTimer = nil
    }
}
