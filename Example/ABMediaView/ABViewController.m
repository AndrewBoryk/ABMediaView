//
//  ABViewController.m
//  ABMediaView
//
//  Created by Andrew Boryk on 01/04/2017.
//  Copyright (c) 2017 Andrew Boryk. All rights reserved.
//

#import "ABViewController.h"
#import "ABAppDelegate.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface ABViewController () {
    
    /// Width of the screen in pixels
    CGFloat screenWidth;
    
    /// Height of the screen in pixels
    CGFloat screenHeight;
    
    /// Percentage of the screen that the status bar would take up
    CGFloat statusBarHeightPercentage;
}

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // Clear all of the documents directory of cached items
//    [ABMediaView clearABMediaDirectory:AllDirectoryItems];
    
    // Clear all of the temp directory of cached items
//    [ABMediaView clearABMediaDirectory:TempDirectoryItems];
    
    // Clear the video directory of cached items
//    [ABMediaView clearABMediaDirectory:VideoDirectoryItems];
    
    // Clear the audio directory of cached items
//    [ABMediaView clearABMediaDirectory:AudioDirectoryItems];
    
    // Cache media when downloaded
    [[ABMediaView sharedManager] setShouldCacheMedia:YES];
    
    // Loads the videos and audio before playing
//    [[ABMediaView sharedManager] setShouldPreloadVideoAndAudio:YES];
    
    // Sets functionality for this demonstration, visit the function to see different functionality
    [self initializeSettingsForMediaView:self.mediaView];
    
    // Toggle hiding the close button, that way it does not show up in fullscreen mediaView. This functionality is only allowed if isMinimizable is enabled.
//    [self.mediaView setHidesCloseButton:YES];
    
    // Setting which determines whether mediaView should pop up and display in full screen mode
    [self.mediaView setShouldDisplayFullscreen: YES];
    
    // If the frame of the mediaView is dynamic, and you would like it to present from the origin frame, then you can ensure this by setting the 'presentFromOriginRect' property to true. After this is set to true, there is no need to set the 'originRect' or 'originRectConverted' properties
    self.mediaView.presentFromOriginRect = YES;
    
    // This functionality toggles whether mediaViews with videos associated with them should autoPlay after presentation
    self.mediaView.autoPlayAfterPresentation = YES;
    
    // Toggle this functionality to enable/disable sound to play when an ABMediaView begins playing, and the user's app is on silent
    [ABMediaView setPlaysAudioWhenPlayingMediaOnSilent:YES];
    
    // In addition, toggle this functionality to enable/disable sound to play when an ABMediaView ends playing, and the user's app is on silent
    [ABMediaView setPlaysAudioWhenStoppingMediaOnSilent:NO];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];

    // Set certain measurement variables so they can be used later on
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    screenWidth = window.frame.size.width;
    screenHeight = window.frame.size.height;
    statusBarHeightPercentage = 20.0f/screenHeight;
    
    // Gifs can be displayed in ABMediaView, where the gif can be downloaded from the internet
    // [self.mediaView setGifURL:@"http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif"];
    
    // Gifs can also be displayed via NSData
    // NSData *gifData = ...;
    // [self.mediaView setGifData:gifData];
    
    // Set the url for the video that will be shown in the mediaView, it will download it and set it to the view. In addition, set the URL of the thumbnail for the video. Added functionality for preview GIFs when the user presses and holds.
    // Test for mp4: http://clips.vorwaerts-gmbh.de/VfE_html5.mp4
    // Test for mpg: http://techslides.com/demos/samples/sample.mpg NOT SUPPORTED
    // Test for mov: http://techslides.com/demos/samples/sample.mov
    // Test for swf: http://techslides.com/demos/samples/sample.swf NOT SUPPORTED
//    NSLog(@"Supported file types: %@", [AVURLAsset audiovisualTypes]);
//    NSLog(@"Supported MIME types: %@", [AVURLAsset audiovisualMIMETypes]);
    
    [self.mediaView setVideoURL:@"http://techslides.com/demos/samples/sample.mov" withThumbnailURL:@"http://camendesign.com/code/video_for_everybody/poster.jpg" andPreviewGifURL:@"https://i.makeagif.com/media/10-02-2015/TZiwZH.gif"];
    
