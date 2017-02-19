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

@synthesize imageCache;
@synthesize videoCache;
@synthesize audioCache;
@synthesize gifCache;

@synthesize imageQueue;
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
        imageCache = [[NSCache alloc] init];
        videoCache = [[NSCache alloc] init];
        audioCache = [[NSCache alloc] init];
        gifCache = [[NSCache alloc] init];
        
        imageQueue = [[NSCache alloc] init];
        videoQueue = [[NSCache alloc] init];
        audioQueue = [[NSCache alloc] init];
        gifQueue = [[NSCache alloc] init];
    }
    return self;
}

- (id) getCache: (CacheType) type objectForKey: (NSString *) key {
    if ([ABCommons notNull:key]) {
        switch (type) {
            case ImageCache:
                return [imageCache objectForKey:key];
                break;
            case VideoCache:
                return [videoCache objectForKey:key];
                break;
            case AudioCache:
                return [audioCache objectForKey:key];
                break;
            case GIFCache:
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
            case ImageCache:
                [imageCache setObject:object forKey:key];
                break;
            case VideoCache:
                [videoCache setObject:object forKey:key];
                break;
            case AudioCache:
                [audioCache setObject:object forKey:key];
                break;
            case GIFCache:
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
            case ImageCache:
                [imageCache removeObjectForKey:key];
                break;
            case VideoCache:
                [videoCache removeObjectForKey:key];
                break;
            case AudioCache:
                [audioCache removeObjectForKey:key];
                break;
            case GIFCache:
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
            case ImageCache:
                return [imageQueue objectForKey:key];
                break;
            case VideoCache:
                return [videoQueue objectForKey:key];
                break;
            case AudioCache:
                return [audioQueue objectForKey:key];
                break;
            case GIFCache:
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
            case ImageCache:
                [imageQueue setObject:object forKey:key];
                break;
            case VideoCache:
                [videoQueue setObject:object forKey:key];
                break;
            case AudioCache:
                [audioQueue setObject:object forKey:key];
                break;
            case GIFCache:
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
            case ImageCache:
                [imageQueue removeObjectForKey:key];
                break;
            case VideoCache:
                [videoQueue removeObjectForKey:key];
                break;
            case AudioCache:
                [audioQueue removeObjectForKey:key];
                break;
            case GIFCache:
                [gifQueue removeObjectForKey:key];
                break;
                
            default:
                
                break;
        }
    }
    
}

- (void)loadGIF:(NSString *)urlString type:(CacheType) type completion:(GIFDataBlock)completionBlock {
    
    if ([ABCommons notNull:urlString]) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        if ([ABCommons notNull: [[ABCacheManager sharedManager] getCache:type objectForKey:urlString]]) {
            
            if(completionBlock) completionBlock([[ABCacheManager sharedManager] getCache:type objectForKey:urlString], urlString, nil);
            
        }
        else {
            if ([[ABCacheManager sharedManager] getQueue:type objectForKey:urlString] == nil) {
                if ([ABCommons notNull:url]) {
                    
                    [[ABCacheManager sharedManager] addQueue:type object:urlString forKey:urlString];
                    
                    dispatch_queue_t downloadQueue = dispatch_queue_create("com.linute.processsmagequeue", NULL);
                    dispatch_async(downloadQueue, ^{
                        NSData *imageData = [NSData dataWithContentsOfURL:url];
                        UIImage *image = [UIImage animatedImageWithAnimatedGIFData:imageData];
                        
                        if ([ABCommons notNull:urlString] && [ABCommons notNull:imageData]) {
                            [[ABCacheManager sharedManager] setCache:type object:imageData forKey:urlString];
                        }
                        
                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                        
                        if(completionBlock) completionBlock(imageData, urlString, nil);
                    });
                }
                else {
                    if(completionBlock) completionBlock(nil, nil, nil);
                }
            }
            else {
                
            }
        }
    }
    else {
        if(completionBlock) completionBlock(nil, nil, nil);
    }
    
    
    
}

