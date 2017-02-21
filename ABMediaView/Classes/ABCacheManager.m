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

/// Different types of directory items
typedef NS_ENUM(NSInteger, DirectoryItemType) {
    VideoDirectoryItems,
    AudioDirectoryItems,
    AllDirectoryItems,
};

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
        [self resetAllCaches];
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

+ (void)loadGIF:(NSString *)urlString completion:(GIFDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = GIFCache;
        
        if ([ABCommons notNull:urlString]) {
            
            NSURL *url = [NSURL URLWithString:urlString];
            
            UIImage *fileImage = [ABCacheManager getCache:type objectForKey:urlString];
            if ([ABCommons notNull: fileImage]) {
                if(completionBlock) completionBlock(fileImage, urlString, nil);
            }
            else {
                if ([[ABCacheManager sharedManager] getQueue:type objectForKey:urlString] == nil) {
                    if ([ABCommons notNull:url]) {
                        
                        [[ABCacheManager sharedManager] addQueue:type object:urlString forKey:urlString];
                        
                        dispatch_queue_t downloadQueue = dispatch_queue_create("com.abdev.processimagequeue", NULL);
                        dispatch_async(downloadQueue, ^{
                            UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:url];
                            
                            if ([ABCommons notNull:urlString] && [ABCommons notNull:image] && [[ABCacheManager sharedManager] cacheMediaWhenDownloaded]) {
                                [[ABCacheManager sharedManager] setCache:type object:image forKey:urlString];
                            }
                            
                            [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                            
                            if(completionBlock) completionBlock(image, urlString, nil);
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
    
    });
    
}

+ (void)loadGIFData:(NSData *)data completion:(GIFDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
    
        if ([ABCommons notNull:data]) {
            
            dispatch_queue_t downloadQueue = dispatch_queue_create("com.abdev.processimagequeue", NULL);
            dispatch_async(downloadQueue, ^{
                UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data];
                if(completionBlock) completionBlock(image, nil, nil);
            });
        }
        else {
            if(completionBlock) completionBlock(nil, nil, nil);
        }
    });
}

+ (void)loadImage:(NSString *)urlString completion:(ImageDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = ImageCache;
        if ([ABCommons notBlank:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            
            UIImage *fileImage = [ABCacheManager getCache:type objectForKey:urlString];
            if ([ABCommons notNull: fileImage]) {
                if(completionBlock) completionBlock(fileImage, urlString, nil);
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
                                        if ([ABCommons notNull:urlString] && [ABCommons notNull:image] && [[ABCacheManager sharedManager] cacheMediaWhenDownloaded]) {
                                            [[ABCacheManager sharedManager] setCache:type object:image forKey:urlString];
                                        }
                                        
                                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                        
                                        if(completionBlock) completionBlock(image, urlString, nil);
                                    });
                                }
                            }
                        }];
                        
                        [task resume];
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
    });

}

+ (void)loadVideo:(NSString *)urlString completion:(VideoDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = VideoCache;
        
        if ([ABCommons notNull:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            
            if ([ABCommons notNull:url]) {
                
                NSString *testFilePath = [self directory:VideoDirectoryItems containsFile:url.lastPathComponent];
                if ([ABCommons notNull:testFilePath]) {
                    
                    [[ABCacheManager sharedManager] setCache:type object:testFilePath forKey:urlString];
                    [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                    if(completionBlock) completionBlock(testFilePath, urlString, nil);
                }
                else {
                    NSString *filePath = [ABCacheManager getCache:type objectForKey:urlString];
                    if ([ABCommons notNull: filePath]) {
                        if(completionBlock) completionBlock(filePath, urlString, nil);
                    }
                    else {
                        [ABCacheManager detectIfURL:url isValidForCacheType:type completion:^(BOOL isValidURL) {
                            if (isValidURL) {
                                //download the file in a seperate thread.
                                dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                    NSData *urlData = [NSData dataWithContentsOfURL:url];
                                    if (urlData)
                                    {
                                        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                        NSString *documentsDirectory = [paths objectAtIndex:0];
                                        
                                        NSString *directoryPath = [NSString stringWithFormat: @"%@/ABMedia/Video", documentsDirectory];
                                        
                                        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
                                            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
                                        
                                        NSString *uniqueFileName = urlString.lastPathComponent;
                                        
                                        NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, uniqueFileName];
                                        
                                        //saving is done on main thread
                                        dispatch_async(dispatch_get_main_queue(), ^{
                                            NSError * error = nil;
                                            BOOL success = [urlData writeToFile:filePath options:NSDataWritingAtomic error:&error];
                                            NSLog(@"Success = %d, error = %@", success, error);
                                            
                                            NSURL *cachedURL = [NSURL fileURLWithPath:filePath];
                                            
                                            if ([ABCommons notNull:urlString] && [ABCommons notNull:cachedURL]) {
                                                [[ABCacheManager sharedManager] setCache:type object:cachedURL forKey:urlString];
                                            }
                                            
                                            [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                            
                                            if(completionBlock) completionBlock(cachedURL, urlString, nil);
                                        });
                                    }
                                    
                                });
                            }
                            else {
                                if(completionBlock) completionBlock(nil, nil, nil);
                            }
                        }];
                        
                        
                    }
                }
            }
            else {
                if(completionBlock) completionBlock(nil, nil, nil);
            }
        }
        else {
            if(completionBlock) completionBlock(nil, nil, nil);
        }
        
        
    });
    
}

