//
//  CommentsVC.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/27/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CommentsViewController : UITableViewController

@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic, strong) NSMutableArray * messageDates;
@property (nonatomic, copy) NSString * poseTitle;

@end
