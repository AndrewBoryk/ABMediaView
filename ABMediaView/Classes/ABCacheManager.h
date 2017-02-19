//
//  ABCacheManager.h
//  Pods
//
//  Created by Andrew Boryk on 2/19/17.
//
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "UIImage+animatedGIF.h"

typedef void (^ImageDataBlock)(UIImage *image, NSString *key, NSError *error);
typedef void (^VideoDataBlock)(NSString *videoPath, NSString *key, NSError *error);
typedef void (^AudioDataBlock)(NSString *audioPath, NSString *key, NSError *error);
typedef void (^GIFDataBlock)(UIImage *gif, NSString *key, NSError *error);

/// Different types of caches
typedef NS_ENUM(NSInteger, CacheType) {
    ImageOriginal,
    ImageThumbnail,
    Video,
    Audio,
    GIF,
};

@interface ABCacheManager : NSObject {
    /// Queue which holds requests for downloading full size images
    NSCache *imageOriginalQueue;
    
    /// Queue which holds requests for downloading thumbnail images
    NSCache *imageThumbnailQueue;
    
    /// Queue which holds requests for downloading videos
    NSCache *videoQueue;
    
    /// Queue which holds requests for downloading GIFs
    NSCache *gifQueue;
    
    /// Queue which holds requests for downloading audio
    NSCache *audioQueue;
    
    /// Cache which holds full size images
    NSCache *imageOriginalCache;
    
    /// Cache which holds thumbnail size images
    NSCache *imageThumbnailCache;
    
    /// Cache which holds paths to videos on disk
    NSCache *videoCache;
    
    /// Cache which holds GIFs
    NSCache *gifCache;
    
    /// Cache which holds paths to audio on disk
    NSCache *audioCache;
}

/// Queue which holds requests for downloading full size images
@property (retain, nonatomic) NSCache *imageOriginalQueue;

/// Queue which holds requests for downloading thumbnail images
@property (retain, nonatomic) NSCache *imageThumbnailQueue;

/// Queue which holds requests for downloading videos
@property (retain, nonatomic) NSCache *videoQueue;

/// Queue which holds requests for downloading GIFs
@property (retain, nonatomic) NSCache *gifQueue;

/// Queue which holds requests for downloading audio
@property (retain, nonatomic) NSCache *audioQueue;

/// Cache which holds full size images
@property (retain, nonatomic) NSCache *imageOriginalCache;

/// Cache which holds thumbnail size images
@property (retain, nonatomic) NSCache *imageThumbnailCache;

/// Cache which holds paths to videos on disk
@property (retain, nonatomic) NSCache *videoCache;

/// Cache which holds GIFs
@property (retain, nonatomic) NSCache *gifCache;

/// Cache which holds paths to audio on disk
@property (retain, nonatomic) NSCache *audioCache;

/// Shared Manager for Media Cache
+ (id)sharedManager;

/// Get object within cache (image, GIF, video or audio location)
- (id) getCache:(CacheType)type objectForKey:(NSString *)key;

/// Set an object to a desired cache (image, GIF, video or audio location)
- (void) setCache:(CacheType)type object:(id)object forKey:(NSString *)key;

/// Remove an object within a desired cache
- (void) removeCache:(CacheType)type forKey:(NSString *)key;

/// Check if the request is in the queue
- (id) getQueue:(CacheType)type objectForKey:(NSString *)key;

/// Add a request to the queue
- (void) addQueue:(CacheType)type object:(id)object forKey:(NSString *)key;

/// Remove the request from the queue
- (void)removeFromQueue:(CacheType)type forKey:(NSString *)key;

/// Load image and store in cache, or retrieve image from cache if already stored
- (void)loadImage:(NSString *)image type:(CacheType)type completion:(ImageDataBlock)completionBlock;

/// Load video and store in cache, or retrieve video from cache if already stored
- (void)loadVideo:(NSString *)video type:(CacheType)type completion:(VideoDataBlock)completionBlock;

/// Load audio and store in cache, or retrieve audio from cache if already stored
- (void)loadAudio:(NSString *)audio type:(CacheType)type completion:(AudioDataBlock)completionBlock;

/// Load GIF and store in cache, or retrieve gif from cache if already stored
- (void)loadGIF:(NSString *)urlString type:(CacheType) type completion:(GIFDataBlock)completionBlock;

/// Remove videos from documents directory
+ (void) removeDocumentsVideos;

@end
