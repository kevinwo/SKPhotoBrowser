//
//  SKCacheTests.swift
//  SKPhotoBrowser
//
//  Created by Kevin Wolkober on 6/13/16.
//  Copyright © 2016 suzuki_keishi. All rights reserved.
//

import XCTest
@testable import SKPhotoBrowser

extension UIImage {
    static func fromColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 100, height: 100)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        CGContextSetFillColorWithColor(context, color.CGColor)
        CGContextFillRect(context, rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img
    }
}

class RRImageCache: SKRequestResponseCacheable {

    let cache: NSURLCache

    init(cache: NSURLCache) {
        self.cache = cache
    }

    func cachedResponseForRequest(request: NSURLRequest) -> NSCachedURLResponse? {
        return self.cache.cachedResponseForRequest(request)
    }

    func storeCachedResponse(cachedResponse: NSCachedURLResponse, forRequest request: NSURLRequest) {
        self.cache.storeCachedResponse(cachedResponse, forRequest: request)
    }
}

class SKCacheTests: XCTestCase {

    var cache: SKCache!
    var image: UIImage!
    let key = "test_image"

    override func setUp() {
        super.setUp()

        self.image = UIImage.fromColor(UIColor.redColor())
        self.cache = SKCache()
    }

    override func tearDown() {
        self.cache = nil

        super.tearDown()
    }
    
    func testInit() {
        XCTAssertNotNil(self.cache.imageCache)
        XCTAssert(self.cache.imageCache is SKDefaultImageCache, "Default image cache should be loaded on init")
    }

    func testDefaultCacheImageForKey() {
        // given
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        cache.setObject(self.image, forKey: self.key)

        // when
        let cachedImage = self.cache.imageForKey(self.key)

        // then
        XCTAssertNotNil(cachedImage)
    }

    func testDefaultCacheSetImageForKey() {
        // when
        self.cache.setImage(self.image, forKey: self.key)

        // then
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        let cachedImage = cache.objectForKey(self.key) as? UIImage
        XCTAssertNotNil(cachedImage)
    }

    func testDefaultCacheRemoveImageForKey() {
        // given
        let cache = (self.cache.imageCache as? SKDefaultImageCache)!.cache
        cache.setObject(self.image, forKey: self.key)

        // when
        self.cache.removeImageForKey(self.key)

        // then
        let cachedImage = self.cache.imageForKey(self.key)
        XCTAssertNil(cachedImage)
    }

    func testRequestResponseImageForRequest() {
        // given
        let cache = NSURLCache(
            memoryCapacity: 20 * 1024 * 1024, // 20 MB,
            diskCapacity: 150 * 1024 * 1024,  // 150 MB, 
            diskPath: "com.keishi.suzuki.SKPhotoBrowser"
        )
        let rrCache = RRImageCache(cache: cache)

        let request = NSURLRequest(URL: NSURL(string: "fake.url")!)
        let response = NSURLResponse(URL: request.URL!, MIMEType: "image/png", expectedContentLength: 2000, textEncodingName: nil)
        let data = UIImagePNGRepresentation(self.image)!
        let cachedResponse = NSCachedURLResponse(response: response, data: data)
        cache.storeCachedResponse(cachedResponse, forRequest: request)

        self.cache.imageCache = rrCache

        // when
        let image = self.cache.imageForRequest(request)

        // then
        XCTAssertNotNil(image)
    }
}
