//
//  PersonalViewController.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/20/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "PersonalViewController.h"
#import "Constants.h"
#import "FirstTrimesterVC.h"
#import "BDKNotifyHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"

//#import "PregnaIAPHelper.h"
//#import <StoreKit/StoreKit.h>

//#warning Save to Parse
//#warning Store date as NSDate
// FIXME: Store date as NSDate

@interface PersonalViewController () {
    NSArray * _products;
    NSDateFormatter * dateFormatter;
    NSDateFormatter * zodiacDateFormatter;
    NSString * savedFilePath;
}

    @property (strong, nonatomic) BDKNotifyHUD * notify;
    @property (strong, nonatomic) NSString * imageNameHUD;
    @property (strong, nonatomic) NSString * notificationTextBirthday;
    @property (strong, nonatomic) NSString * notificationTextEmail;

@end

@implementation PersonalViewController
{
    BOOL _datePicker1Visible;
    BOOL _datePicker2Visible;
    BOOL _zodiacCellVisible;
}

@synthesize personalData;
@synthesize datePicker1, datePicker2;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }
    
    dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterLongStyle;

    [dateFormatter setLocale:[NSLocale currentLocale]];
    [dateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    zodiacDateFormatter = [[NSDateFormatter alloc] init];
    [zodiacDateFormatter setDateFormat:@"dd.MM.yyyy"];
    [zodiacDateFormatter setLocale:[NSLocale currentLocale]];
    //[zodiacDateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    [zodiacDateFormatter setTimeZone:[NSTimeZone systemTimeZone]];
    
    /*
    #warning Turn it off before final release.
    // Force In-Apps already purchased
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.kovallux.PregnaSutraiPhoneRU.ChildData"];
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"com.kovallux.PregnaSutraiPhoneRU.PregnancyCalendar"];
    [[NSUserDefaults standardUserDefaults] synchronize];
     */
    
    UIBarButtonItem * btnHint = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Помощь", nil) style:UIBarButtonItemStylePlain target:self action:@selector(showIntroWithFixedTitleViewDelegate)];
    [self.navigationItem setLeftBarButtonItem:btnHint animated:YES];
    
    /*
    UIBarButtonItem * btnRefresh = [[UIBarButtonItem alloc] initWithTitle:NSLocalizedString(@"Покупки", nil) style:UIBarButtonItemStylePlain target:self action:@selector(refreshTapped)];
    [self.navigationItem setRightBarButtonItem:btnRefresh animated:YES];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.ChildData"] == YES &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.PregnancyCalendar"] == YES) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
     */
    
    self.notificationTextBirthday = NSLocalizedString(@"Сначала введите ваш День\n рождения", nil);
    self.notificationTextEmail = NSLocalizedString(@"Неправильный email", nil);
    self.imageNameHUD = @"noHUD";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDatePicker1)
                                                 name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(hideDatePicker2)
                                                 name:UIKeyboardWillShowNotification object:nil];
    
    _datePicker1Visible = NO;
    _datePicker2Visible = NO;
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zodiacCellVisible"] == YES) {
        _zodiacCellVisible = YES;
    } else {
        _zodiacCellVisible = NO;
    }
    
    _sectionNames = @[NSLocalizedString(@"SETTINGS", @"Settings section title"),
                      NSLocalizedString(@"МОИ ДАННЫЕ", nil),
                      NSLocalizedString(@"Беременность и пол ребенка", nil),
                      ];
    
    _rowNames = @[NSLocalizedString(@"Введите ваше имя", @"Введите ваше имя"),
                  NSLocalizedString(@"Введите вашу фамилию", nil),
                  NSLocalizedString(@"Введите дату рождения", nil),
                  @"",
                  NSLocalizedString(@"Введите ваш email", nil),
                  
                  NSLocalizedString(@"Введите 1-й день менструации2", nil),
                  @"",
                  NSLocalizedString(@"Дата родов", nil),
                  NSLocalizedString(@"Пол ребенка", @"Пол ребенка"),
                  @"",
                  //NSLocalizedString(@"Календарь беременности", nil),
                  ];
    
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    savedFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"MyData.plist", nil)]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
    
    if([fileManager fileExistsAtPath:savedFilePath])
    {
        
        if (![personalData objectForKey:@"imageName"]) {
            _imageName = @"";
        }
        else {
        _imageName = [personalData objectForKey:@"imageName"];
        }
        
        if (![personalData objectForKey:@"name"]) {
            _name = @"";
        }
        else {
        _name = [personalData objectForKey:@"name"];
        }
        
        if (![personalData objectForKey:@"lastName"]) {
            _lastName = @"";
        }
        else {
        _lastName = [personalData objectForKey:@"lastName"];
        }
        
        if (![personalData objectForKey:@"birthday"]) {
            _birthday = @"";
        }
        else {
        _birthday = [personalData objectForKey:@"birthday"];
        }
        
        if (![personalData objectForKey:@"age"]) {
            _age = @"";
        }
        else {
            _age = [personalData objectForKey:@"age"];
        }
        
        if (![personalData objectForKey:@"email"]) {
            _email = @"";
        }
        else {
        _email = [personalData objectForKey:@"email"];
        }
        
        if (![personalData objectForKey:@"childBirthday"]) {
            _childBirthday = @"";
        }
        else {
        _childBirthday = [personalData objectForKey:@"childBirthday"];
        }
        
        if (![personalData objectForKey:@"menstruationDate"]) {
            _menstruationDate = @"";
        }
        else {
        _menstruationDate = [personalData objectForKey:@"menstruationDate"];
        }
        
        if (![personalData objectForKey:@"childSex"]) {
            _childSex = @"";
        }
        else {
        _childSex = [personalData objectForKey:@"childSex"];
        }
        if (![personalData objectForKey:@"zodiac"]) {
            _titleZodiac = @"";
        }
        else {
            
            _titleZodiac = [personalData objectForKey:@"zodiac"];
            
            NSMutableArray * allZodiacs = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"ZodiacSigns", nil) ofType:@"plist"]];
            //NSLog(@"allZodiacs: %lu", (unsigned long)[allZodiacs count]);
            for (int i = 0; i < [allZodiacs count]; i++)
            {
                NSMutableDictionary * sign = [allZodiacs objectAtIndex:i];
                NSMutableString * currentCat = [sign objectForKey:@"title"];
                
                if ([currentCat isEqualToString:_titleZodiac]) {
                    _imageZodiac = [sign objectForKey:@"image"];
                    _dateZodiac1 = [sign objectForKey:@"date1"];
                    _dateZodiac2 = [sign objectForKey:@"date2"];
                    _elementZodiac = [sign objectForKey:@"element"];
                    _elementImageZodiac = [sign objectForKey:@"elementImage"];
                }
            }
        }
    }
    else {
        
        _imageName = @"";
        _name = @"";
        _lastName = @"";
        _birthday = @"";
        _age = @"";
        _email = @"";
        _childBirthday = @"";
        _menstruationDate = @"";
        _childSex = @"";
        _titleZodiac = @"";
        _imageZodiac = @"";
        _dateZodiac1 = @"";
        _dateZodiac2 = @"";
        _elementZodiac = @"";
        _elementImageZodiac = @"";
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    
    if (![[NSUserDefaults standardUserDefaults] objectForKey:@"firstRunAccount"]){
        self.firstRunAccount = TRUE;
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:@"firstRunAccount"];
        [self showIntro];
    }else{
        self.firstRunAccount = FALSE;
    }
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = NSLocalizedString(@"Про ребёнка", nil);
    
    /*
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(productPurchased:) name:IAPHelperProductPurchasedNotification object:nil];
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.ChildData"] == YES &&
        [[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.PregnancyCalendar"] == YES) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    } else {
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
     */
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:YES];
    //NSLog (@"scrollToPaidContent BEFORE = %@", [[NSUserDefaults standardUserDefaults] boolForKey:@"scrollToPaidContent"] ? @"YES" : @"NO");
    
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"scrollToPaidContent"] == YES) {
        NSIndexPath * paidIndexPath1 = [NSIndexPath indexPathForRow:2 inSection:1];
        UITableViewCell * cell1 = [self.tableView cellForRowAtIndexPath:paidIndexPath1];
        [self.tableView scrollToRowAtIndexPath:paidIndexPath1 atScrollPosition:UITableViewScrollPositionTop animated:YES];
        NSIndexPath * paidIndexPath2 = [NSIndexPath indexPathForRow:3 inSection:1];
        UITableViewCell * cell2 = [self.tableView cellForRowAtIndexPath:paidIndexPath2];
        
        cell1.backgroundColor = PURPLE_COLOR;
        cell1.textLabel.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:1.0f
                         animations:^{
                             cell1.backgroundColor = [UIColor whiteColor];
                         }
                         completion:nil];
        
        cell2.backgroundColor = PURPLE_COLOR;
        cell2.textLabel.backgroundColor = [UIColor clearColor];
        [UIView animateWithDuration:1.0f
                         animations:^{
                             cell2.backgroundColor = [UIColor whiteColor];
                         }
                         completion:nil];
        
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"scrollToPaidContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];

}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:YES];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_sectionNames count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return [_sectionNames objectAtIndex:section];
    }
    if (section == 1) {
        return nil;
    }
    return [_sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if (section == 1) {
        return 5;
    }
    else {
        return 5;
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return 44.0f;
    }
    else if (indexPath.section == 2 && indexPath.row == 1) {
        return _datePicker2Visible ? 217.0f : 0.0f;
    }
    else if (indexPath.section == 2 && indexPath.row == 4) {
        return _zodiacCellVisible ? 44.0f : 0.0f;
    }
    else if (indexPath.section == 1 && indexPath.row == 3) {
        return _datePicker1Visible ? 217.0f : 0.0f;
    }
    else {
        return 44.0f;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath;
    }
    else if (indexPath.section == 1) {
        if (indexPath.row == 3) {
            return nil;
        }
        else {
            return indexPath;
        }
    }
    else {
        if (indexPath.row == 0) {
            return indexPath;
        }
        else {
            return nil;
        }
    }
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 1) {
        
        UIView * headerView = [[UIView alloc] init];
        
        NSFileManager * fileManager = [NSFileManager defaultManager];
        
        if([fileManager fileExistsAtPath:savedFilePath])
        {
            if (![[personalData objectForKey:@"imageName"] isEqualToString: @""]) {
                personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
                
                NSString * docPath = [NSSearchPathForDirectoriesInDomains (NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
                NSString * filePath=[NSString stringWithFormat:@"%@/%@", docPath, [personalData objectForKey:@"imageName"]];
                UIImage * personImage = [UIImage imageWithContentsOfFile:filePath];
                
                UIImageView * personImageView = [[UIImageView alloc] initWithImage:personImage];
                personImageView.contentMode = UIViewContentModeScaleAspectFill;
                CALayer * l = [personImageView layer];
                [l setMasksToBounds:YES];
                [l setCornerRadius:50.0];
                [l setBorderWidth:1.0];
                [l setBorderColor:[PINK_COLOR CGColor]];
                personImageView.alpha = 1.0f;
                [headerView addSubview:personImageView];

                personImageView.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [personImageView.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
                    [personImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:10.0],
                    [personImageView.widthAnchor constraintEqualToConstant:100.0],
                    [personImageView.heightAnchor constraintEqualToConstant:100.0]
                ]];
                
                UIButton * addButton = [[UIButton alloc] init];
                addButton.alpha = 1.0f;
                [addButton setImage:[UIImage imageNamed:@"transparentButton.png"] forState:UIControlStateNormal];
                [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateHighlighted];
                [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateSelected];
                addButton.showsTouchWhenHighlighted = YES;
                [addButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:addButton];

                addButton.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [addButton.centerXAnchor constraintEqualToAnchor:personImageView.centerXAnchor],
                    [addButton.centerYAnchor constraintEqualToAnchor:personImageView.centerYAnchor],
                    [addButton.widthAnchor constraintEqualToAnchor:personImageView.widthAnchor],
                    [addButton.heightAnchor constraintEqualToAnchor:personImageView.heightAnchor]
                ]];
                
                UILabel * personFirstSectionLabel = [[UILabel alloc] init];
                personFirstSectionLabel.font = [UIFont systemFontOfSize:14.0];
                personFirstSectionLabel.numberOfLines = 1;
                personFirstSectionLabel.backgroundColor = [UIColor clearColor];
                personFirstSectionLabel.textAlignment = NSTextAlignmentLeft;
                NSString *currentSectionTitle = [_sectionNames objectAtIndex:section];
                personFirstSectionLabel.text = [currentSectionTitle uppercaseString];
                personFirstSectionLabel.textColor = GRAY_COLOR;
                [headerView addSubview:personFirstSectionLabel];

                personFirstSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [personFirstSectionLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:15.0],
                    [personFirstSectionLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-15.0],
                    [personFirstSectionLabel.topAnchor constraintEqualToAnchor:personImageView.bottomAnchor constant:15.0],
                    [personFirstSectionLabel.heightAnchor constraintEqualToConstant:22.0]
                ]];
            }
            else {
                UIImage * personImage = [UIImage imageNamed:@"AddImage.jpg"];
                UIImageView * personImageView = [[UIImageView alloc] initWithImage:personImage];
                personImageView.contentMode = UIViewContentModeScaleAspectFill;
                CALayer * l = [personImageView layer];
                [l setMasksToBounds:YES];
                [l setCornerRadius:50.0];
                [l setBorderWidth:1.0];
                [l setBorderColor:[PINK_COLOR CGColor]];
                personImageView.alpha = 0.2f;
                [headerView addSubview:personImageView];

                personImageView.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [personImageView.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
                    [personImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:10.0],
                    [personImageView.widthAnchor constraintEqualToConstant:100.0],
                    [personImageView.heightAnchor constraintEqualToConstant:100.0]
                ]];
                
                UIButton * addButton = [[UIButton alloc] init];
                addButton.alpha = 1.0f;
                [addButton setImage:[UIImage imageNamed:@"transparentButton.png"] forState:UIControlStateNormal];
                [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateHighlighted];
                [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateSelected];
                addButton.showsTouchWhenHighlighted = YES;
                [addButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
                [headerView addSubview:addButton];

                addButton.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [addButton.centerXAnchor constraintEqualToAnchor:personImageView.centerXAnchor],
                    [addButton.centerYAnchor constraintEqualToAnchor:personImageView.centerYAnchor],
                    [addButton.widthAnchor constraintEqualToAnchor:personImageView.widthAnchor],
                    [addButton.heightAnchor constraintEqualToAnchor:personImageView.heightAnchor]
                ]];
                
                UILabel * personFirstSectionLabel = [[UILabel alloc] init];
                personFirstSectionLabel.font = [UIFont systemFontOfSize:14.0];
                personFirstSectionLabel.numberOfLines = 1;
                personFirstSectionLabel.backgroundColor = [UIColor clearColor];
                personFirstSectionLabel.textAlignment = NSTextAlignmentLeft;
                NSString *currentSectionTitle = [_sectionNames objectAtIndex:section];
                personFirstSectionLabel.text = [currentSectionTitle uppercaseString];
                personFirstSectionLabel.textColor = GRAY_COLOR;
                [headerView addSubview:personFirstSectionLabel];

                personFirstSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
                [NSLayoutConstraint activateConstraints:@[ 
                    [personFirstSectionLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:15.0],
                    [personFirstSectionLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-15.0],
                    [personFirstSectionLabel.topAnchor constraintEqualToAnchor:personImageView.bottomAnchor constant:15.0],
                    [personFirstSectionLabel.heightAnchor constraintEqualToConstant:22.0]
                ]];
            }
        }
        else {
            
            UIImage * personImage = [UIImage imageNamed:@"AddImage.jpg"];
            UIImageView * personImageView = [[UIImageView alloc] initWithImage:personImage];
            personImageView.contentMode = UIViewContentModeScaleAspectFill;
            CALayer * l = [personImageView layer];
            [l setMasksToBounds:YES];
            [l setCornerRadius:50.0];
            [l setBorderWidth:1.0];
            [l setBorderColor:[PINK_COLOR CGColor]];
            personImageView.alpha = 0.2f;
            [headerView addSubview:personImageView];

            personImageView.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[ 
                [personImageView.centerXAnchor constraintEqualToAnchor:headerView.centerXAnchor],
                [personImageView.topAnchor constraintEqualToAnchor:headerView.topAnchor constant:10.0],
                [personImageView.widthAnchor constraintEqualToConstant:100.0],
                [personImageView.heightAnchor constraintEqualToConstant:100.0]
            ]];
            
            UIButton * addButton = [[UIButton alloc] init];
            addButton.alpha = 1.0f;
            [addButton setImage:[UIImage imageNamed:@"transparentButton.png"] forState:UIControlStateNormal];
            [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateHighlighted];
            [addButton setImage:[UIImage imageNamed:@"transparentButton2.png"] forState:UIControlStateSelected];
            addButton.showsTouchWhenHighlighted = YES;
            [addButton addTarget:self action:@selector(addImage) forControlEvents:UIControlEventTouchUpInside];
            [headerView addSubview:addButton];

            addButton.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[ 
                [addButton.centerXAnchor constraintEqualToAnchor:personImageView.centerXAnchor],
                [addButton.centerYAnchor constraintEqualToAnchor:personImageView.centerYAnchor],
                [addButton.widthAnchor constraintEqualToAnchor:personImageView.widthAnchor],
                [addButton.heightAnchor constraintEqualToAnchor:personImageView.heightAnchor]
            ]];
            
            UILabel * personFirstSectionLabel = [[UILabel alloc] init];
            personFirstSectionLabel.font = [UIFont systemFontOfSize:14.0];
            personFirstSectionLabel.numberOfLines = 1;
            personFirstSectionLabel.backgroundColor = [UIColor clearColor];
            personFirstSectionLabel.textAlignment = NSTextAlignmentLeft;
            NSString *currentSectionTitle = [_sectionNames objectAtIndex:section];
            personFirstSectionLabel.text = [currentSectionTitle uppercaseString];
            personFirstSectionLabel.textColor = GRAY_COLOR;
            [headerView addSubview:personFirstSectionLabel];

            personFirstSectionLabel.translatesAutoresizingMaskIntoConstraints = NO;
            [NSLayoutConstraint activateConstraints:@[ 
                [personFirstSectionLabel.leadingAnchor constraintEqualToAnchor:headerView.leadingAnchor constant:15.0],
                [personFirstSectionLabel.trailingAnchor constraintEqualToAnchor:headerView.trailingAnchor constant:-15.0],
                [personFirstSectionLabel.topAnchor constraintEqualToAnchor:personImageView.bottomAnchor constant:15.0],
                [personFirstSectionLabel.heightAnchor constraintEqualToConstant:22.0]
            ]];
        }
        
        return headerView;
        
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return UITableViewAutomaticDimension;
        return 40.0f;
    }
    else if (section == 1) {
        return 160.0f;
    }
    else {
        return UITableViewAutomaticDimension;
        return 40.0f;
    }
}


