//
//  RFSVGCache.swift
//  RFSVG
//
//  Created by Dunja Lalic on 1/25/17.
//  Copyright © 2017 Lautsprecher Teufel GmbH. All rights reserved.
//

import Foundation
import UIKit
import PocketSVG

class RFSVGCache: DirectoryWatcherDelegate {
    // MARK: Properties
    
    static let sharedInstance = RFSVGCache()
    var bundle = Bundle.main
    private var directoryWatcher: DirectoryWatcher?
    private let imageCache: NSCache<NSString, UIImage> = NSCache()
    private var writeQueue: DispatchQueue = DispatchQueue(label: "com.raumfeld.SerialSVGCacheQueue",attributes: [])
    
    // MARK: Lifecycle
    
    init() {
        if FileManager.default.fileExists(atPath: pathForTemporaryDirectory()) {
            do {
                try FileManager.default.removeItem(atPath: pathForTemporaryDirectory())
            } catch {
                debugPrint("Error removing folder at path \(pathForTemporaryDirectory())")
            }
        }
        
        do {
            try FileManager.default.createDirectory(atPath: pathForTemporaryDirectory(), withIntermediateDirectories: false, attributes: nil)
        } catch {
            debugPrint("Error creating folder at path \(pathForTemporaryDirectory())")
        }
        
        self.imageCache.name = "com.raumfeld.SVGCache"
        
        self.directoryWatcher = DirectoryWatcher.init(URL: pathURLForTemporaryDirectory(), delegate: self)
        
        let didBecomeActiveBlock = { [unowned self] (_: Notification) in
            self.handleApplicationDidBecomeActive()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidBecomeActive,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: didBecomeActiveBlock)
        
        let didEnterBackgroundBlock = { [unowned self] (_: Notification) in
            self.handleApplicationDidEnterBackgroundBlock()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidEnterBackground,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: didEnterBackgroundBlock)
        
        let removalBlock = { [unowned self] (_: Notification) in
            self.handleLowMemoryWarning()
        }
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.UIApplicationDidReceiveMemoryWarning,
                                               object: nil,
                                               queue: OperationQueue.main,
                                               using: removalBlock)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidBecomeActive, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
        self.directoryWatcher?.stopMonitoring()
    }
    
    public func image(name: String,size: CGSize) -> UIImage {
        if let image = imageFromMemoryCache(name: name, size: size) {
            return image
        }

        if imageExistsInDiskCache(name: name,size: size) {
            return imageFromDiskCache(name: name, size: size)
        }
        
        let image = imageFromSVG(name: name, size: size)
        cacheImageAsync(image: image, name: name, size: size)
        return image
    }
    
    // MARK: File management
    
    private func imageName(name: String,size: CGSize) -> String {
        return "\(name)_\(size.width)x\(size.height).png"
    }
    
    func pathForTemporaryDirectory() -> String {
        var path = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0] as String
        path += "/com.raumfeld.SVGCache"
        return path
    }
    
    private func pathURLForTemporaryDirectory() -> URL {
        return URL(fileURLWithPath: pathForTemporaryDirectory())
    }
    
    private func pathForImage(name: String,size: CGSize) -> String {
        let fileName = self.imageName(name: name, size: size)
        return pathForTemporaryDirectory() + "/" + fileName
    }
    
    private func pathURLForImage(name: String,size: CGSize) -> URL {
        return URL(fileURLWithPath: pathForImage(name: name, size: size))
    }
    
    //MARK: SVG parsing
    
    private func imageFromSVG(name: String,size: CGSize) -> UIImage {
        let url = self.bundle.url(forResource: name, withExtension: "svg")!
        let layer: SVGLayer = SVGLayer.init(contentsOf: url)
        layer.contentsGravity = kCAGravityResizeAspect
        layer.frame = CGRect.init(origin: CGPoint.zero, size: size)
        layer.scaleLineWidth = true
        let image = imageForLayer(layer: layer)
        return image
    }
    
    private func imageForLayer(layer: CALayer) -> UIImage {
        let bounds = layer.bounds
        if (bounds.size.width == 0 || bounds.size.height == 0) {
            return UIImage()
        }
        
        UIGraphicsBeginImageContextWithOptions(bounds.size, false, 0)
        let context: CGContext = UIGraphicsGetCurrentContext()!
        context.saveGState()
        layer.layoutIfNeeded()
        layer.render(in: context)
        context.restoreGState()
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
    
    // MARK: Caching
    
    func imageFromMemoryCache(name: String,size: CGSize) -> UIImage? {
        return self.imageCache.object(forKey: imageName(name: name, size: size) as NSString)
    }
    
    private func imageExistsInDiskCache(name: String,size: CGSize) -> Bool {
        return FileManager.default.fileExists(atPath: pathForImage(name: name, size: size))
    }
    
    func imageFromDiskCache(name: String,size: CGSize) -> UIImage {
        let pngData: Data = try! Data.init(contentsOf: pathURLForImage(name: name, size: size))
        
        guard let image = UIImage(data: pngData) else {
            return UIImage()
        }
        
        return image
    }
    
    private func cacheImageAsync(image: UIImage, name: String,size: CGSize) {
        var cost = 0
        if let imageRef = image.cgImage {
            cost = imageRef.bytesPerRow
        } else {
            cost = Int(image.size.height * image.size.width * image.scale * image.scale)
        }
        self.imageCache.setObject(image, forKey: imageName(name: name, size: size) as NSString, cost: cost)
        
        writeQueue.async { [weak self] in
            guard let weakSelf = self else {
                return
            }
            if let pngData = UIImagePNGRepresentation(image) {
                let fileURL = weakSelf.pathURLForImage(name: name, size: size)
                do {
                    try pngData.write(to: fileURL, options: .atomic)
                } catch {
                    debugPrint("Error writing file to URL \(fileURL)")
                }
            }
        }
    }
    
    // MARK: Notifications
    
    private func handleApplicationDidBecomeActive() {
        self.directoryWatcher?.startMonitoring()
    }
    
    private func handleApplicationDidEnterBackgroundBlock() {
        self.directoryWatcher?.stopMonitoring()
    }
    
    private func handleLowMemoryWarning() {
        self.imageCache.removeAllObjects()
    }
    
    // MARK: DirectoryWatcherDelegate
    
    internal func directoryDidChange(_ directoryWatcher: DirectoryWatcher) {
        do {
            let items = try FileManager.default.contentsOfDirectory(atPath: pathForTemporaryDirectory())
            for item: String in items {
                self.imageCache.removeObject(forKey: item as NSString)
            }
        } catch {
            debugPrint("Error reading contents of folder at path \(pathForTemporaryDirectory())")
        }
    }
}
