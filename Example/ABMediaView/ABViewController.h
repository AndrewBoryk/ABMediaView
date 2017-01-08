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
#import <ABMediaView/ABMediaViewController.h>

@interface ABViewController : UIViewController <ABMediaViewDelegate>

@property (strong, nonatomic) IBOutlet ABMediaView *mediaView;

@end
