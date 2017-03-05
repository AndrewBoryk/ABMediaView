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

/// Different types of directory items
typedef NS_ENUM(NSInteger, DirectoryItemType) {
    VideoDirectoryItems,
    AudioDirectoryItems,
    AllDirectoryItems,
    TempDirectoryItems,
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

- (id)getCache:(CacheType)type objectForKey:(NSString *)key {
    
    if ([ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                return [self.imageCache objectForKey:key];
                break;
            case VideoCache:
                return [self.videoCache objectForKey:key];
                break;
            case AudioCache:
                return [self.audioCache objectForKey:key];
                break;
            case GIFCache:
                return [self.gifCache objectForKey:key];
                break;
                
            default:
                return nil;
                break;
        }
        
    }
    
    return nil;
}

- (void)setCache:(CacheType)type object:(id)object forKey:(NSString *)key {
    
    if ([ABCommons notNull:object] && [ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                [self.imageCache setObject:object forKey:key];
                break;
            case VideoCache:
                [self.videoCache setObject:object forKey:key];
                break;
            case AudioCache:
                [self.audioCache setObject:object forKey:key];
                break;
            case GIFCache:
                [self.gifCache setObject:object forKey:key];
                break;
            default:
                
                break;
        }
        
    }
    
}

- (void)removeCache:(CacheType)type forKey:(NSString *)key {
    
    if ([ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                [self.imageCache removeObjectForKey:key];
                break;
            case VideoCache:
                [self.videoCache removeObjectForKey:key];
                break;
            case AudioCache:
                [self.audioCache removeObjectForKey:key];
                break;
            case GIFCache:
                [self.gifCache removeObjectForKey:key];
                break;
            
                
            default:
                
                break;
        }
        
    }
    
}

- (id)getQueue:(CacheType)type objectForKey:(NSString *)key {
    
    if ([ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                return [self.imageQueue objectForKey:key];
                break;
            case VideoCache:
                return [self.videoQueue objectForKey:key];
                break;
            case AudioCache:
                return [self.audioQueue objectForKey:key];
                break;
            case GIFCache:
                return [self.gifQueue objectForKey:key];
                break;
                
            default:
                return nil;
                break;
        }
        
    }
    
    return nil;
}

- (void)addQueue:(CacheType)type object:(id)object forKey:(NSString *)key {
    
    if ([ABCommons notNull:object] && [ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                [self.imageQueue setObject:object forKey:key];
                break;
            case VideoCache:
                [self.videoQueue setObject:object forKey:key];
                break;
            case AudioCache:
                [self.audioQueue setObject:object forKey:key];
                break;
            case GIFCache:
                [self.gifQueue setObject:object forKey:key];
                break;
                
            default:
                
                break;
        }
        
    }
    
}

- (void)removeFromQueue:(CacheType)type forKey:(NSString *)key {
    
    if ([ABCommons notNull:key]) {
        
        switch (type) {
            case ImageCache:
                [self.imageQueue removeObjectForKey:key];
                break;
            case VideoCache:
                [self.videoQueue removeObjectForKey:key];
                break;
            case AudioCache:
                [self.audioQueue removeObjectForKey:key];
                break;
            case GIFCache:
                [self.gifQueue removeObjectForKey:key];
                break;
                
            default:
                
                break;
        }
        
    }
    
}


+ (void)loadGIF:(NSString *)urlString completion:(GIFDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([ABCommons notNull:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            [ABCacheManager loadGIFURL:url completion:^(UIImage *gif, NSString *key, NSError *error) {
                
                if(completionBlock) completionBlock(gif, key, error);
                
            }];
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
    });
}

+ (void)loadGIFURL:(NSURL *)url completion:(GIFDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = GIFCache;
        
        if ([ABCommons notNull:url]) {
            
            NSString *urlString = url.absoluteString;
            
            UIImage *fileImage = [ABCacheManager getCache:type objectForKey:urlString];
            
            if ([ABCommons notNull: fileImage]) {
                
                if(completionBlock) completionBlock(fileImage, urlString, nil);
                
            } else {
                
                if ([[ABCacheManager sharedManager] getQueue:type objectForKey:urlString] == nil) {
                    
                    if ([ABCommons notNull:url]) {
                        
                        [[ABCacheManager sharedManager] addQueue:type object:urlString forKey:urlString];
                        
                        UIImage *image = [UIImage animatedImageWithAnimatedGIFURL:url];
                        
                        if ([ABCommons notNull:urlString] && [ABCommons notNull:image] && [[ABCacheManager sharedManager] cacheMediaWhenDownloaded]) {
                            [ABCacheManager setCache:type object:image forKey:urlString];
                        }
                        
                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                        
                        if(completionBlock) completionBlock(image, urlString, nil);
                        
                    } else {
                        
                        if(completionBlock) completionBlock(nil, nil, nil);
                        
                    }
                    
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
            
            UIImage *image = [UIImage animatedImageWithAnimatedGIFData:data];
            
            if(completionBlock) completionBlock(image, nil, nil);
            
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
        
    });
}

+ (void)loadImage:(NSString *)urlString completion:(ImageDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([ABCommons notNull:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            [ABCacheManager loadImageURL:url completion:^(UIImage *image, NSString *key, NSError *error) {
                
                if(completionBlock) completionBlock(image, key, error);
                
            }];
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
        
    });
}

+ (void)loadImageURL:(NSURL *)url completion:(ImageDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = ImageCache;
        
        if ([ABCommons notNull:url]) {
            NSString *urlString = url.absoluteString;
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
                                            [ABCacheManager setCache:type object:image forKey:urlString];
                                        }
                                        
                                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                        
                                        if(completionBlock) completionBlock(image, urlString, nil);
                                        
                                    });
                                }
                                
                            }
                            
                        }];
                        
                        [task resume];
                    } else {
                        
                        if(completionBlock) completionBlock(nil, nil, nil);
                        
                    }
                }
            }
        } else {
            if(completionBlock) completionBlock(nil, nil, nil);
        }
    });

}

