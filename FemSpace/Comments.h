//
//  BirthCalendar.h
//  PregnaSutra
//
//  Created by Сергей Коваль on 3/23/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RDRStickyKeyboardView.h"

@interface Comments : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (nonatomic, strong) NSMutableArray * messages;
@property (nonatomic, copy) NSString * poseTitle;
@property (nonatomic, strong) IBOutlet UITableView * tableView;
@property (nonatomic, strong) RDRStickyKeyboardView * contentWrapper;

@end
