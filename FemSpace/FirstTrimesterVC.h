//
//  BirthCalendar.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/27/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"
#import "SMPageControl.h"
#import <MessageUI/MessageUI.h>

@interface FirstTrimesterVC : UITableViewController <EAIntroDelegate>

// флаг для определения первого запуска
@property(nonatomic) BOOL firstRun;

@property (nonatomic, strong) NSString * childBirthday;

// week data
@property (nonatomic, strong) NSMutableDictionary * week;
@property (nonatomic, strong) NSMutableArray * weekTexts;
@property (nonatomic, strong) NSString * childImage;

@end