// TODO: оптимизировать все if's
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if (indexPath.section == 0) { // SETTINGS Section
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"SettingsCell"];
        }
        cell.textLabel.text = NSLocalizedString(@"Select Language", @"Select language row title");
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textColor = [UIColor blackColor]; // Or your desired color
        return cell;
    }
    // Existing logic, but section indices are now +1
    else if ([fileManager fileExistsAtPath:savedFilePath])
    {
        personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
        
        if (indexPath.section == 1) { // МОИ ДАННЫЕ (was section 0)
            if (indexPath.row == 0) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (![[personalData objectForKey:@"name"] isEqualToString: @""]) {
                    cell.textLabel.text = [personalData objectForKey:@"name"];
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; // row 0
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                return cell;
            }
            else if (indexPath.row == 1) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (![[personalData objectForKey:@"lastName"] isEqualToString: @""]) {
                    cell.textLabel.text = [personalData objectForKey:@"lastName"];
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; // row 1
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                return cell;
            }
            else if (indexPath.row == 2) {
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"AgeCell" forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (![_birthday isEqualToString: @""]) {
                    cell.textLabel.text = _birthday;
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
                    cell.detailTextLabel.text = _age;
                    cell.imageView.image = nil;
                    cell.accessoryView = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; // row 2
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                return cell;
            }
            else if (indexPath.row == 3) { // DatePicker1 placeholder
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.textLabel.text = nil;
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            else { // indexPath.row == 4 (Email)
                UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                if (![[personalData objectForKey:@"email"] isEqualToString: @""]) {
                    cell.textLabel.text = [personalData objectForKey:@"email"];
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; // row 4
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                }
                return cell;
            }
        }
        else { // Section 2 - Беременность и пол ребенка (was section 1)
            // Adjust _rowNames indexing: original _rowNames was flat, so access by original index (indexPath.row + 5)
            if (indexPath.row == 0) { // Menstruation Date
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                if (![[personalData objectForKey:@"menstruationDate"] isEqualToString: @""]) {
                    cell.textLabel.text = [personalData objectForKey:@"menstruationDate"];
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5]; // row 0+5 = 5
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                }
                return cell;
            }
            else if (indexPath.row == 1) { // DatePicker2 placeholder
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.textLabel.text = @"";
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
            else if (indexPath.row == 2) { // Child Birthday
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                if (![[personalData objectForKey:@"childBirthday"] isEqualToString: @""]) {
                    NSString *childDate = personalData[@"childBirthday"] ? personalData[@"childBirthday"] : @"";
                    // _rowNames[7] is "Дата родов"
                    NSString *arrayTex = _rowNames[7] ? _rowNames[7] : @""; 
                    NSString *rowText = [NSString stringWithFormat:@"%@: %@", arrayTex, childDate];
                    // ... existing attributed text logic ...
                    if ([cell.textLabel respondsToSelector:@selector(setAttributedText:)]) {
                        NSDictionary * attribs = @{ NSForegroundColorAttributeName: cell.textLabel.textColor, NSFontAttributeName: cell.textLabel.font };
                        NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:rowText attributes:attribs];
                        UIColor * defaultColor = [UIColor blackColor];
                        UIFont * normalFont = [UIFont systemFontOfSize:FONT_SIZE];
                        NSRange defaultTextRange = [rowText rangeOfString:arrayTex];
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:defaultColor, NSFontAttributeName:normalFont} range:defaultTextRange];
                        UIColor * color = PURPLE_COLOR;
                        UIFont * boldFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
                        NSRange textRange = [rowText rangeOfString:childDate];
                        if (textRange.length > 0 && textRange.location != NSNotFound) {
                            [attributedText setAttributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:boldFont} range:textRange];
                        }
                        cell.textLabel.attributedText = attributedText;
                        cell.textLabel.adjustsFontSizeToFitWidth = YES;
                    }
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5]; // row 2+5 = 7
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                return cell;
            }
            else if (indexPath.row == 3) { // Child Sex
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                if ([fileManager fileExistsAtPath:savedFilePath] && ![[personalData objectForKey:@"childSex"] isEqualToString: @""]) {
                    NSString * childSex = [personalData objectForKey:@"childSex"];
                    NSString * arrayTex = [_rowNames objectAtIndex:8]; // row 3+5 = 8
                    NSString * rowText = [NSString stringWithFormat:@"%@: %@", arrayTex, childSex];
                     // ... existing attributed text logic ...
                    if ([cell.textLabel respondsToSelector:@selector(setAttributedText:)]) {
                        NSDictionary * attribs = @{ NSForegroundColorAttributeName: cell.textLabel.textColor, NSFontAttributeName: cell.textLabel.font };
                        NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:rowText attributes:attribs];
                        UIColor * defaultColor = [UIColor blackColor];
                        UIFont * normalFont = [UIFont systemFontOfSize:FONT_SIZE];
                        NSRange defaultTextRange = [rowText rangeOfString:arrayTex];
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:defaultColor, NSFontAttributeName:normalFont} range:defaultTextRange];
                        UIColor * color = PURPLE_COLOR;
                        UIFont * boldFont = [UIFont boldSystemFontOfSize:FONT_SIZE];
                        NSRange textRange = [rowText rangeOfString:childSex];
                        [attributedText setAttributes:@{NSForegroundColorAttributeName:color, NSFontAttributeName:boldFont} range:textRange];
                        cell.textLabel.attributedText = attributedText;
                    }
                    cell.accessoryType = UITableViewCellAccessoryNone;
                    cell.imageView.image = nil;
                }
                else {
                    cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5]; // row 3+5 = 8
                    cell.textLabel.textColor = [UIColor lightGrayColor];
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                return cell;
            }
            else { // indexPath.row == 4 (Zodiac)
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AgeCell" forIndexPath:indexPath];
                if ([[NSUserDefaults standardUserDefaults] boolForKey:@"zodiacCellVisible"] == YES) {
                    cell.textLabel.text = _titleZodiac;
                    cell.detailTextLabel.text = [NSString stringWithFormat:@"%@\t", _elementZodiac];
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
                    cell.imageView.image = [UIImage imageNamed:_imageZodiac];
                    UIImageView * imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_elementImageZodiac]];
                    cell.accessoryView = imageView;
                } else {
                    cell.textLabel.text = nil;
                    cell.detailTextLabel.text = nil;
                    cell.imageView.image = nil;
                    cell.accessoryView = nil;
                }
                cell.accessoryType = UITableViewCellAccessoryNone;
                return cell;
            }
        }
    }
    else // File doesn't exist - default placeholders
    {
        if (indexPath.section == 1) { // МОИ ДАННЫЕ (was section 0)
            if (indexPath.row == 0) {
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row];
                cell.textLabel.textColor = [UIColor lightGrayColor];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.imageView.image = nil;
                return cell;
            }
            // ... similar adjustments for other rows in section 1 when file doesn't exist ...
            else if (indexPath.row == 1) { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; cell.textLabel.textColor = [UIColor lightGrayColor]; cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; cell.imageView.image = nil; return cell;}
            else if (indexPath.row == 2) { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AgeCell" forIndexPath:indexPath]; cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; cell.textLabel.textColor = [UIColor lightGrayColor]; cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; cell.detailTextLabel.text = @""; cell.imageView.image = nil; cell.accessoryView = nil; return cell;}
            else if (indexPath.row == 3) { UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.textLabel.text = @""; cell.accessoryType = UITableViewCellAccessoryNone; return cell;}
            else { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row]; cell.textLabel.textColor = [UIColor lightGrayColor]; cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator; cell.imageView.image = nil; return cell;}
        }
        else { // Section 2 - Беременность и пол ребенка (was section 1)
            if (indexPath.row == 0) {
                UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5];
                cell.imageView.image = nil;
                cell.textLabel.textColor = [UIColor lightGrayColor];
                return cell;
            }
            // ... similar adjustments for other rows in section 2 when file doesn't exist ...
            else if (indexPath.row == 1) { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.textLabel.text = @""; cell.accessoryType = UITableViewCellAccessoryNone; return cell; }
            else if (indexPath.row == 2) { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.accessoryType = UITableViewCellAccessoryNone; cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5]; cell.imageView.image = nil; cell.textLabel.textColor = [UIColor lightGrayColor]; return cell; }
            else if (indexPath.row == 3) { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell4" forIndexPath:indexPath]; cell.accessoryType = UITableViewCellAccessoryNone; cell.textLabel.text = [_rowNames objectAtIndex:indexPath.row + 5]; cell.imageView.image = nil; cell.textLabel.textColor = [UIColor lightGrayColor]; return cell; }
            else { UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"AgeCell" forIndexPath:indexPath]; cell.textLabel.text = nil; cell.detailTextLabel.text = nil; cell.imageView.image = nil; cell.accessoryView = nil; cell.accessoryType = UITableViewCellAccessoryNone; return cell; }
        }
    }
}