+ (void) loadAudio:(NSString *)urlString completion:(AudioDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = AudioCache;
        NSURL *url = [NSURL URLWithString:urlString];
        
        if ([ABCommons notNull:urlString] && [ABCommons notNull:url]) {
            NSString *testFilePath = [self directory:AudioDirectoryItems containsFile:url.lastPathComponent];
            if ([ABCommons notNull:testFilePath]) {
                
                [[ABCacheManager sharedManager] setCache:type object:testFilePath forKey:urlString];
                [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                if(completionBlock) completionBlock(testFilePath, urlString, nil);
            }
            else {
                NSString *filePath = [ABCacheManager getCache:type objectForKey:urlString];
                if ([ABCommons notNull: filePath]) {
                    if(completionBlock) completionBlock(filePath, urlString, nil);
                }
                else {
                    [ABCacheManager detectIfURL:url isValidForCacheType:type completion:^(BOOL isValidURL) {
                        if (isValidURL) {
                            //download the file in a seperate thread.
                            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                                NSData *urlData = [NSData dataWithContentsOfURL:url];
                                if (urlData)
                                {
                                    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                                    NSString *documentsDirectory = [paths objectAtIndex:0];
                                    
                                    NSString *directoryPath = [NSString stringWithFormat: @"%@/ABMedia/Audio", documentsDirectory];
                                    
                                    if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
                                        [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
                                    
                                    NSString *uniqueFileName = urlString.lastPathComponent;
                                    
                                    NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, uniqueFileName];
                                    
                                    //saving is done on main thread
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSError * error = nil;
                                        BOOL success = [urlData writeToFile:filePath options:NSDataWritingAtomic error:&error];
                                        NSLog(@"Success = %d, error = %@", success, error);
                                        
                                        NSURL *cachedURL = [NSURL fileURLWithPath:filePath];
                                        
                                        if ([ABCommons notNull:urlString] && [ABCommons notNull:cachedURL]) {
                                            [[ABCacheManager sharedManager] setCache:type object:cachedURL forKey:urlString];
                                        }
                                        
                                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                        
                                        if(completionBlock) completionBlock(cachedURL, urlString, nil);
                                    });
                                }
                                
                            });
                        }
                        else {
                            if(completionBlock) completionBlock(nil, nil, nil);
                        }
                    }];
                    
                    
                }
            }
            
        }
        else {
            if(completionBlock) completionBlock(nil, nil, nil);
        }
    });
}

+ (void) clearDirectory:(NSInteger)type {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/"];
    
    if (type == VideoDirectoryItems) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Video/"];
    }
    else if (type == AudioDirectoryItems) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Audio/"];
    }
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    for (NSString *string in array) {
        NSString *fullPath = [path stringByAppendingPathComponent:string];
        
        /// Make sure not to remove realm file
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
}

