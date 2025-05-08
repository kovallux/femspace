//
//  Week.h
//  FemSpace
//
//  Created by Сергей Коваль on 4/3/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface WeekViewController : UITableViewController <UIWebViewDelegate>

@property (nonatomic, strong) UIWebView * youTubeWebView;

// controller title
@property (nonatomic, strong) NSString * weekTitle;
@property (nonatomic) NSInteger sectionNumber;
@property (nonatomic, assign) CGFloat imageHeight;

// week data
@property (nonatomic, strong) NSMutableDictionary * week;
@property (nonatomic, strong) NSMutableArray * weekTexts;

// week dictionary
@property (nonatomic, strong) NSString * childImage;
@property (nonatomic, strong) NSString * bodyImage;
@property (nonatomic) BOOL bodyImageExists;
@property (nonatomic, strong) NSString * didYouKnowImage;
@property (nonatomic) BOOL didYouKnowImageExists;
@property (nonatomic, strong) NSString * checklist1;
@property (nonatomic, strong) NSString * checklist2;
@property (nonatomic, strong) NSString * checklist3;
@property (nonatomic, strong) NSString * checklist4;
@property (nonatomic) BOOL checklist4Exists;
@property (nonatomic, strong) NSString * yourChildText;
@property (nonatomic, strong) NSString * didYouKnowText;
@property (nonatomic, strong) NSString * yourBodyText;
@property (nonatomic, strong) NSString * payAttentionText;
@property (nonatomic, strong) NSString * videoUrl;
@property (nonatomic) BOOL videoUrlExists;

@end