#pragma mark - Navigation
 
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) { // SETTINGS Section
        if (indexPath.row == 0) { // Select Language row
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Select Language", @"Select language alert title")
                                                                           message:nil
                                                                    preferredStyle:UIAlertControllerStyleActionSheet];
            
            // Assuming English is default for now, add a checkmark or similar indicator
            // For simplicity, we'll just use text. Actual selection persistence is not implemented here.
            UIAlertAction *englishAction = [UIAlertAction actionWithTitle:@"🇬🇧 English" 
                                                                    style:UIAlertActionStyleDefault
                                                                  handler:^(UIAlertAction * _Nonnull action) {
                                                                      //NSLog(@"English selected");
                                                                      // TODO: Implement language change logic if needed
                                                                  }];
            UIAlertAction *ukrainianAction = [UIAlertAction actionWithTitle:@"🇺🇦 Ukrainian"
                                                                      style:UIAlertActionStyleDefault
                                                                    handler:^(UIAlertAction * _Nonnull action) {
                                                                        //NSLog(@"Ukrainian selected");
                                                                        // TODO: Implement language change logic if needed
                                                                    }];
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"Cancel", nil) 
                                                                   style:UIAlertActionStyleCancel
                                                                 handler:nil];
            
            [alert addAction:englishAction];
            [alert addAction:ukrainianAction];
            [alert addAction:cancelAction];
            
            // For iPad, to prevent crashes
            if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad) {
                UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
                alert.popoverPresentationController.sourceView = cell;
                alert.popoverPresentationController.sourceRect = cell.bounds;
                alert.popoverPresentationController.permittedArrowDirections = UIPopoverArrowDirectionAny;
            }
            
            [self presentViewController:alert animated:YES completion:nil];
        }
    }
    // Adjust existing logic for new section indices
    else if (indexPath.section == 1) { // МОИ ДАННЫЕ (was section 0)
        if (_datePicker2Visible) { // Check for datePicker2 in the *other* section
            [self hideDatePicker2];
        }
        if (indexPath.row == 0) { // Name
            // ... existing UIAlertView logic for name ...
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите имя", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil]; alert.alertViewStyle = UIAlertViewStylePlainTextInput; alert.tag = 0; UITextField * alertTextField = [alert textFieldAtIndex:0]; alertTextField.keyboardType = UIKeyboardTypeDefault; alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; alertTextField.placeholder = NSLocalizedString(@"Ваше имя", nil); [alert show];
        }
        if (indexPath.row == 1) { // Last Name
            // ... existing UIAlertView logic for last name ...
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите Фамилию", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil]; alert.alertViewStyle = UIAlertViewStylePlainTextInput; alert.tag = 1; UITextField * alertTextField = [alert textFieldAtIndex:0]; alertTextField.keyboardType = UIKeyboardTypeDefault; alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; alertTextField.placeholder = NSLocalizedString(@"Ваша фамилия", nil); [alert show];
        }
        if (indexPath.row == 2) { // Birthday
            if (!_datePicker1Visible){ [self showDatePicker1]; } else { [self hideDatePicker1]; }
        }
        if (indexPath.row == 4) { // Email
            // ... existing UIAlertView logic for email ...
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите Email", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil]; alert.alertViewStyle = UIAlertViewStylePlainTextInput; alert.tag = 2; UITextField * alertTextField = [alert textFieldAtIndex:0]; alertTextField.keyboardType = UIKeyboardTypeDefault; alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords; alertTextField.placeholder = NSLocalizedString(@"Ваш email", nil); [alert show];
        }
    }
    else if (indexPath.section == 2) { // Беременность и пол ребенка (was section 1)
        if (_datePicker1Visible) { // Check for datePicker1 in the *other* section
            [self hideDatePicker1];
        }
        if (indexPath.row == 0) { // Menstruation Date
            // ... existing logic for menstruation date / datePicker2 ...
            NSFileManager * fileManager = [NSFileManager defaultManager]; personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath]; if(![fileManager fileExistsAtPath:savedFilePath] || [[personalData objectForKey:@"birthday"] isEqualToString: @""]) { BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:self.imageNameHUD] text:self.notificationTextBirthday]; hud.center = CGPointMake(self.view.center.x, self.view.center.y - 20); AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate]; [appDelegate.window addSubview:hud]; [hud presentWithDuration:2.0f speed:0.5f inView:self.view completion:^{[hud removeFromSuperview];}]; } else { if (!_datePicker2Visible){ [self showDatePicker2]; } else { [self hideDatePicker2]; } }
        }
    }
    
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
}

