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

@interface ABViewController : UIViewController <ABMediaViewDelegate>

/// Button to add a mediaView to the queue
@property (strong, nonatomic) IBOutlet UIButton *showMediaViewButton;

/// Adds a mediaView to the queue
- (IBAction)showMediaViewAction:(id)sender;
@end
