//
//  ACPopoverContentDelegate.h
//  WEPopover
//
//  Created by Alex Coplan on 13/07/2012.
//

#import <Foundation/Foundation.h>

@protocol ACPopoverContentDelegate <NSObject>

- (void)userSelectedRowInPopover:(NSUInteger)row;

@end