#pragma mark - AlertView methods

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    if (buttonIndex == 0){
        return;
    }
    
    if (buttonIndex == 1) {
        if (alertView.tag == 0) {
            NSString * detailString = [[alertView textFieldAtIndex:0] text];
            _name = detailString;
            [self savePersonalData];
        }
        if (alertView.tag == 1) {
            NSString * detailString = [[alertView textFieldAtIndex:0] text];
            _lastName = detailString;
            [self savePersonalData];
        }
        if (alertView.tag == 2) {
            NSString * detailString = [[alertView textFieldAtIndex:0] text];
            _email = detailString;
            [self savePersonalData];
            [self validateEmail:detailString];
        }
    }
}

- (BOOL) validateEmail: (NSString *) email
{
    NSString * emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate * emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
    BOOL isValid = [emailTest evaluateWithObject:email];
    
    if (!isValid) {
        // Create the HUD notification
        BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:self.imageNameHUD] text:self.notificationTextEmail];
        hud.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
        AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        [appDelegate.window addSubview:hud];
        [hud presentWithDuration:1.5f speed:0.5f inView:self.view completion:^{
            [hud removeFromSuperview];
        }];
    }
    return isValid;
}


#pragma mark - Add Image / Save data

- (void)savePersonalData {
    personalData = [[NSMutableDictionary alloc] init];
    [personalData setValue:_imageName forKey:@"imageName"];
    [personalData setValue:_name forKey:@"name"];
    [personalData setValue:_lastName forKey:@"lastName"];
    [personalData setValue:_birthday forKey:@"birthday"];
    [personalData setValue:_age forKey:@"age"];
    [personalData setValue:_email forKey:@"email"];
    [personalData setValue:_childBirthday forKey:@"childBirthday"];
    [personalData setValue:_menstruationDate forKey:@"menstruationDate"];
    [personalData setValue:_childSex forKey:@"childSex"];
    [personalData setValue:_titleZodiac forKey:@"zodiac"];
    
    [personalData writeToFile:savedFilePath atomically:YES];
    [self.tableView reloadData];
}

