//
//  ABViewController.m
//  ABMediaView
//
//  Created by Andrew Boryk on 01/04/2017.
//  Copyright (c) 2017 Andrew Boryk. All rights reserved.
//

#import "ABViewController.h"

@interface ABViewController ()

@end

@implementation ABViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    


}

- (void) mediaViewDidPlayVideo: (ABMediaView *) mediaView {
    mediaView.image = nil;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    
    // Executes before and after rotation, that way any ABMediaViews can adjust their frames for the new size. Is especially helpful when users are watching landscape videos and rotate their devices between portrait and landscape.
    
    [coordinator animateAlongsideTransition:^(id  _Nonnull context) {
        
        // Notifies the ABMediaView that the device is about to rotate
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewWillRotateNotification object:nil];
        
    } completion:^(id  _Nonnull context) {
        
        // Notifies the ABMediaView that the device just finished rotating
        [[NSNotificationCenter defaultCenter] postNotificationName:ABMediaViewDidRotateNotification object:nil];
    }];
}
- (IBAction)showMediaViewAction:(id)sender {
    
    ABMediaView *mediaView = [[ABMediaView alloc] initWithFrame:self.view.frame];
    
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
    
    // Allows toggling for functionality which would allow the mediaView to be swiped away to the bottom right corner, and allows the user to keep scrolling which the mediaView sits there. Video continues to play if already playing. The user can also swipe right
    [mediaView setCanMinimize: YES];
    
    // Setting the contentMode to aspectFit will set the videoGravity to aspect as well
    mediaView.contentMode = UIViewContentModeScaleAspectFit;
    
    // If you desire to have the image to fill the view, however you would like the videoGravity to be aspect fit, then you can implement this functionality
    //    self.mediaView.contentMode = UIViewContentModeScaleAspectFill;
    //    [self.mediaView changeVideoToAspectFit: YES];
    
    // If the imageview is not in a reusable cell, and you wish that the image not disappear for a split second when reloaded, then you can enable this functionality
    mediaView.imageViewNotReused = YES;
    
    [mediaView setImageURL:@"http://camendesign.com/code/video_for_everybody/poster.jpg" withCompletion:^(UIImage *image, NSError *error) {
        
    }];
    
    [mediaView setVideoURL:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"];
    
    if ([[[ABMediaView sharedManager] mediaViewQueue] count]) {
        [[ABMediaView sharedManager] queueMediaView:mediaView];
        
        [[ABMediaView sharedManager] showNextMediaView];
    }
    else {
        [[ABMediaView sharedManager] queueMediaView:mediaView];
    }
    
}
@end
