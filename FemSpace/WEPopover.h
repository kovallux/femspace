//
//  WEPopoverContentViewController.h
//  WEPopover
//
//  Created by Werner Altewischer on 06/11/10.
//  Copyright 2010 Werner IT Consultancy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ACPopoverContentDelegate.h"

@interface WEPopover : UITableViewController {
    
    NSUInteger checkmark;
    
}

@property (nonatomic, retain) NSObject<ACPopoverContentDelegate> * contentDelegate;
@property (nonatomic, assign) NSUInteger checkmark;

@end