- (void) addImage {
    UIImagePickerController * picker = [[UIImagePickerController alloc] init];
	picker.delegate = self;
    picker.sourceType = UIImagePickerControllerSourceTypeSavedPhotosAlbum;
	[self presentViewController:picker animated:YES completion:nil];
}

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage *pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    NSData *imageData = UIImagePNGRepresentation(pickedImage);
    
    NSString *documentsDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    NSString *path = [documentsDirectory stringByAppendingPathComponent:@"imageName.png"];
    
    NSError * error = nil;
    [imageData writeToFile:path options:NSDataWritingAtomic error:&error];
    
    if (error != nil) {
        NSLog(@"Error: %@", error);
        return;
    }
    else {
        _imageName = @"imageName.png";
        [self savePersonalData];
    }
}

#pragma mark - Date Picker 1 methods

- (void)showDatePicker1 {
    
    NSIndexPath * dateRowIndexPath = [NSIndexPath indexPathForRow:2 inSection:1];
    NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:dateRowIndexPath.row + 1 inSection:dateRowIndexPath.section];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:dateRowIndexPath];
    UITableViewCell * pickerCell = [self.tableView cellForRowAtIndexPath:pickerIndexPath];
    cell.textLabel.textColor = PINK_COLOR;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
    
    datePicker1 = [[UIDatePicker alloc] init];
    datePicker1.datePickerMode = UIDatePickerModeDate;
    
    // Set the preferred style to wheels
    if (@available(iOS 13.4, *)) {
        datePicker1.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }
    // For older iOS versions, .wheels is the default and only style, 
    // but it's good practice to be explicit if a specific style is desired.
    
    NSDateComponents * comps = [[NSDateComponents alloc] init];
    [comps setYear: -18];
    NSDate * maxDate = [[NSCalendar currentCalendar] dateByAddingComponents:comps toDate:[NSDate date]  options:0];
    
    datePicker1.maximumDate = maxDate;
    [datePicker1 addTarget:self action:@selector(picker1Change) forControlEvents:UIControlEventValueChanged];
    [pickerCell.contentView addSubview:datePicker1];
    
    if (![fileManager fileExistsAtPath:savedFilePath] || [[personalData objectForKey:@"birthday"] isEqualToString: @""] || ![personalData objectForKey:@"birthday"])
    {
        [datePicker1 setDate:[NSDate date] animated:YES];
        NSString * datelabel = [dateFormatter stringFromDate:[NSDate date]];
        cell.textLabel.text = datelabel;
    }
    else {
        NSString * savedDateString = [personalData objectForKey:@"birthday"];
        NSDate * savedDate = [dateFormatter dateFromString:savedDateString];
        [datePicker1 setDate:savedDate animated:YES];
        cell.textLabel.text = savedDateString;
    }
    
    _datePicker1Visible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    datePicker1.hidden = NO;
    datePicker1.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{
        datePicker1.alpha = 1.0f;
    }];
    
    [self.tableView scrollToRowAtIndexPath:dateRowIndexPath atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (void)hideDatePicker1 {
    if (_datePicker1Visible) {
        
        _datePicker1Visible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [UIView animateWithDuration:0.25 animations:^{
            datePicker1.alpha = 0.0f;
        } completion:^(BOOL finished) {
            datePicker1.hidden = YES;
            datePicker1 = nil;
        }];
    }
}


- (void) picker1Change {
    NSString * datelabel = [dateFormatter stringFromDate:datePicker1.date];
    _birthday = datelabel;
    
    NSDateComponents * ageComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                       fromDate:datePicker1.date
                                                                         toDate:[NSDate date]
                                                                        options:0];
    NSInteger year = [ageComponents year]; // Real age
    
    NSString * lastDigit = [[NSString stringWithFormat:@"%ld", (long)year] substringFromIndex:1];
    
    if ([lastDigit isEqualToString:@"0"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"1"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld год", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"2"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld года", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"3"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld года", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"4"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld года", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"5"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"6"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"7"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"8"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    if ([lastDigit isEqualToString:@"9"]) {
        _age = [NSString stringWithFormat:NSLocalizedString(@"%ld лет", nil), (long)year];
    }
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
    
    if([fileManager fileExistsAtPath:savedFilePath] &&
       ![[personalData objectForKey:@"birthday"] isEqualToString: @""] &&
       ![[personalData objectForKey:@"menstruationDate"] isEqualToString: @""]) {
        
        NSLog(@"Dates: %@ • %@", _birthday, [personalData objectForKey:@"menstruationDate"]);
        
        NSString * savedMenstruationDateString = [personalData objectForKey:@"menstruationDate"];
        NSDate * savedMenstruationDate = [dateFormatter dateFromString:savedMenstruationDateString];
        NSDateComponents * menstruationMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:savedMenstruationDate];
        NSInteger month = [menstruationMonth month];
        
        NSDateComponents * ageCalcComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                           fromDate:datePicker1.date
                                                                             toDate:savedMenstruationDate
                                                                            options:0];
        NSInteger yearForCalc = [ageCalcComponents year];
        
        NSLog(@"yearForCalc: %li", (long)yearForCalc);
        
        NSDate * selectedBirthDate = datePicker1.date;
        [self identifyBirthDate:selectedBirthDate];
        [self identifyChildSexWithBirthdayYear:yearForCalc andMenstruationMonth:month];
    }
    
    [self savePersonalData];
    [self hideDatePicker1];
}

