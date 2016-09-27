//
//  MWKFPhoto.swift
//  MWPhotoBrowser_Swift
//
//  Created by Beniten on 9/27/16.
//  Copyright © 2016 Sereivoan. All rights reserved.
//

import UIKit
import Kingfisher
import MWPhotoBrowser
import Photos
import AssetsLibrary

final class MWKFPhoto: NSObject, MWPhoto {
  
  var caption: String?
  var videoURL: URL! {
    didSet {
      isVideo = true
    }
  }
  var emptyImage: Bool = true
  var isVideo: Bool = false
  var underlyingImage: UIImage?
  
  private var loadingInProgress: Bool = false
  private var downloadTask: RetrieveImageDownloadTask?
  private var assetRequestID: PHImageRequestID = PHInvalidImageRequestID
  private var assetVideoRequestID: PHImageRequestID = PHInvalidImageRequestID
  
  fileprivate var image: UIImage!
  fileprivate var photoURL: URL!
  fileprivate var asset: PHAsset!
  fileprivate var assetTargetSize: CGSize!
  
  init(image: UIImage) {
    super.init()
    self.image = image
  }
  
  init(asset: PHAsset, targetSize: CGSize) {
    super.init()
    self.asset = asset
    self.assetTargetSize = targetSize
    self.isVideo = asset.mediaType == .video
  }
  
  init(photoURL: URL) {
    super.init()
    self.photoURL = photoURL
  }
  
  init(videoURL: URL) {
    super.init()
    self.videoURL = videoURL
    self.isVideo = true
    self.emptyImage = true
  }
  
  deinit {
    cancelAnyLoading()
  }
  
  func getVideoURL(_ completion: @escaping (URL?) -> Void) {
    if (videoURL != nil) {
        completion(videoURL)
    } else if asset != nil && asset.mediaType == .video {
      cancelVideoRequest() // Cancel any existing
      let options = PHVideoRequestOptions()
      options.isNetworkAccessAllowed = true
      assetVideoRequestID = PHImageManager.default().requestAVAsset(forVideo: asset, options: options) { [weak self] asset, audioMix, info in
        self?.assetVideoRequestID = PHInvalidImageRequestID
        if let asset = asset as? AVURLAsset {
          completion(asset.url)
        } else {
          completion(nil)
        }
      }
    }
  }
  
  func loadUnderlyingImageAndNotify() {
    assert(Thread.isMainThread, "This method must be called on the main thread.")
    guard !loadingInProgress else { return }
    loadingInProgress = true
    if underlyingImage != nil {
      imageLoadingComplete()
    } else {
      performLoadUnderlyingImageAndNotify()
    }
  }
  
  // Set the underlyingImage
  func performLoadUnderlyingImageAndNotify() {
    
    // Get underlying image
    if image != nil {
      
      // We have UIImage!
      underlyingImage = image
      imageLoadingComplete()
      
    } else if photoURL != nil {
      
      // Check what type of url it is
      if photoURL.scheme?.lowercased() == "assets-libralibraryry" {
        
        // Load from assets library
        performLoadUnderlyingImageAndNotifyWithAssetsLibrary(url: photoURL)
        
      } else if photoURL.isFileURL {
        
        // Load from local file async
        performLoadUnderlyingImageAndNotifyWithLocalFile(url: photoURL)
        
      } else {
        
        // Load async from web (using SDWebImage)
        performLoadUnderlyingImageAndNotify(with: photoURL)
        
      }
      
    } else if asset != nil {
      
      // Load from photos asset
      performLoadUnderlyingImageAndNotify(with: asset, targetSize: assetTargetSize)
      
    } else {
      
      // Image is empty
      imageLoadingComplete()
      
    }
  }
  