//    [self.mediaView setVideoURL:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4" withThumbnailURL:@"http://camendesign.com/code/video_for_everybody/poster.jpg"];
    
    // Setting just the title allows for a label to be displayed at the top of the mediaView
    [self.mediaView setTitle:@"Big Buck Bunny"];
    
    // You can also set the video URL, download the video, and set a thumnail image that doesn't need to be downloaded
    // [self.mediaView setVideoURL:@"www.video.com/urlHere" withThumbnailImage:thumnailImage];
    
    // BONUS FUNCTIONALITY: If you want, you can also set a Gif as the thumnail, either by URL or NSData.
    // [self.mediaView setVideoURL:@"www.video.com/urlHere" withThumbnailGifURL:@"www.gif.com/urlHere"];
    // NSData *gifData = ...;
    // [self.mediaView setVideoURL:@"www.video.com/urlHere" withThumbnailGifData:gifData];
    
    // Rect that specifies where the mediaView's frame will originate from when presenting, and needs to be converted into its position in the mainWindow
//    self.mediaView.originRect = self.mediaView.frame;
    
}

- (IBAction)showGIFAction:(id)sender {
    ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
    
    // Sets functionality for this demonstration, visit the function to see different functionality
    [self initializeSettingsForMediaView:mediaView];
    
    // Adjust the size ratio for the minimized view of the fullscreen popup. By default, the minimized view is ABMediaViewRatioPresetLandscape
    mediaView.minimizedAspectRatio = ABMediaViewRatioPresetSquare;
    
    // Gifs can be displayed in ABMediaView, where the gif can be downloaded from the internet
    [mediaView setGifURL:@"http://static1.squarespace.com/static/552a5cc4e4b059a56a050501/565f6b57e4b0d9b44ab87107/566024f5e4b0354e5b79dd24/1449141991793/NYCGifathon12.gif"];
    
    // Present the mediaView, dismiss any other mediaView that is showing
    [[ABMediaView sharedManager] presentMediaView:mediaView];
}

- (IBAction)pickMediaAction:(id)sender {
    UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
    
    imagePicker.delegate = self;
    
    imagePicker.mediaTypes = [[NSArray alloc] initWithObjects:(NSString *)kUTTypeMovie, (NSString *)kUTTypeImage, nil];
    
    imagePicker.allowsEditing = NO;
    [self presentViewController:imagePicker animated:YES completion:nil];
}

- (IBAction)showAudioAction:(id)sender {
    ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
    
    // Sets functionality for this demonstration, visit the function to see different functionality
    [self initializeSettingsForMediaView:mediaView];
    
    // Adjust the size ratio for the minimized view of the fullscreen popup. By default, the minimized view is ABMediaViewRatioPresetLandscape
    mediaView.minimizedAspectRatio = ABMediaViewRatioPresetLandscape;
    
    // Adjust the ratio of the screen that the width of the minimized view will stretch across. The default value for this is 0.5
    mediaView.minimizedWidthRatio = 1.0f;
    
    // Add space to the bottom of the mediaView when it is minimized. By default, there is 12px of space. More can be added if it is desired to reserve space on the bottom for a UITabbar, UIToolbar, or other content.
    [mediaView setBottomBuffer:0.0f];
    
    // This functionality toggles whether mediaViews with videos associated with them should autoPlay after presentation
    mediaView.autoPlayAfterPresentation = YES;
    
    // Set the url for the audio that will be shown in the mediaView, it will download it and set it to the view. In addition, set the URL of the thumbnail for the audio.
//    http://techslides.com/demos/samples/sample.m4a
    [mediaView setAudioURL:@"https://a.tumblr.com/tumblr_ojs6z4VJp31u5escjo1.mp3" withThumbnailURL:@"http://www.popologynow.com/wp-content/uploads/2015/01/M_FallOutBoy_082214-3.jpg"];
    
    // Tile and details can be set for a mediaView, which displays labels on the top of the view
    [mediaView setTitle:@"\"The Take Over, The Breaks Over\"" withDetails:@"Fall Out Boy"];
    
    [mediaView preloadAudio];
    
    // Present the mediaView, dismiss any other mediaView that is showing
    [[ABMediaView sharedManager] presentMediaView:mediaView];
}

