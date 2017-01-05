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
    
    self.mediaView.delegate = self;
    
    self.mediaView.backgroundColor = [UIColor blackColor];
    
    /// Changing the theme color changes the color of the play indicator as well as the progress track
    [self.mediaView setThemeColor:[UIColor redColor]];
    
    [self.mediaView setShowTrack:YES];
    
    [self.mediaView setAllowLooping:YES];
    
    self.mediaView.contentMode = UIViewContentModeScaleAspectFit;
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mediaView setImageURL:@"https://i.ytimg.com/vi/jkHI1hGvWRY/maxresdefault.jpg" withCompletion:^(UIImage *image, NSError *error) {
        
    }];
    
    [self.mediaView setVideoURL:@"http://clips.vorwaerts-gmbh.de/VfE_html5.mp4"];

}

- (void) playVideo {
    self.mediaView.image = nil;
}
@end
