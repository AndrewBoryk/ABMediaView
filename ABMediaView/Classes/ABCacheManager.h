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
#import <AVFoundation/AVFoundation.h>

typedef void (^ImageDataBlock)(UIImage *image, NSString *key, NSError *error);
typedef void (^VideoDataBlock)(NSURL *videoPath, NSString *key, NSError *error);
typedef void (^AudioDataBlock)(NSURL *audioPath, NSString *key, NSError *error);
typedef void (^GIFDataBlock)(UIImage *gif, NSString *key, NSError *error);

/// Different types of caches
typedef NS_ENUM(NSInteger, CacheType) {
    ImageCache,
    VideoCache,
    AudioCache,
    GIFCache,
};

@interface ABCacheManager : NSObject

/// Queue which holds requests for downloading images
@property (strong, nonatomic) NSCache *imageQueue;

/// Queue which holds requests for downloading videos
@property (strong, nonatomic) NSCache *videoQueue;

/// Queue which holds requests for downloading GIFs
@property (strong, nonatomic) NSCache *gifQueue;

/// Queue which holds requests for downloading audio
@property (strong, nonatomic) NSCache *audioQueue;

/// Cache which holds images
@property (strong, nonatomic) NSCache *imageCache;

/// Cache which holds paths to videos on disk
@property (strong, nonatomic) NSCache *videoCache;

/// Cache which holds GIFs
@property (strong, nonatomic) NSCache *gifCache;

/// Cache which holds paths to audio on disk
@property (strong, nonatomic) NSCache *audioCache;

/// Determines whether media should be cached when downloaded
@property (nonatomic) BOOL cacheMediaWhenDownloaded;

/// If all media is sourced from the same location, then the ABCacheManager will search the Directory for files with the same name when getting cache (only applies to Audio and Video)
@property (nonatomic) BOOL isAllMediaFromSameLocation;

/// Shared Manager for Media Cache
+ (id)sharedManager;

/// Get object within cache (image, GIF, video or audio location)
- (id)getCache:(CacheType)type objectForKey:(NSString *)key;

/// Class method for checking if an object is in the cache
+ (id)getCache:(CacheType)type objectForKey:(NSString *)key;

/// Set an object to a desired cache (image, GIF, video or audio location)
- (void)setCache:(CacheType)type object:(id)object forKey:(NSString *)key;

/// Class method for setting an object to a cache
+ (void)setCache:(CacheType)type object:(id)object forKey:(NSString *)key;

/// Remove an object within a desired cache
- (void)removeCache:(CacheType)type forKey:(NSString *)key;

/// Check if the request is in the queue
- (id)getQueue:(CacheType)type objectForKey:(NSString *)key;

/// Add a request to the queue
- (void)addQueue:(CacheType)type object:(id)object forKey:(NSString *)key;

/// Remove the request from the queue
- (void)removeFromQueue:(CacheType)type forKey:(NSString *)key;

/// Load image and store in cache, or retrieve image from cache if already stored (by string)
+ (void)loadImage:(NSString *)urlString completion:(ImageDataBlock)completionBlock;

/// Load image and store in cache, or retrieve image from cache if already stored
+ (void)loadImageURL:(NSURL *)url completion:(ImageDataBlock)completionBlock;

/// Load video and store in cache, or retrieve video from cache if already stored (by string)
+ (void)loadVideo:(NSString *)urlString completion:(VideoDataBlock)completionBlock;

/// Load video and store in cache, or retrieve video from cache if already stored
+ (void)loadVideoURL:(NSURL *)url completion:(VideoDataBlock)completionBlock;

/// Load audio and store in cache, or retrieve audio from cache if already stored (by string)
+ (void)loadAudio:(NSString *)urlString completion:(AudioDataBlock)completionBlock;

/// Load audio and store in cache, or retrieve audio from cache if already stored
+ (void)loadAudioURL:(NSURL *)url completion:(AudioDataBlock)completionBlock;

/// Load audio from the iPod music library directory
+ (void)loadMusicLibrary:(NSString *)urlString completion:(AudioDataBlock)completionBlock;

/// Load GIF and store in cache, or retrieve gif from cache if already stored (by string)
+ (void)loadGIF:(NSString *)urlString completion:(GIFDataBlock)completionBlock;

/// Load GIF and store in cache, or retrieve gif from cache if already stored
+ (void)loadGIFURL:(NSURL *)url completion:(GIFDataBlock)completionBlock;

/// Load GIF using data and store in cache, or retrieve gif from cache if already stored
+ (void)loadGIFData:(NSData *)data completion:(GIFDataBlock)completionBlock;

/// Remove videos from documents directory
+ (void)clearDirectory:(NSInteger)type;

/// Determines if the url should be downloaded for the cache type
+ (void)detectIfURL:(NSURL *)url isValidForCacheType:(CacheType)type completion:(void (^)(BOOL isValidURL))completionBlock;

/// Exports an asset to disk given the asset, a url, and the type of cache
+ (void)exportAssetURL:(NSString *)urlString type:(CacheType)type asset:(AVAsset *)asset;

@end
