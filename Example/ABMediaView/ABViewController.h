//
//  ABViewController.h
//  ABMediaView
//
//  Created by Andrew Boryk on 01/04/2017.
//  Copyright (c) 2017 Andrew Boryk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <ABMediaView/ABMediaView.h>
#import <MediaPlayer/MediaPlayer.h>
@interface ABViewController : UIViewController <ABMediaViewDelegate, MPMediaPickerControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>

/// Button to add a mediaView for to the queue
@property (strong, nonatomic) IBOutlet UIButton *showGIFButton;

/// Button to select the type of media to display
@property (strong, nonatomic) IBOutlet UIButton *pickMediaButton;

/// Button to show how audio is displayed
@property (strong, nonatomic) IBOutlet UIButton *showAudioButton;

/// Button to select audio to display
@property (strong, nonatomic) IBOutlet UIButton *pickAudioButton;

/// MediaView to demonstrate how mediaViews can pop up
@property (strong, nonatomic) IBOutlet ABMediaView *mediaView;

/// Adds a mediaView for a GIF to the queue
- (IBAction)showGIFAction:(id)sender;

/// Pick media, then adds a mediaView for that media to the queue
- (IBAction)pickMediaAction:(id)sender;

/// Shows how audio would look by adding a mediaView with audio to the queue
- (IBAction)showAudioAction:(id)sender;

/// Pick audio, then adds a mediaView for that audio to the queue
- (IBAction)pickAudioAction:(id)sender;

@end