- (IBAction)pickAudioAction:(id)sender {
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes:MPMediaTypeMusic];
    mediaPicker.delegate = self;
    mediaPicker.showsCloudItems = NO;
    mediaPicker.allowsPickingMultipleItems = NO; // this is the default
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) initializeSettingsForMediaView: (ABMediaView *) mediaView {
    mediaView.delegate = self;
    
    mediaView.backgroundColor = [UIColor blackColor];
    
    // Changing the theme color changes the color of the play indicator as well as the progress track
    [mediaView setThemeColor:[UIColor redColor]];
    
    // Enable progress track to show at the bottom of the view
    [mediaView setShowTrack:YES];
    
    // Allow video to loop once reaching the end
    [mediaView setAllowLooping:YES];
    
    // Allows toggling for funtionality which would show remaining time instead of total time on the right label on the track
    [mediaView setShowRemainingTime:YES];
    
    // Allows toggling for functionality which would allow the mediaView to be swiped away to the bottom right corner, and allows the user to interact with the underlying interface while the mediaView sits there. Video continues to play if already playing, and the user can swipe right to dismiss the minimized view.
    [mediaView setIsMinimizable: YES];
    
    /// Change the font for the labels on the track
    [mediaView setTrackFont:[UIFont fontWithName:@"STHeitiTC-Medium" size:12.0f]];
    
    // Setting the contentMode to aspectFit will set the videoGravity to aspect as well
    mediaView.contentMode = UIViewContentModeScaleAspectFit;
    
    // If you desire to have the image to fill the view, however you would like the videoGravity to be aspect fit, then you can implement this functionality
    //    self.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    //    [self.mediaView changeVideoToAspectFit: YES];
    
    // If the imageview is not in a reusable cell, and you wish that the image not disappear for a split second when reloaded, then you can enable this functionality
    mediaView.imageViewNotReused = YES;
    
    // Adds a offset to the views at the top of the ABMediaView, which helps to make sure that the views do not block other views (ie. UIStatusBar)
    [mediaView setTopBuffer:ABBufferStatusBar];
}

#pragma mark - TransitionCoordinator

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Executes before and after rotation, that way any ABMediaViews can adjust their frames for the new size. Is especially helpful when users are watching landscape videos and rotate their devices between portrait and landscape.
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        
        // Notifies the ABMediaView that the device is about to rotate
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewWillRotateNotification object:nil];
        
    } completion:^(id  _Nonnull context) {
        
        // Change origin rect because the screen has rotated
//        self.mediaView.originRect = self.mediaView.frame;
        
        // Notifies the ABMediaView that the device just finished rotating
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewDidRotateNotification object:nil];
    }];
}

#pragma mark - ABMediaView Delegate

- (void) mediaView:(ABMediaView *)mediaView didChangeOffset:(float)offsetPercentage {
//    NSLog(@"MediaView offset changed: %f", offsetPercentage);
    
    if (![[UIApplication sharedApplication] isStatusBarHidden]) {
        if (offsetPercentage < (statusBarHeightPercentage*0.66f)) {
            if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleLightContent) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
            }
        }
        else {
            if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleDefault) {
                [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
            }
        }
    }
    
}

- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView {
//    NSLog(@"MediaView did play video");
}

- (void) mediaViewDidFailToPlayVideo:(ABMediaView *)mediaView {
//    NSLog(@"MediaView did fail to play video");
}

- (void) mediaViewDidPauseVideo:(ABMediaView *)mediaView {
//    NSLog(@"MediaView did pause video");
}

- (void) mediaViewWillPresent:(ABMediaView *)mediaView {
//    NSLog(@"MediaView will present");
}

- (void) mediaViewDidPresent:(ABMediaView *)mediaView {
//    NSLog(@"MediaView will present");
    
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Enable rotation when the ABMediaView is presented. For this application, we want the ABMediaView to rotate when in fullscreen, in order to watch landscape videos. However, our app's interface in portrait, so when the ABMediaView is shown, that is when rotation should be enabled
    [self restrictRotation:NO];
}

