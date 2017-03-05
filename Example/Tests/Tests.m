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
    
    [self testVideoURLValidityMP4];
    
    [self testVideoURLValidityMOV];
    
    [self testGIFURLValidity];
    
    [self testAudioURLValidity];
    
    [self testImageLoading];
    
    [self testVideoLoadingMP4];
    
    [self testVideoLoadingMOV];
    
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

- (void) testVideoURLValidityMP4 {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"] isValidForCacheType:VideoCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"Video URL MP4 is invalid");
    }];
}

- (void) testVideoURLValidityMOV {
    [ABCacheManager detectIfURL:[NSURL URLWithString:@"http://techslides.com/demos/samples/sample.mov"] isValidForCacheType:VideoCache completion:^(BOOL isValidURL) {
        XCTAssert(isValidURL, @"Video URL MOV is invalid");
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
    }];
}

- (void)testVideoLoadingMP4 {
    [ABCacheManager loadVideo:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4" completion:^(NSURL *videoPath, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:videoPath], "videoPath MP4 should not be null");
    }];
}

- (void)testVideoLoadingMOV {
    [ABCacheManager loadVideo:@"http://techslides.com/demos/samples/sample.mov" completion:^(NSURL *videoPath, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:videoPath], "videoPath MOV should not be null");
    }];
}

- (void)testGIFLoading {
    [ABCacheManager loadGIF:@"http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif" completion:^(UIImage *gif, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:gif], "gif should not be null");
    }];
}

- (void)testAudioLoading {
    [ABCacheManager loadAudio:@"https://a.tumblr.com/tumblr_ojs6z4VJp31u5escjo1.mp3" completion:^(NSURL *audioPath, NSString *key, NSError *error) {
        XCTAssert([ABCommons notNull:audioPath], "audioPath should not be null");
    }];
}

@end