- (void)loadImage:(NSString *)urlString type:(CacheType)type completion:(ImageDataBlock)completionBlock {
    
    if ([ABCommons notBlank:urlString]) {
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        if ([ABCommons notNull: [[ABCacheManager sharedManager] getCache:type objectForKey:urlString]]) {
            if(completionBlock) completionBlock([[ABCacheManager sharedManager] getCache:type objectForKey:urlString], urlString, nil);
            
        }
        else {
            if ([[ABCacheManager sharedManager] getQueue:type objectForKey:urlString] == nil) {
                if ([ABCommons notNull:url]) {
                    
                    [[ABCacheManager sharedManager] addQueue:type object:urlString forKey:urlString];
                    
                    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
                        if (data) {
                            UIImage *image = [UIImage imageWithData:data];
                            
                            if (image) {
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    if(completionBlock) completionBlock(image, urlString, nil);
                                });
                            }
                        }
                    }];
                    
//                    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//                    manager.responseSerializer = [AFImageResponseSerializer serializer];
//                    
//                    manager.requestSerializer.cachePolicy = NSURLRequestReloadIgnoringLocalAndRemoteCacheData;
//                    
//                    //                    NSLog(@"URL %@", url);
//                    
//                    [manager GET:url.absoluteString parameters:nil progress:^(NSProgress * _Nonnull downloadProgress) {
//                        
//                        if (type == PostImageOriginal || type == ArticleImage) {
//                            NSURL *notificationURL = [[CacheManager sharedManager] imageURL:image type:type];
//                            if ([Utils notNull:notificationURL]) {
//                                
//                                NSNumber *progressNumber = [NSNumber numberWithFloat:downloadProgress.fractionCompleted];
//                                NSString *progressImage = image;
//                                
//                                NSDictionary *progressDictionary = [[NSDictionary alloc] initWithObjectsAndKeys:progressNumber, @"progress", progressImage, @"image", nil];
//                                
//                                NSString *notificationString = [NSString stringWithFormat:@"Progress:%@", notificationURL.relativeString];
//                                [[NSNotificationCenter defaultCenter] postNotificationName:notificationString object:progressDictionary];
//                            }
//                        }
//                        
//                        
//                    } success:^(NSURLSessionTask *task, id responseObject) {
//                        UIImage *responseImage = responseObject;
//                        
//                        if ([Utils notNull:image] && [Utils notNull:responseImage]) {
//                            [Defaults cache:type setObject:responseImage forKey:image];
//                        }
//                        
//                        [[CacheManager sharedManager] removeFromQueue:type forKey:image];
//                        
//                        NSURL *notificationURL = [[CacheManager sharedManager] imageURL:image type:type];
//                        if ([Utils notNull:notificationURL]) {
//                            [[NSNotificationCenter defaultCenter] postNotificationName:notificationURL.relativeString object:nil];
//                        }
//                        
//                        if(completionBlock) completionBlock(responseImage, image, nil);
//                        
//                    } failure:^(NSURLSessionTask *operation, NSError *error) {
//                        
//                        NSLog(@"FAILURE %@", url);
//                        [[CacheManager sharedManager] removeFromQueue:type forKey:image];
//                        if(completionBlock) completionBlock(nil, nil, error);
//                    }];
                }
                else {
                    if(completionBlock) completionBlock(nil, nil, nil);
                }
            }
            else {
                
            }
        }
    }
    else {
        if(completionBlock) completionBlock(nil, nil, nil);
    }
    
}

- (void)loadVideo:(NSString *)urlString type:(CacheType)type completion:(VideoDataBlock)completionBlock {
    
    
    NSURL *url = [NSURL URLWithString:urlString];
    
    if ([ABCommons notNull:urlString] && [ABCommons notNull:url]) {
        if ([ABCommons notNull: [[ABCacheManager sharedManager] getCache:type objectForKey:urlString]]) {
            if(completionBlock) completionBlock([[ABCacheManager sharedManager] getCache:type objectForKey:urlString], urlString, nil);
        }
        else {
//            AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
//            
//            NSURLRequest *request = [NSURLRequest requestWithURL:url];
//            
//            NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:^(NSProgress * _Nonnull downloadProgress) {
//                
//                //        if(progressBlock) {
//                //            progressBlock ([NSNumber numberWithDouble:downloadProgress.fractionCompleted]);
//                //        }
//                
//            } destination:^NSURL * _Nonnull(NSURL * _Nonnull targetPath, NSURLResponse * _Nonnull response) {
//                
//                NSURL *documentsDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSDocumentDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
//                return [documentsDirectoryURL URLByAppendingPathComponent:[response suggestedFilename]];
//                
//            } completionHandler:^(NSURLResponse * _Nonnull response, NSURL * _Nullable filePath, NSError * _Nullable error) {
//                
//                if(error) {
//                    if(completionBlock) completionBlock(nil, nil, error);
//                }
//                else {
//                    if ([Utils notNull:filePath.relativePath] && [Utils notNull:video]) {
//                        [Defaults cache:type setObject:filePath.relativePath forKey:video];
//                    }
//                    if(completionBlock) completionBlock(filePath.relativePath, video, nil);
//                }
//                
//            }];
//            
//            [downloadTask resume];
        }
    }
    else {
        if(completionBlock) completionBlock(nil, nil, nil);
    }
    
}

+ (void) removeDocumentsVideos {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/"];
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *string in array) {
        NSString *fullPath = [path stringByAppendingPathComponent:string];
        
        /// Make sure not to remove realm file
        if (![fullPath containsString:@"realm"]) {
            [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
        }
        
    }
}

- (NSCache *) cacheForType: (CacheType) type {
    switch (type) {
        case ImageCache:
            return imageCache;
            break;
        case VideoCache:
            return videoCache;
            break;
        case AudioCache:
            return audioCache;
            break;
        case GIFCache:
            return gifCache;
            break;
            
        default:
            return nil;
            break;
    }
}

- (NSCache *) queueForType: (CacheType) type {
    switch (type) {
        case ImageCache:
            return imageQueue;
            break;
        case VideoCache:
            return videoQueue;
            break;
        case AudioCache:
            return audioQueue;
            break;
        case GIFCache:
            return gifQueue;
            break;
            
        default:
            return nil;
            break;
    }
}

@end
