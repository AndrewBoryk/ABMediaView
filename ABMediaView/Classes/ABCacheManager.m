//
//  ABCacheManager.m
//  Pods
//
//  Created by Andrew Boryk on 2/19/17.
//
//

#import "ABCacheManager.h"
#import "ABCommons.h"

@implementation ABCacheManager

@synthesize imageOriginalCache;
@synthesize imageThumbnailCache;
@synthesize videoCache;
@synthesize audioCache;
@synthesize gifCache;

@synthesize imageOriginalQueue;
@synthesize imageThumbnailQueue;
@synthesize videoQueue;
@synthesize audioQueue;
@synthesize gifQueue;

+ (id)sharedManager {
    static ABCacheManager *sharedMyManager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedMyManager = [[self alloc] init];
    });
    return sharedMyManager;
}

- (id)init {
    if (self = [super init]) {
        // Initialize caches
        imageOriginalCache = [[NSCache alloc] init];
        imageThumbnailCache = [[NSCache alloc] init];
        videoCache = [[NSCache alloc] init];
        audioCache = [[NSCache alloc] init];
        gifCache = [[NSCache alloc] init];
        
        imageOriginalQueue = [[NSCache alloc] init];
        imageThumbnailQueue = [[NSCache alloc] init];
        videoQueue = [[NSCache alloc] init];
        audioQueue = [[NSCache alloc] init];
        gifQueue = [[NSCache alloc] init];
    }
    return self;
}

- (id) getCache: (CacheType) type objectForKey: (NSString *) key {
    if ([ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                return [imageOriginalCache objectForKey:key];
                break;
            case ImageThumbnail:
                return [imageThumbnailCache objectForKey:key];
                break;
            case Video:
                return [videoCache objectForKey:key];
                break;
            case Audio:
                return [audioCache objectForKey:key];
                break;
            case GIF:
                return [gifCache objectForKey:key];
                break;
                
            default:
                return nil;
                break;
        }
    }
    return nil;
}

- (void) setCache: (CacheType) type object: (id) object forKey: (NSString *) key {
    if ([ABCommons notNull:object] && [ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                [imageOriginalCache setObject:object forKey:key];
                break;
            case ImageThumbnail:
                [imageThumbnailCache setObject:object forKey:key];
                break;
            case Video:
                [videoCache setObject:object forKey:key];
                break;
            case Audio:
                [audioCache setObject:object forKey:key];
                break;
            case GIF:
                [gifCache setObject:object forKey:key];
                break;
            default:
                
                break;
        }
    }
    
}

- (void) removeCache: (CacheType) type forKey: (NSString *) key {
    if ([ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                [imageOriginalCache removeObjectForKey:key];
                break;
            case ImageThumbnail:
                [imageThumbnailCache removeObjectForKey:key];
                break;
            case Video:
                [videoCache removeObjectForKey:key];
                break;
            case Audio:
                [audioCache removeObjectForKey:key];
                break;
            case GIF:
                [gifCache removeObjectForKey:key];
                break;
            
                
            default:
                
                break;
        }
    }
    
}

- (id) getQueue: (CacheType) type objectForKey: (NSString *) key {
    if ([ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                return [imageOriginalQueue objectForKey:key];
                break;
            case ImageThumbnail:
                return [imageThumbnailQueue objectForKey:key];
                break;
            case Video:
                return [videoQueue objectForKey:key];
                break;
            case Audio:
                return [audioQueue objectForKey:key];
                break;
            case GIF:
                return [gifQueue objectForKey:key];
                break;
                
            default:
                return nil;
                break;
        }
    }
    return nil;
}

- (void) addQueue: (CacheType) type object: (id) object forKey: (NSString *) key {
    if ([ABCommons notNull:object] && [ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                [imageOriginalQueue setObject:object forKey:key];
                break;
            case ImageThumbnail:
                [imageThumbnailQueue setObject:object forKey:key];
                break;
            case Video:
                [videoQueue setObject:object forKey:key];
                break;
            case Audio:
                [audioQueue setObject:object forKey:key];
                break;
            case GIF:
                [gifQueue setObject:object forKey:key];
                break;
                
            default:
                
                break;
        }
    }
    
}

- (void) removeFromQueue: (CacheType) type forKey: (NSString *) key {
    if ([ABCommons notNull:key]) {
        switch (type) {
            case ImageOriginal:
                [imageOriginalQueue removeObjectForKey:key];
                break;
            case ImageThumbnail:
                [imageThumbnailQueue removeObjectForKey:key];
                break;
            case Video:
                [videoQueue removeObjectForKey:key];
                break;
            case Audio:
                [audioQueue removeObjectForKey:key];
                break;
            case GIF:
                [gifQueue removeObjectForKey:key];
                break;
                
            default:
                
                break;
        }
    }
    
}

@end
