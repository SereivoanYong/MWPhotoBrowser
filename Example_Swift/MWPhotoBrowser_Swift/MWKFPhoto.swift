//
//  MWPhoto.swift
//  MWPhotoBrowser_Swift
//
//  Created by Beniten on 9/27/16.
//  Copyright © 2016 Sereivoan. All rights reserved.
//

import UIKit
import Kingfisher
import MWPhotoBrowser

final class MWKFPhoto: NSObject, MWPhoto {
  
  var underlyingImage: UIImage?
  private var photoURL: String
  
  private var downloadTask: RetrieveImageDownloadTask?
  private var loadingInProgress: Bool = false
  
  init(url: String) {
    photoURL = url
    super.init()
    underlyingImage = KingfisherManager.shared.cache.retrieveImageInDiskCache(forKey: url)
  }
  
  deinit {
    cancelAnyLoading()
  }
  
  func loadUnderlyingImageAndNotify() {
    assert(Thread.current.isMainThread, "This method must be called on the main thread.")
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
    if underlyingImage != nil {
      // We have UIImage!
      imageLoadingComplete()
    } else {
      // Load async from web (using Kingfisher)
      performLoadUnderlyingImageAndNotifyWithWebURL(url: URL(string: photoURL))
    }
  }
  
  private func performLoadUnderlyingImageAndNotifyWithWebURL(url: NSURL) {
    downloadTask = KingfisherManager.shared.downloader.downloadImageWithURL(
      url,
      progressBlock: { receivedSize, totalSize in
        if totalSize > 0 {
          let progress = Double(receivedSize) / Double(totalSize)
          let dict = ["progress": progress, "photo": self]
          NSNotificationCenter.defaultCenter().postNotificationName(MWPHOTO_PROGRESS_NOTIFICATION, object: dict)
        }
      },
      completionHandler: { [weak self] image, error, imageURL, originalData in
        if error != nil {
          print("Kingfisher failed to download image: \(error)")
        }
        self?.downloadTask = nil
        self?.underlyingImage = image
        
        dispatch_async(dispatch_get_main_queue()) { [weak self] in
          self?.imageLoadingComplete()
        }
      }
    )
  }
  
  // Release if we can get it again from url
  func unloadUnderlyingImage() {
    loadingInProgress = false
    underlyingImage = nil
  }
  
  private func imageLoadingComplete() {
    assert(Thread.current.isMainThread, "This method must be called on the main thread.")
    // Complete so notify
    loadingInProgress = false
    // Notify on next run loop
    NotificationCenter.default.post(name: .MWPhotoLoadingDidEnd, object: self)
  }
  
  func cancelAnyLoading() {
    downloadTask?.cancel()
    downloadTask = nil
  }
  
}