  // Load from web
  fileprivate func performLoadUnderlyingImageAndNotify(with url: URL) {
    downloadTask = KingfisherManager.shared.downloader.downloadImage(with: url, options: nil,
      progressBlock: { [weak self] receivedSize, expectedSize in
        guard let `self` = self else { return }
        if expectedSize > 0 {
          let progress = Double(receivedSize) / Double(expectedSize)
          let dict = ["progress": progress, "photo": self] as [String: Any]
          NotificationCenter.default.post(name: .MWPhotoProgress, object: dict)
        }
      },
      completionHandler: { [weak self] image, error, imageURL, originalData in
        if error != nil {
          print("Kingfisher failed to download image: \(error)")
        }
        self?.downloadTask = nil
        self?.underlyingImage = image
        
        DispatchQueue.main.async {
          self?.imageLoadingComplete()
        }
      }
    )
  }
  
  // Load from local file
  fileprivate func performLoadUnderlyingImageAndNotifyWithLocalFile(url: URL) {
    DispatchQueue.global(qos: .default).async { [weak self] in
      self?.underlyingImage = UIImage(contentsOfFile: url.path)
      if self?.underlyingImage == nil {
        print("Error loading photo from path: \(url.path)")
      }
    }
  }
  
  // Load from asset library async
  fileprivate func performLoadUnderlyingImageAndNotifyWithAssetsLibrary(url: URL) {
    DispatchQueue.global(qos: .default).async {
      let assetsLibrary = ALAssetsLibrary()
      assetsLibrary.asset(for: url,
        resultBlock: { [weak self] asset in
          guard let `self` = self else { return }
          let rep = asset?.defaultRepresentation()
          let iref = rep?.fullScreenImage()
          if let iref = iref {
            self.underlyingImage = UIImage(cgImage: iref as! CGImage)
          }
          self.imageLoadingComplete()
        }, failureBlock: { [weak self] error in
          self?.underlyingImage = nil
          print("Photo from asset library error: \(error)")
          self?.imageLoadingComplete()
        }
      )
    }
  }
  
  // Load from photos library
  fileprivate func performLoadUnderlyingImageAndNotify(with asset: PHAsset, targetSize: CGSize) {
    let options = PHImageRequestOptions()
    options.isNetworkAccessAllowed = true
    options.resizeMode = .fast
    options.deliveryMode = .highQualityFormat
    options.isSynchronous = false
    options.progressHandler = { [weak self] progress, error, stop, info in
      guard let `self` = self else { return }
      let dict = ["progress": progress, "photo": self] as [String: Any]
      NotificationCenter.default.post(name: .MWPhotoProgress, object: dict)
    }
    
    assetRequestID = PHImageManager.default().requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { [weak self] result, info in
      DispatchQueue.main.async {
        self?.underlyingImage = result
        self?.imageLoadingComplete()
      }
    }
  }
  
  // Release if we can get it again from url
  internal func unloadUnderlyingImage() {
    loadingInProgress = false
    underlyingImage = nil
  }
  
  fileprivate func imageLoadingComplete() {
    assert(Thread.isMainThread, "This method must be called on the main thread.")
    // Complete so notify
    loadingInProgress = false
    // Notify on next run loop
    postCompleteNotification()
  }
  
  fileprivate func postCompleteNotification() {
    NotificationCenter.default.post(name: .MWPhotoLoadingDidEnd, object: self)
  }
  
  func cancelAnyLoading() {
    downloadTask?.cancel()
    downloadTask = nil
    loadingInProgress = false
    cancelImageRequest()
    cancelVideoRequest()
  }
  
  fileprivate func cancelImageRequest() {
    if assetRequestID != PHInvalidImageRequestID {
      PHImageManager.default().cancelImageRequest(assetRequestID)
      assetRequestID = PHInvalidImageRequestID
    }
  }
  
  fileprivate func cancelVideoRequest() {
    if assetVideoRequestID != PHInvalidImageRequestID {
      PHImageManager.default().cancelImageRequest(assetVideoRequestID)
      assetVideoRequestID = PHInvalidImageRequestID
    }
  }
  
}
