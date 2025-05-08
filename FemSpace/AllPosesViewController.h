//
//  FirstViewController.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/12/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "WEPopoverController.h"
#import "WEPopover.h"
#import "ACPopoverContentDelegate.h"

@class WEPopoverController;
@class PoseTableViewController;

@interface AllPosesViewController : UITableViewController <WEPopoverControllerDelegate, ACPopoverContentDelegate>
{
    WEPopoverController * popoverController;
    Class popoverClass;
}

@property (nonatomic) NSInteger trimesterNumberNext;
@property (nonatomic, strong) NSArray * posesListArray;
@property (nonatomic, strong) NSArray * posesList1;
@property (nonatomic, strong) NSArray * posesList2;
@property (nonatomic, strong) NSArray * posesList3;
@property (nonatomic, strong) NSArray * sectionTitles;

@property (nonatomic, strong) WEPopoverController * popoverController;
@property (nonatomic, assign) NSUInteger filterIndex;
@property (nonatomic, assign) float sectionHeight;

@property (strong, nonatomic) PoseTableViewController * poseViewController;

- (IBAction)onButtonFilterClick:(UIButton *)button;

@end
