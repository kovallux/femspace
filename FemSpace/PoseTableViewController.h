//
//  PoseTableViewController.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/13/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MessageUI/MessageUI.h>

@interface PoseTableViewController : UITableViewController <UIActionSheetDelegate, MFMailComposeViewControllerDelegate, UISplitViewControllerDelegate>
{
}

@property (nonatomic, strong) NSMutableDictionary * pose;
@property (nonatomic, strong) NSString * poseTitle;
@property (nonatomic, strong) NSArray * poseSectionNames;
@property (nonatomic, strong) NSMutableArray * poseTexts;
@property (nonatomic, strong) NSString * favoritesButtonTitle;
@property (nonatomic, strong) NSString * addCommentsButtonTitle;
@property (nonatomic, assign) float rectHeight;
@property (nonatomic, strong) NSMutableArray * commentsArray;

@end