+ (void)loadVideo:(NSString *)urlString completion:(AudioDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([ABCommons notNull:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            
            [ABCacheManager loadVideoURL:url completion:^(NSURL *videoPath, NSString *key, NSError *error) {
                
                if(completionBlock) completionBlock(videoPath, key, error);
                
            }];
            
        }
        else {
            if(completionBlock) completionBlock(nil, nil, nil);
        }
        
    });
}

+ (void)loadVideoURL:(NSURL *)url completion:(VideoDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = VideoCache;
        
        if ([ABCommons notNull:url]) {
            NSString *urlString = url.absoluteString;
            
            if ([ABCommons notNull:url]) {
                NSURL *filePath = [ABCacheManager getCache:type objectForKey:urlString];
                
                if ([ABCommons notNull: filePath]) {
                    [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                    
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
                                    
                                    NSError *error;
                                    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                                        [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                    }
                                    
                                    //saving is done on main thread
                                    dispatch_async(dispatch_get_main_queue(), ^{
                                        NSError * error = nil;
                                        BOOL success = [urlData writeToFile:filePath options:NSDataWritingAtomic error:&error];
//                                        NSLog(@"Success = %d, error = %@", success, error);
                                        
                                        if (success) {
                                            NSURL *cachedURL = [NSURL fileURLWithPath:filePath];
                                            
                                            if ([ABCommons notNull:urlString] && [ABCommons notNull:cachedURL]) {
                                                [ABCacheManager setCache:type object:cachedURL forKey:urlString];
                                            }
                                            
                                            [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                            
                                            if(completionBlock) completionBlock(cachedURL, urlString, nil);
                                            
                                        } else {
                                            [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                            
                                            if(completionBlock) completionBlock(nil, urlString, nil);
                                            
                                        }
                                        
                                    });
                                    
                                }
                                
                            });
                            
                        } else {
                            
                            if(completionBlock) completionBlock(nil, nil, nil);
                            
                        }
                    }];
                    
                    
                }
            } else {
                
                if(completionBlock) completionBlock(nil, nil, nil);
                
            }
        }
        else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
        
    });
    
}