+ (NSString *) directory:(DirectoryItemType)type containsFile:(NSString *)fileEndingComponent {
    if ([ABCommons notNull:fileEndingComponent]) {
        NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/"];
        
        if (type == VideoDirectoryItems) {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Video/"];
            [[ABCacheManager sharedManager] resetCache:VideoCache];
        }
        else if (type == AudioDirectoryItems) {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Audio/"];
            [[ABCacheManager sharedManager] resetCache:AudioCache];
        }
        else {
            [[ABCacheManager sharedManager] resetCache:VideoCache];
            [[ABCacheManager sharedManager] resetCache:AudioCache];
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@", path, fileEndingComponent];
        
        NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
        if ([array containsObject:filePath]) {
            return filePath;
        }
    }
    
    return nil;
            
    
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

+ (void) detectIfURL:(NSURL *)url isValidForCacheType:(CacheType)type completion:(void (^)(BOOL isValidURL))completionBlock {
    NSURLRequest *request = [NSURLRequest requestWithURL: url];
    [NSURLConnection
     sendAsynchronousRequest:request
     queue:[[NSOperationQueue alloc] init]
     completionHandler:^(NSURLResponse *response,
                         NSData *data,
                         NSError *error)
     {
         
         if ([data length] >0 && error == nil)
         {
             NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
             
             if ([httpResponse respondsToSelector:@selector(allHeaderFields)]) {
                 NSDictionary *dictionary = [httpResponse allHeaderFields];
                 if ([ABCommons notNull:[dictionary valueForKey:@"content-type"]]) {
                     NSString *contentType = [dictionary valueForKey:@"content-type"];
                     if ([contentType containsString:@"video/"] && type == VideoCache) {
                         if (completionBlock) completionBlock(YES);
                     }
                     else if ([contentType containsString:@"audio/"] && type == AudioCache) {
                         if (completionBlock) completionBlock(YES);
                     }
                     else if ([contentType containsString:@"image/gif"] && type == GIFCache) {
                         if (completionBlock) completionBlock(YES);
                     }
                     else if ([contentType containsString:@"image/"] && type == ImageCache) {
                         if (completionBlock) completionBlock(YES);
                     }
                     else {
                         if (completionBlock) completionBlock(NO);
                     }
                 }
                 else {
                     if (completionBlock) completionBlock(NO);
                 }
             }
             else {
                 if (completionBlock) completionBlock(NO);
             }
         }
         else if ([data length] == 0 && error == nil)
         {
             NSLog(@"Nothing was downloaded.");
             if (completionBlock) completionBlock(NO);
         }
         else if (error != nil){
             NSLog(@"Error = %@", error);
             if (completionBlock) completionBlock(NO);
         }
         
     }];
}

- (void) setCacheMediaWhenDownloaded:(BOOL)cacheMediaWhenDownloaded {
    _cacheMediaWhenDownloaded = cacheMediaWhenDownloaded;
    
    if (!self.cacheMediaWhenDownloaded) {
        [self resetAllCaches];
    }
}

- (void) resetCache:(CacheType)type {
    switch (type) {
        case ImageCache:
            imageCache = [[NSCache alloc] init];
            break;
        case VideoCache:
            videoCache = [[NSCache alloc] init];
            break;
        case GIFCache:
            gifCache = [[NSCache alloc] init];
            break;
        case AudioCache:
            audioCache = [[NSCache alloc] init];
            break;
            
        default:
            break;
    }
}

- (void) resetAllCaches {
    imageCache = [[NSCache alloc] init];
    videoCache = [[NSCache alloc] init];
    audioCache = [[NSCache alloc] init];
    gifCache = [[NSCache alloc] init];
    
    imageQueue = [[NSCache alloc] init];
    videoQueue = [[NSCache alloc] init];
    audioQueue = [[NSCache alloc] init];
    gifQueue = [[NSCache alloc] init];
}

+ (id)getCache:(CacheType)type objectForKey:(NSString *)key {
    id cacheObject = [[ABCacheManager sharedManager] getCache:type objectForKey:key];
    
    if (type == VideoCache && [ABCommons isNull:cacheObject]) {
        if ([ABCommons notNull:key]) {
            NSURL *url = [NSURL URLWithString:key];
            
            cacheObject = [self directory:VideoDirectoryItems containsFile:url.lastPathComponent];
        }
    }
    
    return cacheObject;
}

+ (void)setCache:(CacheType)type object:(id)object forKey:(NSString *)key {
    [[ABCacheManager sharedManager] setCache:type object:object forKey:key];
}
@end
