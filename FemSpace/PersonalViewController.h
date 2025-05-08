//
//  PersonalViewController.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/20/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "EAIntroView.h"

@interface PersonalViewController : UITableViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate, EAIntroDelegate>
{
    UIDatePicker * datePicker1;
    UIDatePicker * datePicker2;
}

@property (nonatomic, strong) NSArray * sectionNames;
@property (nonatomic, strong) NSArray * rowNames;


// Main dictionary
@property (nonatomic, strong) NSMutableDictionary * personalData;

// first section initial texts
@property (nonatomic, strong) NSString * imageName;

@property (nonatomic, strong) NSString * name;
@property (nonatomic, strong) NSString * lastName;
@property (nonatomic, strong) NSString * birthday;
@property (nonatomic, strong) NSString * age;
@property (nonatomic, strong) NSString * email;

@property (nonatomic, strong) NSString * menstruationDate;
@property (nonatomic, strong) NSString * childBirthday;
@property (nonatomic, strong) NSString * childSex;

@property (nonatomic) BOOL firstRunAccount;

// Date pickers
@property (nonatomic, retain) UIDatePicker * datePicker1;
@property (nonatomic, retain) UIDatePicker * datePicker2;

@property (nonatomic, strong) UIActivityIndicatorView * activityView;

// Zodiac properties
@property (nonatomic, strong) NSString * dateZodiac1;
@property (nonatomic, strong) NSString * dateZodiac2;
@property (nonatomic, strong) NSString * titleZodiac;
@property (nonatomic, strong) NSString * imageZodiac;
@property (nonatomic, strong) NSString * elementZodiac;
@property (nonatomic, strong) NSString * elementImageZodiac;

// Parse.com
//@property (nonatomic) BOOL personalDataSaved;

@end