#pragma mark - Date Picker 2 methods

- (void)showDatePicker2 {
    
    NSIndexPath * dateRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    NSIndexPath *pickerIndexPath = [NSIndexPath indexPathForRow:dateRowIndexPath.row + 1 inSection:dateRowIndexPath.section];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:dateRowIndexPath];
    UITableViewCell * pickerCell = [self.tableView cellForRowAtIndexPath:pickerIndexPath];
    cell.textLabel.textColor = PINK_COLOR;
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    personalData = [[NSMutableDictionary alloc] initWithContentsOfFile:savedFilePath];
    
    datePicker2 = [[UIDatePicker alloc] init];
    datePicker2.datePickerMode = UIDatePickerModeDate;

    // Set the preferred style to wheels
    if (@available(iOS 13.4, *)) {
        datePicker2.preferredDatePickerStyle = UIDatePickerStyleWheels;
    }

    [datePicker2 addTarget:self action:@selector(picker2Change) forControlEvents:UIControlEventValueChanged];
    [pickerCell.contentView addSubview:datePicker2];
    
    
    if(![fileManager fileExistsAtPath:savedFilePath] || [[personalData objectForKey:@"menstruationDate"] isEqualToString: @""])
    {
        [datePicker2 setDate:[NSDate date] animated:YES];
        cell.textLabel.text = [dateFormatter stringFromDate:[NSDate date]];
    }
    else {
        NSString * savedDateString = [personalData objectForKey:@"menstruationDate"];
        NSDate * savedDate = [dateFormatter dateFromString:savedDateString];
        [datePicker2 setDate:savedDate animated:YES];
        cell.textLabel.text = savedDateString;
    }
    
    _datePicker2Visible = YES;
    [self.tableView beginUpdates];
    [self.tableView endUpdates];
    
    datePicker2.hidden = NO;
    datePicker2.alpha = 0.0f;
    [UIView animateWithDuration:0.25 animations:^{datePicker2.alpha = 1.0f;}];
    
    [self.tableView scrollToRowAtIndexPath:pickerIndexPath atScrollPosition:UITableViewScrollPositionMiddle animated:YES];
}