- (void) mediaViewWillDismiss:(ABMediaView *)mediaView {
//    NSLog(@"MediaView will dismiss");
    
    // Disable rotation when the ABMediaView is being dismissed. For this application, we want the ABMediaView to rotate when in fullscreen, in order to watch landscape videos. However, our app's interface in portrait, so when leaving the ABMediaView, we want rotation to be restricted
    [self restrictRotation:YES];
    
    NSNumber *value = [NSNumber numberWithInt:UIInterfaceOrientationPortrait];
    [[UIDevice currentDevice] setValue:value forKey:@"orientation"];
}

- (void) mediaViewDidDismiss:(ABMediaView *)mediaView {
//    NSLog(@"MediaView did dismiss");
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
}

- (void) mediaViewWillChangeMinimization:(ABMediaView *)mediaView {
//    NSLog(@"MediaView will minimize to a certain value");
}

- (void) mediaViewDidChangeMinimization:(ABMediaView *)mediaView {
//    NSLog(@"MediaView did minimize to a certain value");
}

- (void) mediaViewWillEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized {
//    NSLog(@"MediaView will snap to minimized mode? %i", isMinimized);
    
    [self restrictRotation:isMinimized];
}

- (void) mediaViewDidEndMinimizing:(ABMediaView *)mediaView atMinimizedState:(BOOL)isMinimized {
//    NSLog(@"MediaView snapped to minimized mode? %i", isMinimized);
    
    if (isMinimized) {
        if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleDefault) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
    else {
        if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
}

- (void) mediaView:(ABMediaView *)mediaView didSetImage:(UIImage *)image {
//    NSLog(@"Did set Image: %@", image);
}

- (void) mediaViewWillChangeDismissing:(ABMediaView *)mediaView {
//    NSLog(@"MediaView will change dismissing");
}

- (void) mediaViewDidChangeDismissing:(ABMediaView *)mediaView {
//    NSLog(@"MediaView did change dismissing");
}

- (void) mediaViewWillEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss {
//    NSLog(@"MediaView will end dismissing");
    
    [self restrictRotation:didDismiss];
}

- (void) mediaViewDidEndDismissing:(ABMediaView *)mediaView withDismissal:(BOOL)didDismiss {
//    NSLog(@"MediaView did end dismissing");
    
    if (didDismiss) {
        if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleDefault) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
        }
    }
    else {
        if ([[UIApplication sharedApplication] statusBarStyle] != UIStatusBarStyleLightContent) {
            [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
        }
    }
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadImage:(UIImage *)image {
//    NSLog(@"Did download Image: %@", image);
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadVideo:(NSString *)video {
//    NSLog(@"Did download Video path: %@", video);
}

- (void) mediaView:(ABMediaView *)mediaView didDownloadGif:(UIImage *)gif {
//    NSLog(@"Did download Gif: %@", gif);
}

- (void) handleTitleSelectionInMediaView:(ABMediaView *)mediaView {
//    NSLog(@"Title label was selected");
}

- (void) handleDetailsSelectionInMediaView:(ABMediaView *)mediaView {
//    NSLog(@"Details label was selected");
}

- (void) mediaPicker:(MPMediaPickerController *)mediaPicker didPickMediaItems:(MPMediaItemCollection *)mediaItemCollection {
    
    [self dismissViewControllerAnimated:YES completion:^{
        MPMediaItem *item = [[mediaItemCollection items] firstObject];
        NSURL *url = [item valueForProperty:MPMediaItemPropertyAssetURL];
        NSString *title = [item valueForProperty:MPMediaItemPropertyTitle];
        NSString *artist = [item valueForProperty:MPMediaItemPropertyArtist];
        
//        NSLog(@"MPMediaItemPropertyAssetURL %@", url);
        
        MPMediaItemArtwork *artWork = [item valueForProperty:MPMediaItemPropertyArtwork];
        
        ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
        
        // Sets functionality for this demonstration, visit the function to see different functionality
        [self initializeSettingsForMediaView:mediaView];
        
        // Adjust the size ratio for the minimized view of the fullscreen popup. By default, the minimized view is ABMediaViewRatioPresetLandscape
        mediaView.minimizedAspectRatio = ABMediaViewRatioPresetSquare;
        
        // This functionality toggles whether mediaViews with videos associated with them should autoPlay after presentation
        mediaView.autoPlayAfterPresentation = YES;
        
        // Set the url for the audio that will be shown in the mediaView, it will download it and set it to the view. In addition, set the URL of the thumbnail for the audio.
        [mediaView setAudioURL:url.relativeString withThumbnailImage:[artWork imageWithSize:CGSizeMake(screenWidth, screenWidth)]];
        
        // Setting just the title allows for a label to be displayed at the top of the mediaView
//         [mediaView setTitle:title];
        
        // Setting both the title and details displays two labels on the top of the mediaView
        [mediaView setTitle:title withDetails:artist];
        
//        mediaView.fileFromDirectory = YES;
        [mediaView preloadAudio];
        
        // Present the mediaView, dismiss any other mediaView that is showing
        [[ABMediaView sharedManager] presentMediaView:mediaView];
        
    }];
}

- (void) mediaPickerDidCancel:(MPMediaPickerController *)mediaPicker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(void) restrictRotation:(BOOL) restriction
{
    // An approach at determining whether the view should allow for rotation, when the ABMediaView is fullscreen, we want rotation to be enabled. However, if ABMediaView is not fullscreen, I don't want rotation to be allowed
    
    ABAppDelegate* appDelegate = (ABAppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

-(void)imagePickerController:
(UIImagePickerController *)picker
didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    
    if ([info objectForKey:UIImagePickerControllerMediaType] == (NSString *)kUTTypeImage) {
        // Image chosen
        
        UIImage *image = info[UIImagePickerControllerOriginalImage];
        
        ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
        
        // Sets functionality for this demonstration, visit the function to see different functionality
        [self initializeSettingsForMediaView:mediaView];
        
        // Allows toggling for functionality which would allow the mediaView to be swiped away to the bottom of the screen for dismissal. This variable overrides isMinimizable.
        [mediaView setIsDismissable: YES];
        
        // Set the image for the mediaView
        [mediaView setImage:image];
        
        // Present the mediaView, dismiss any other mediaView that is showing
        [[ABMediaView sharedManager] presentMediaView:mediaView];
        
        
    }
    else if ([info objectForKey:UIImagePickerControllerMediaType] == (NSString *)kUTTypeMovie){
        
        // Video chosen
        NSURL *url = [info objectForKey:UIImagePickerControllerMediaURL];
        AVAsset *videoAsset = [AVAsset assetWithURL:url];
        
        CGSize size = [[[videoAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] naturalSize];
        
        [picker dismissViewControllerAnimated:YES completion:^{
            ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
            
            // Sets functionality for this demonstration, visit the function to see different functionality
            [self initializeSettingsForMediaView:mediaView];
            
            // Adjust the size ratio for the minimized view of the fullscreen popup. By default, the minimized view is ABMediaViewRatioPresetLandscape. Aspect ratio can be custom calculated using Height/Width
            mediaView.minimizedAspectRatio = size.height/size.width;
            
            // This functionality toggles whether mediaViews with videos associated with them should autoPlay after presentation
            mediaView.autoPlayAfterPresentation = YES;
            
            // Set the url for the video that will be shown in the mediaView, it will be downloaded and set to the view. In addition, set the image of the thumbnail for the video.
            [mediaView setVideoURL:url.relativeString withThumbnailImage:[self generateThumbImage:url.relativeString]];
            
            // Present the mediaView, dismiss any other mediaView that is showing
            [[ABMediaView sharedManager] presentMediaView:mediaView];
        }];
        
    }
    
    [picker dismissViewControllerAnimated:NO completion:nil];
    
}

-(void)imagePickerControllerDidCancel:
(UIImagePickerController *)picker
{
    
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (UIImage *)generateThumbImage : (NSString *)filepath
{
    
    NSURL *url = [NSURL fileURLWithPath:filepath];
    
    AVAsset *asset = [AVAsset assetWithURL:url];
    AVAssetImageGenerator *imageGenerator = [[AVAssetImageGenerator alloc]initWithAsset:asset];
    imageGenerator.appliesPreferredTrackTransform = YES;
    
    CMTime time = CMTimeMakeWithSeconds(CMTimeGetSeconds([asset duration])/2.0f, 30);
    CGImageRef imageRef = [imageGenerator copyCGImageAtTime:time actualTime:NULL error:NULL];
    UIImage *thumbnail = [UIImage imageWithCGImage:imageRef];
    CGImageRelease(imageRef);  // CGImageRef won't be released by ARC
    
    return thumbnail;
}

@end
