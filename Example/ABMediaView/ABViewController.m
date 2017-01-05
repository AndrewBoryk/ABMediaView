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
    
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void) viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self.mediaView setImageURL:@"http://cdn3-www.cattime.com/assets/uploads/2011/08/best-kitten-names-1.jpg" withCompletion:^(UIImage *image, NSError *error) {
        
    }];
    
    [self.mediaView setThemeColor:[UIColor redColor]];
    
    [self.mediaView setShowTrack:YES];
    
    [self.mediaView setAllowLooping:YES];
    
    self.mediaView.contentMode = UIViewContentModeScaleAspectFit;
    
    [self.mediaView setVideoURL:@"http://techslides.com/demos/sample-videos/small.mp4"];

}
@end