- (void)hideDatePicker2 {
    if (_datePicker2Visible) {
        
        _datePicker2Visible = NO;
        [self.tableView beginUpdates];
        [self.tableView endUpdates];
        
        [UIView animateWithDuration:0.25 animations:^{
            datePicker2.alpha = 0.0f;
        } completion:^(BOOL finished) {
            datePicker2.hidden = YES;
            datePicker2 = nil;
        }];
    }
}


- (void) picker2Change {
    NSString * datelabel = [dateFormatter stringFromDate:datePicker2.date];
    _menstruationDate = datelabel;

    NSIndexPath * dateRowIndexPath = [NSIndexPath indexPathForRow:0 inSection:2];
    UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:dateRowIndexPath];
    cell.textLabel.text = datelabel;
    cell.textLabel.textColor = PINK_COLOR;
    
    NSDate * selectedMenstruationDate = datePicker2.date;
    [self identifyBirthDate:selectedMenstruationDate];
    
    NSString * savedBirthDateString = [personalData objectForKey:@"birthday"];
    if (savedBirthDateString && ![savedBirthDateString isEqualToString:@""]) {
        NSDate * motherBirthDate = [dateFormatter dateFromString:savedBirthDateString];
        
        NSDateComponents * menstruationMonth = [[NSCalendar currentCalendar] components:NSCalendarUnitMonth fromDate:selectedMenstruationDate];
        NSInteger month = [menstruationMonth month];
        
        NSDateComponents * ageCalcComponents = [[NSCalendar currentCalendar] components:NSCalendarUnitYear
                                                                               fromDate:motherBirthDate
                                                                                 toDate:selectedMenstruationDate
                                                                                options:0];
        NSInteger yearForCalc = [ageCalcComponents year];
        
        [self identifyChildSexWithBirthdayYear:yearForCalc andMenstruationMonth:month];
    }
    
    [self savePersonalData];
    [self hideDatePicker2];
}


#pragma mark - Дата родов

- (void) identifyBirthDate:(NSDate *)selectedDate
{
    NSDateComponents * menstruationComponents = [[NSDateComponents alloc] init];
    [menstruationComponents setMonth: -3];
    [menstruationComponents setDay: +7];
    [menstruationComponents setYear: +1];
    NSDate * childBirthdayDate = [[NSCalendar currentCalendar] dateByAddingComponents:menstruationComponents toDate:selectedDate options:0];
    NSString * childBirthday = [dateFormatter stringFromDate:childBirthdayDate];
    _childBirthday = childBirthday;
    
    [self identifyZodiac:childBirthdayDate];
}


- (void) identifyZodiac:(NSDate *)selectedDate
{
    
    NSMutableArray * allZodiacs = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"ZodiacSigns", nil) ofType:@"plist"]];
    
    for (NSMutableDictionary * zodiac in allZodiacs)
    {
        _dateZodiac1 = [zodiac objectForKey:@"date1"];
        _dateZodiac2 = [zodiac objectForKey:@"date2"];
        
        NSDate * date1 = [zodiacDateFormatter dateFromString:_dateZodiac1];
        NSDate * date2 = [zodiacDateFormatter dateFromString:_dateZodiac2];
        
        NSDateComponents * compsSelected = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth|NSCalendarUnitYear fromDate:selectedDate];
        NSInteger daySelected = [compsSelected day];
        NSInteger monthSelected = [compsSelected month];
        NSInteger yearSelected = [compsSelected year];
        NSDate * fixedSelectedcDate = [zodiacDateFormatter dateFromString:[NSString stringWithFormat:@"%li.%li.%li", (long)daySelected, (long)monthSelected, (long)yearSelected]];
        
        NSDateComponents * compsZodiac1 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:date1];
        NSInteger day1 = [compsZodiac1 day];
        NSInteger month1 = [compsZodiac1 month];
        NSDate * fixedZodiacDate1 = [zodiacDateFormatter dateFromString:[NSString stringWithFormat:@"%li.%li.%li", (long)day1, (long)month1, (long)yearSelected]];
        
        NSDateComponents * compsZodiac2 = [[NSCalendar currentCalendar] components:NSCalendarUnitDay|NSCalendarUnitMonth fromDate:date2];
        NSInteger day2 = [compsZodiac2 day];
        NSInteger month2 = [compsZodiac2 month];
        NSDate * fixedZodiacDate2 = [zodiacDateFormatter dateFromString:[NSString stringWithFormat:@"%li.%li.%li", (long)day2, (long)month2, (long)yearSelected]];
        
        if ([fixedSelectedcDate compare:fixedZodiacDate1] == NSOrderedDescending &&
            [fixedSelectedcDate compare:fixedZodiacDate2] == NSOrderedAscending) {
            
            _titleZodiac = [zodiac objectForKey:@"title"];
            _imageZodiac = [zodiac objectForKey:@"image"];
            _elementZodiac = [zodiac objectForKey:@"element"];
            _elementImageZodiac = [zodiac objectForKey:@"elementImage"];
            
            _zodiacCellVisible = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zodiacCellVisible"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
        if ([fixedSelectedcDate compare:fixedZodiacDate1] == NSOrderedSame ||
                 [fixedSelectedcDate compare:fixedZodiacDate2] == NSOrderedSame) {
            
            _titleZodiac = [zodiac objectForKey:@"title"];
            _imageZodiac = [zodiac objectForKey:@"image"];
            _elementZodiac = [zodiac objectForKey:@"element"];
            _elementImageZodiac = [zodiac objectForKey:@"elementImage"];
            
            _zodiacCellVisible = YES;
            [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"zodiacCellVisible"];
            [[NSUserDefaults standardUserDefaults] synchronize];
        }
    }
}

#pragma mark - Пол ребенка