+ (void)loadAudio:(NSString *)urlString completion:(AudioDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        
        if ([ABCommons notNull:urlString]) {
            NSURL *url = [NSURL URLWithString:urlString];
            [ABCacheManager loadAudioURL:url completion:^(NSURL *audioPath, NSString *key, NSError *error) {
                
                if(completionBlock) completionBlock(audioPath, key, error);
                
            }];
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
        
    });
}

+ (void)loadAudioURL:(NSURL *)url completion:(AudioDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = AudioCache;
        
        if ([ABCommons notNull:url]) {
            NSString *urlString = url.absoluteString;
            NSURL *filePath = [ABCacheManager getCache:type objectForKey:urlString];
            if ([ABCommons notNull: filePath]) {
                [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                
                if(completionBlock) completionBlock(filePath, urlString, nil);
                
            } else {
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
                                
                                NSError *error;
                                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                                }
                                
                                //saving is done on main thread
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    NSError * error = nil;
                                    BOOL success = [urlData writeToFile:filePath options:NSDataWritingAtomic error:&error];
//                                    NSLog(@"Success = %d, error = %@", success, error);
                                    if (success) {
                                        NSURL *cachedURL = [NSURL fileURLWithPath:filePath];
                                        
                                        if ([ABCommons notNull:urlString] && [ABCommons notNull:cachedURL]) {
                                            [ABCacheManager setCache:type object:cachedURL forKey:urlString];
                                        }
                                        
                                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                        
                                        if(completionBlock) completionBlock(cachedURL, urlString, nil);
                                        
                                    } else {
                                        [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                                        
                                        if(completionBlock) completionBlock(nil, urlString, nil);
                                        
                                    }
                                });
                                
                            }
                            
                        });
                        
                    } else {
                        
                        if(completionBlock) completionBlock(nil, nil, nil);
                        
                    }
                    
                }];
                
            }
            
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
        
    });
    
}

