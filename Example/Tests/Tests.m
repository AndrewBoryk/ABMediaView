//
//  ABMediaViewTests.m
//  ABMediaViewTests
//
//  Created by Andrew Boryk on 01/04/2017.
//  Copyright (c) 2017 Andrew Boryk. All rights reserved.
//

@import XCTest;
#import <ABMediaView/ABCacheManager.h>
#import <ABMediaView/ABCommons.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
    
    [self testImageURLValidity];
    
    [self testVideoURLValidity];
    
    [self testGIFURLValidity];
    
    [self testAudioURLValidity];
    
    [self testImageLoading];
    
    [self testVideoLoading];
    
    [self testGIFLoading];
    
    [self testAudioLoading];
    
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void) testImageURLValidity {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"http://camendesign.com/code/video_for_everybody/poster.jpg"] isValidForCacheType:ImageCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"Image URL is invalid");
    }];
}

- (void) testVideoURLValidity {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"] isValidForCacheType:VideoCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"Video URL is invalid");
    }];
}

- (void) testGIFURLValidity {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif"] isValidForCacheType:GIFCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"GIF URL is invalid");
    }];
}

- (void) testAudioURLValidity {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"https://a.tumblr.com/tumblr_ojs6z4VJp31u5escjo1.mp3"] isValidForCacheType:AudioCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"GIF URL is invalid");
    }];
}

- (void)testImageLoading {
    [ABCacheManager loadImage:@"http://camendesign.com/code/video_for_everybody/poster.jpg" completion:^(UIImage *image, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:image], "image should not be null");
        
        [self testGetImageCacheForKey:key];
    }];
}

- (void)testVideoLoading {
    [ABCacheManager loadVideo:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4" completion:^(NSURL *videoPath, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:videoPath], "videoPath should not be null");
        
        [self testGetVideoCacheForKey:key];
    }];
}

- (void)testGIFLoading {
    [ABCacheManager loadGIF:@"http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif" completion:^(UIImage *gif, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:gif], "gif should not be null");
        
        [self testGetGIFCacheForKey:key];
    }];
}

- (void)testAudioLoading {
    [ABCacheManager loadAudio:@"https://a.tumblr.com/tumblr_ojs6z4VJp31u5escjo1.mp3" completion:^(NSURL *audioPath, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:audioPath], "audioPath should not be null");
        
        [self testGetAudioCacheForKey:key];
    }];
}

- (void)testGetImageCacheForKey:(NSString *)key {
    UIImage *cachedObject = [ABCacheManager getCache:ImageCache objectForKey:key];
    
    XCTAssert([ABCommons notNull:cachedObject], "cached image should not be null");
}

- (void)testGetVideoCacheForKey:(NSString *)key {
    NSString *cachedObject = [ABCacheManager getCache:VideoCache objectForKey:key];
    
    XCTAssert([ABCommons notNull:cachedObject], "cached video should not be null");
}

- (void)testGetGIFCacheForKey:(NSString *)key {
    UIImage *cachedObject = [ABCacheManager getCache:GIFCache objectForKey:key];
    
    XCTAssert([ABCommons notNull:cachedObject], "cached GIF should not be null");
}

- (void)testGetAudioCacheForKey:(NSString *)key {
    NSString *cachedObject = [ABCacheManager getCache:AudioCache objectForKey:key];
    
    XCTAssert([ABCommons notNull:cachedObject], "cached audio should not be null");
}

@end