- (void) identifyChildSexWithBirthdayYear:(NSInteger)year andMenstruationMonth:(NSInteger)month
{
    if (year >= 18 && year <= 44) {
        NSMutableArray * allAges = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ChildSexMatrix" ofType:@"plist"]];
        for(int i = 0; i < [allAges count] - 1; i++)
        {
            NSMutableDictionary * age = [allAges objectAtIndex:i + 1];
            
            if ((i + 18) == year) {
                NSMutableString * childSexSign = [age objectForKey:[NSString stringWithFormat:@"%li", (long)month]];
                if ([childSexSign isEqualToString:@"+"]) {
                    _childSex = NSLocalizedString(@"Мальчик", nil);
                }
                else {
                    _childSex = NSLocalizedString(@"Девочка", nil);
                }
            }
        }
    }
    else {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Ошибка", nil) message:NSLocalizedString(@"Ошибка возраста", nil) delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        _childSex = NSLocalizedString(@"Неопределено", nil);
    }
    
}


#pragma mark - Purchased Product

/*
- (void)refreshTapped
{
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = self.view.center;
    _activityView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [_activityView startAnimating];
    [self.view addSubview:_activityView];
    
    _products = nil;
    [[PregnaIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            
            SKProduct * product = (SKProduct *) [_products objectAtIndex:0];
            NSLog(@"product.localizedTitle: %@", product.localizedTitle);
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:NSLocalizedString(@"Подтвердите восстановление покупок", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:@"OK", nil];
            alert.tag = 3;
            [alert show];
            
            [_activityView stopAnimating];
        }
    }];
}
*/

/*
- (void)buyCalculatorTapped
{
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = self.view.center;
    _activityView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [_activityView startAnimating];
    [self.view addSubview:_activityView];
    
    _products = nil;
    [[PregnaIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray *products) {
        if (success) {
            _products = products;
            SKProduct * product = (SKProduct *) [_products objectAtIndex:0];
            NSLog(@"product.localizedTitle: %@", product.localizedTitle);
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:NSLocalizedString(@"Подтвердите внутреннюю покупку", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:@"OK", nil];
            alert.tag = 4;
            [alert show];
            
            [_activityView stopAnimating];
        }
    }];
}

- (void)buyCalendarTapped
{
    _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    _activityView.center = self.view.center;
    _activityView.transform = CGAffineTransformMakeScale(1.5, 1.5);
    [_activityView startAnimating];
    [self.view addSubview:_activityView];
    
    _products = nil;
    [[PregnaIAPHelper sharedInstance] requestProductsWithCompletionHandler:^(BOOL success, NSArray * products) {
        if (success) {
            _products = products;
            SKProduct * product = (SKProduct *) [_products objectAtIndex:1];
            NSLog(@"product.localizedTitle: %@", product.localizedTitle);
            
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:product.localizedTitle message:NSLocalizedString(@"Подтвердите внутреннюю покупку", nil) delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:@"OK", nil];
            alert.tag = 5;
            [alert show];
            
            [_activityView stopAnimating];
        }
    }];
}
 */

/*
- (void)productPurchased:(NSNotification *)notification {
    
    NSString * productIdentifier = notification.object;
    [_products enumerateObjectsUsingBlock:^(SKProduct * product, NSUInteger idx, BOOL *stop) {
        if ([product.productIdentifier isEqualToString:productIdentifier]) {
            NSLog(@"productPurchased!");
            *stop = YES;
            
            if ([[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.ChildData"] == YES &&
                [[NSUserDefaults standardUserDefaults] boolForKey:@"com.kovallux.PregnaSutraiPhoneRU.PregnancyCalendar"] == YES) {
                self.navigationItem.rightBarButtonItem.enabled = NO;
            } else {
                self.navigationItem.rightBarButtonItem.enabled = YES;
            }
            [self.view setNeedsDisplay];
            [self.view setNeedsLayout];
            [self.tableView reloadData];
        }
    }];
}
*/

#pragma mark - Intro View

- (void) showIntroWithFixedTitleViewDelegate
{
    [self showIntro];
}

- (void) showIntro {
    
    BOOL isRunningTallPhone = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568);
    
    int titlePositionY;
    int descPositionY;
    int titleViewY;
    
    if (isRunningTallPhone) {
        titlePositionY = 360;
        descPositionY = 330;
        titleViewY = 204;
    }
    else {
        titlePositionY = 280;
        descPositionY = 260;
        titleViewY = 204;
    }
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    
    EAIntroPage * page1 = [EAIntroPage page];
    page1.title = NSLocalizedString(@"Вычисление даты рождения", nil);
    page1.desc = NSLocalizedString(@"Вычисление даты рождения - описание", nil);
    page1.titlePositionY = titlePositionY;
    page1.descPositionY = descPositionY;
    
    EAIntroPage * page2 = [EAIntroPage page];
    page2.title = NSLocalizedString(@"Вычисление пола ребенка", nil);
    page2.desc = NSLocalizedString(@"Вычисление пола ребенка - описание", nil);
    page2.titlePositionY = titlePositionY;
    page2.descPositionY = descPositionY;
    
    
    EAIntroView * intro = [[EAIntroView alloc] initWithFrame:appDelegate.window.bounds andPages:@[page1,page2]];
    [intro setDelegate:self];
    UIImageView * titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"paidContentHelp"]];
    intro.titleView = titleView;
    intro.titleViewY = titleViewY;
    intro.backgroundColor = BLACK_COLOR;
    intro.alpha = 0.5f;
    intro.pageControlY = 70;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(220, [UIScreen mainScreen].bounds.size.height - 100, 100, 20)];
    [btn setTitle:NSLocalizedString(@"Пропустить", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    intro.skipButton = btn;
    
    [intro showInView:appDelegate.window animateDuration:0.5];
    
}

- (void)introDidFinish:(EAIntroView *)introView {
    NSIndexPath * paidIndexPath1 = [NSIndexPath indexPathForRow:2 inSection:1];
    UITableViewCell * cell1 = [self.tableView cellForRowAtIndexPath:paidIndexPath1];
    [self.tableView scrollToRowAtIndexPath:paidIndexPath1 atScrollPosition:UITableViewScrollPositionTop animated:YES];
    NSIndexPath * paidIndexPath2 = [NSIndexPath indexPathForRow:3 inSection:1];
    UITableViewCell * cell2 = [self.tableView cellForRowAtIndexPath:paidIndexPath2];
    
    cell1.backgroundColor = PURPLE_COLOR;
    cell1.textLabel.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1.0f
                     animations:^{
                         cell1.backgroundColor = [UIColor whiteColor];
                     }
                     completion:nil];
    
    cell2.backgroundColor = PURPLE_COLOR;
    cell2.textLabel.backgroundColor = [UIColor clearColor];
    [UIView animateWithDuration:1.0f
                     animations:^{
                         cell2.backgroundColor = [UIColor whiteColor];
                     }
                     completion:nil];
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"scrollToPaidContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

@end