+ (void)loadMusicLibrary:(NSString *)urlString completion:(AudioDataBlock)completionBlock {
    dispatch_async(dispatch_get_main_queue(), ^{
        CacheType type = AudioCache;
        
        if ([ABCommons notNull:urlString]) {
            NSURL *filePathTest = [ABCacheManager getCache:type objectForKey:urlString];
            
            if ([ABCommons notNull: filePathTest]) {
                [[ABCacheManager sharedManager] removeFromQueue:type forKey:urlString];
                
                if(completionBlock) completionBlock(filePathTest, urlString, nil);
                
            } else {
                NSURL *url = [NSURL URLWithString:urlString];
                
                [[ABCacheManager sharedManager] addQueue:AudioCache object:urlString forKey:urlString];
                AVURLAsset *songAsset = [AVURLAsset URLAssetWithURL:url options:nil];
                AVAssetExportSession *exporter = [[AVAssetExportSession alloc]
                                                  initWithAsset: songAsset
                                                  presetName: AVAssetExportPresetAppleM4A];
                NSLog (@"created exporter. supportedFileTypes: %@", exporter.supportedFileTypes);
                exporter.outputFileType = @"com.apple.m4a-audio";
                
                NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
                NSString *documentsDirectory = [paths objectAtIndex:0];
                
                NSString *directoryPath = [NSString stringWithFormat: @"%@/ABMedia/Audio", documentsDirectory];
                
                if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
                    [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil]; //Create folder
                
                NSString *uniqueFileName = urlString.lastPathComponent;
                
                NSString *filePath = [NSString stringWithFormat:@"%@/%@.m4a", directoryPath, uniqueFileName];
                
                NSError *error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                }
                
                NSURL *exportURL = [NSURL fileURLWithPath:filePath];
                exporter.outputURL = exportURL;
                
                // do the export
                [exporter exportAsynchronouslyWithCompletionHandler:^{
                    [[ABCacheManager sharedManager] removeFromQueue:AudioCache forKey:urlString];
                    int exportStatus = exporter.status;
                    
                    switch (exportStatus) {
                        case AVAssetExportSessionStatusFailed: {
                            // log error to text view
                            NSError *exportError = exporter.error;
                            NSLog (@"AVAssetExportSessionStatusFailed: %@",
                                   exportError);
                            break;
                        }
                        case AVAssetExportSessionStatusCompleted: {
                            NSLog (@"AVAssetExportSessionStatusCompleted");
                            [ABCacheManager setCache:AudioCache object:exporter.outputURL forKey:urlString];
                            break;
                        }
                        case AVAssetExportSessionStatusUnknown: {
                            NSLog (@"AVAssetExportSessionStatusUnknown"); break;}
                        case AVAssetExportSessionStatusExporting: {
                            NSLog (@"AVAssetExportSessionStatusExporting"); break;}
                        case AVAssetExportSessionStatusCancelled: {
                            NSLog (@"AVAssetExportSessionStatusCancelled"); break;}
                        case AVAssetExportSessionStatusWaiting: {
                            NSLog (@"AVAssetExportSessionStatusWaiting"); break;}
                        default: { NSLog (@"didn't get export status"); break;}
                    }
                    
                }];
            }
            
        } else {
            
            if(completionBlock) completionBlock(nil, nil, nil);
            
        }
    });
    
}

+ (void)exportAssetURL:(NSString *)urlString type:(CacheType)type asset:(AVAsset *)asset {
    
    if (type == AudioCache) {
        //        AVURLAsset * asset = self.player.currentItem.asset;
        //        AVAssetExportSession * exportSession = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
        //        exportSession.outputFileType = AVFileTypeQuickTimeMovie;
        //        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //        NSString *documentsDirectory = [paths objectAtIndex:0];
        //
        //        NSString *directoryPath = [NSString stringWithFormat: @"%@/ABMedia/Audio", documentsDirectory];
        //
        //        if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
        //            [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
        //
        //        NSString *uniqueFileName = urlString.lastPathComponent;
        //
        //        NSString *filePath = [NSString stringWithFormat:@"%@/%@.mov", directoryPath, [uniqueFileName stringByDeletingPathExtension]];
        
        //        NSURL *outputURL = [NSURL fileURLWithPath:filePath];
        //        exportSession.outputURL = [NSURL fileURLWithPath:filePath];
        //        exportSession.metadata = asset.metadata;
        //        exportSession.shouldOptimizeForNetworkUse = YES;
        //        [exportSession exportAsynchronouslyWithCompletionHandler:^{
        //            NSLog(@"Output URL %@", exportSession.outputURL);
        //
        //            if (exportSession.status == AVAssetExportSessionStatusCompleted)
        //            {
        //                NSLog(@"AV export succeeded.");
        //            }
        //            else if (exportSession.status == AVAssetExportSessionStatusCancelled)
        //            {
        //                NSLog(@"AV export cancelled.");
        //            }
        //            else
        //            {
        //                NSLog(@"AV export failed with error: %@ (%ld)", exportSession.error, (long)exportSession.error.code);
        //            }
        //        }];
    } else if (type == VideoCache) {
        if ([ABCommons isNull:[ABCacheManager getCache:type objectForKey:urlString]]) {
            AVAssetExportSession *exporter;
            
            if (type == VideoCache) {
                exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetHighestQuality];
            } else if (type == AudioCache) {
                exporter = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetAppleM4A];
            }
            
            NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
            NSString *documentsDirectory = [paths objectAtIndex:0];
            
            NSString *directoryPath = [NSString stringWithFormat: @"%@/ABMedia/", documentsDirectory];
            
            if (type == VideoCache) {
                directoryPath = [directoryPath stringByAppendingString:@"Video"];
            } else if (type == AudioCache) {
                directoryPath = [directoryPath stringByAppendingString:@"Audio"];
            }
            
            if (![[NSFileManager defaultManager] fileExistsAtPath:directoryPath])
                [[NSFileManager defaultManager] createDirectoryAtPath:directoryPath withIntermediateDirectories:NO attributes:nil error:nil];
            
            NSString *uniqueFileName = urlString.lastPathComponent;
            
            NSString *filePath = [NSString stringWithFormat:@"%@/%@", directoryPath, uniqueFileName];
            
            exporter.outputURL = [NSURL fileURLWithPath:filePath];
            exporter.shouldOptimizeForNetworkUse = YES;
            exporter.outputFileType = AVFileTypeMPEG4;
            
            if ([ABCommons notNull:exporter.outputURL]) {
                
                NSError *error;
                if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
                    [[NSFileManager defaultManager] removeItemAtPath:filePath error:&error];
                }
                
                [exporter exportAsynchronouslyWithCompletionHandler:^{
                    NSLog(@"Output URL: %@", exporter.outputURL);
                    
                    switch ([exporter status]) {
                        case AVAssetExportSessionStatusFailed:
                            
                            NSLog(@"Export failed: %@", [[exporter error] localizedDescription]);
                            NSLog(@"%@", [[exporter error] localizedFailureReason]);
                            NSLog(@"Full: %@", [exporter error]);
                            NSLog(@"%@", [[exporter error] localizedRecoverySuggestion]);
                            break;
                        case AVAssetExportSessionStatusCancelled:
                            NSLog(@"Export canceled");
                            break;
                        default:
                            NSLog(@"Export succeded");
                            if ([ABCommons notNull:exporter.outputURL]) {
                                [ABCacheManager setCache:type object:exporter.outputURL forKey:urlString];
                            }
                            
                            break;
                    }
                    
                }];
            }
            
        }
        
    }
    
}

