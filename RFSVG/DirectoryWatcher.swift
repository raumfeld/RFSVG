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
    
    private weak var delegate: DirectoryWatcherDelegate?
    private var monitoredDirectoryFileDescriptor: CInt = -1
    private let directoryWatcherQueue = DispatchQueue(label: "com.raumfeld.SVGCache.directoryWatcher", attributes: DispatchQueue.Attributes.concurrent)
    private var directoryWatcherSource: DispatchSourceFileSystemObject?
    private var URL: URL
    
    // MARK: Lifecycle
    
    init(URL: URL, delegate: DirectoryWatcherDelegate) {
        self.URL = URL
        self.delegate = delegate
    }
    
    // MARK: Monitoring
    
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
    
    func stopMonitoring() {
        directoryWatcherSource?.cancel()
    }
}
