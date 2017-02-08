//
//  DirectoryWatcher.swift
//  RFSVG
//
//  Created by Dunja Lalic on 28/01/2017.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import Foundation

protocol DirectoryWatcherDelegate: class {
    func directoryDidChange(_ directoryWatcher: DirectoryWatcher)
}

class DirectoryWatcher {
    // MARK: Properties
    
    /// A delegate responsible for responding to `DirectoryWatcher` updates
    private weak var delegate: DirectoryWatcherDelegate?
    /// A file descriptor for the monitored directory
    private var monitoredDirectoryFileDescriptor: CInt = -1
    /// A dispatch queue used for sending file changes in the directory
    private let directoryWatcherQueue = DispatchQueue(label: "com.raumfeld.SVGCache.directoryWatcher", attributes: DispatchQueue.Attributes.concurrent)
    /// A dispatch source to monitor a file descriptor
    private var directoryWatcherSource: DispatchSourceFileSystemObject?
    /// URL for the directory to be monitored
    private var URL: URL
    
    // MARK: Lifecycle
    
    /// Initializer.
    ///
    /// - Parameters:
    ///   - URL: URL for the directory to be monitored
    ///   - delegate: A delegate responsible for responding to `DirectoryWatcher` updates
    init(URL: URL, delegate: DirectoryWatcherDelegate) {
        self.URL = URL
        self.delegate = delegate
    }
    
    // MARK: Monitoring
    
    /// Starts monitoring
    func startMonitoring() {
        if directoryWatcherSource == nil && monitoredDirectoryFileDescriptor == -1 {
            monitoredDirectoryFileDescriptor = open(URL.path, O_EVTONLY)
            
            directoryWatcherSource = DispatchSource.makeFileSystemObjectSource(fileDescriptor: monitoredDirectoryFileDescriptor, eventMask: [.write], queue: directoryWatcherQueue)
            
            directoryWatcherSource?.setEventHandler {
                self.delegate?.directoryDidChange(self)
                
                return
            }
            
            directoryWatcherSource?.setCancelHandler {
                close(self.monitoredDirectoryFileDescriptor)
                
                self.monitoredDirectoryFileDescriptor = -1
                
                self.directoryWatcherSource = nil
            }
            
            directoryWatcherSource?.resume()
        }
    }
    
    /// Stops monitoring
    func stopMonitoring() {
        directoryWatcherSource?.cancel()
    }
}