+ (void)clearDirectory:(NSInteger)type {
    NSString *path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/"];
    
    if (type == VideoDirectoryItems) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Video/"];
        [[ABCacheManager sharedManager] resetCache: VideoCache];
    } else if (type == AudioDirectoryItems) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Audio/"];
        [[ABCacheManager sharedManager] resetCache: AudioCache];
    } else if (type == TempDirectoryItems) {
        path = [NSHomeDirectory() stringByAppendingPathComponent:@"tmp/"];
    } else {
        [[ABCacheManager sharedManager] resetCache: VideoCache];
        [[ABCacheManager sharedManager] resetCache: AudioCache];
    }
    
    NSArray *array = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:path error:nil];
    
    for (NSString *string in array) {
        NSString *fullPath = [path stringByAppendingPathComponent:string];
        
        /// Make sure not to remove realm file
        [[NSFileManager defaultManager] removeItemAtPath:fullPath error:nil];
    }
    
}

+ (NSURL *)directory:(DirectoryItemType)type containsFile:(NSString *)fileEndingComponent {
    
    if ([ABCommons notNull:fileEndingComponent]) {
        NSString *path;
        
        if (type == VideoDirectoryItems) {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Video/"];
        } else if (type == AudioDirectoryItems) {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/Audio/"];
        } else {
            path = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/ABMedia/"];
        }
        
        NSString *filePath = [NSString stringWithFormat:@"%@%@", path, fileEndingComponent];
        
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            return [NSURL fileURLWithPath:filePath];
        }
    }
    
    return nil;
            
    
}

- (NSCache *)cacheForType:(CacheType)type {
    
    switch (type) {
        case ImageCache:
            return self.imageCache;
            break;
        case VideoCache:
            return self.videoCache;
            break;
        case AudioCache:
            return self.audioCache;
            break;
        case GIFCache:
            return self.gifCache;
            break;
            
        default:
            return nil;
            break;
    }
    
}

- (NSCache *)queueForType:(CacheType)type {
    
    switch (type) {
        case ImageCache:
            return self.imageQueue;
            break;
        case VideoCache:
            return self.videoQueue;
            break;
        case AudioCache:
            return self.audioQueue;
            break;
        case GIFCache:
            return self.gifQueue;
            break;
            
        default:
            return nil;
            break;
    }
    
}

+ (void)detectIfURL:(NSURL *)url isValidForCacheType:(CacheType)type completion:(void (^)(BOOL isValidURL))completionBlock {
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
                         
                     } else if ([contentType containsString:@"audio/"] && type == AudioCache) {
                         
                         if (completionBlock) completionBlock(YES);
                         
                     } else if ([contentType containsString:@"image/gif"] && type == GIFCache) {
                         
                         if (completionBlock) completionBlock(YES);
                         
                     } else if ([contentType containsString:@"image/"] && type == ImageCache) {
                         
                         if (completionBlock) completionBlock(YES);
                         
                     } else {
                         
                         if (completionBlock) completionBlock(NO);
                         
                     }
                     
                 } else {
                     
                     if (completionBlock) completionBlock(NO);
                     
                 }
                 
             } else {
                 
                 if (completionBlock) completionBlock(NO);
                 
             }
             
         } else if ([data length] == 0 && error == nil) {
             NSLog(@"Nothing was downloaded.");
             
             if (completionBlock) completionBlock(NO);
             
         } else if (error != nil) {
             NSLog(@"Error = %@", error);
        
             if (completionBlock) completionBlock(NO);
             
         }
         
     }];
    
}

- (void)setCacheMediaWhenDownloaded:(BOOL)cacheMediaWhenDownloaded {
    _cacheMediaWhenDownloaded = cacheMediaWhenDownloaded;
    
    if (!self.cacheMediaWhenDownloaded) {
        [self resetAllCaches];
    }
    
}

- (void)resetCache:(CacheType)type {
    
    switch (type) {
        case ImageCache:
            self.imageCache = [[NSCache alloc] init];
            break;
        case VideoCache:
            self.videoCache = [[NSCache alloc] init];
            break;
        case GIFCache:
            self.gifCache = [[NSCache alloc] init];
            break;
        case AudioCache:
            self.audioCache = [[NSCache alloc] init];
            break;
            
        default:
            break;
    }
    
}

- (void)resetAllCaches {
    self.imageCache = [[NSCache alloc] init];
    self.videoCache = [[NSCache alloc] init];
    self.audioCache = [[NSCache alloc] init];
    self.gifCache = [[NSCache alloc] init];
    
    self.imageQueue = [[NSCache alloc] init];
    self.videoQueue = [[NSCache alloc] init];
    self.audioQueue = [[NSCache alloc] init];
    self.gifQueue = [[NSCache alloc] init];
}

+ (id)getCache:(CacheType)type objectForKey:(NSString *)key {
    
    if ((type == VideoCache || type == AudioCache) && [[ABCacheManager sharedManager] isAllMediaFromSameLocation]) {
        if ([ABCommons notNull:key]) {
            if (type == VideoCache) {
                return [self directory:VideoDirectoryItems containsFile:key.lastPathComponent];
            } else if (type == AudioCache) {
                return [self directory:AudioDirectoryItems containsFile:key.lastPathComponent];
            }
        }
        
    } else {
        id cacheObject = [[ABCacheManager sharedManager] getCache:type objectForKey:key];
        
        return cacheObject;
    }
    
    return nil;
    
}

+ (void)setCache:(CacheType)type object:(id)object forKey:(NSString *)key {
    [[ABCacheManager sharedManager] setCache:type object:object forKey:key];
}

@end
