//
//  BirthCalendar.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/27/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "FirstTrimesterVC.h"
#import "Constants.h"
#import "WeekViewController.h"
#import "AppDelegate.h"
#import "BDKNotifyHUD.h"
#import "ADViewController.h"
#import <QuartzCore/QuartzCore.h>
@import Social;

static NSString * const sampleDescription1 = @"introPage1";
static NSString * const sampleDescription2 = @"introPage2";
static NSString * const sampleDescription3 = @"introPage3";
static NSString * const sampleDescription4 = @"introPage4";

//#define IsRunningTallPhone() ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568)

@interface FirstTrimesterVC() {
    NSArray * sectionNames;
    NSMutableArray * rowNames;
    NSArray * sortedArray;
}

@property (strong, nonatomic) BDKNotifyHUD * notify;
@property (strong, nonatomic) NSString * imageName;
@property (strong, nonatomic) NSString * notificationTextAdded;
@property (strong, nonatomic) NSString * notificationTextRemoved;

// VK properties
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSString * string;
@property (nonatomic, strong) NSURL * URL;

@property(nonatomic, assign) BOOL introIsShown;

@end

@implementation FirstTrimesterVC

@synthesize firstRun = _firstRun;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    if (@available(iOS 13.0, *)) {
        UINavigationBarAppearance *appearance = [[UINavigationBarAppearance alloc] init];
        [appearance configureWithOpaqueBackground];
        appearance.backgroundColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
        appearance.titleTextAttributes = @{NSForegroundColorAttributeName: UIColor.whiteColor};

        self.navigationController.navigationBar.standardAppearance = appearance;
        self.navigationController.navigationBar.scrollEdgeAppearance = appearance;
    }

    self.notificationTextAdded = NSLocalizedString(@"Добавлено!", nil);
    self.notificationTextRemoved = NSLocalizedString(@"Удалено!", nil);
    self.imageName = @"Checkmark.png";
    
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    
    if (![defaults objectForKey:@"firstRun"]){

        [defaults setObject:[NSDate date] forKey:@"firstRun"];
        [defaults synchronize];
        
        [self showIntro];
        
        [UIView animateWithDuration:0.25 animations:^{ [self setNeedsStatusBarAppearanceUpdate];
            self.tabBarController.tabBar.alpha = 0.0f;
        } completion:^(BOOL finished) {
            self.tabBarController.tabBar.hidden = YES;
        }];
        
    } else {
        self.introIsShown = NO;
        
        [self.tabBarController.tabBar setHidden:NO];
        self.tabBarController.tabBar.alpha = 0.0f;
        
        [UIView animateWithDuration:0.8 animations:^{ [self setNeedsStatusBarAppearanceUpdate];
            self.tabBarController.tabBar.alpha = 1.0f;
        }];
    }
    
    _weekTexts = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"PregnaCalendar", nil) ofType:@"plist"]];
    
    rowNames = [[NSMutableArray alloc] init];
    for (int i = 0; i < [_weekTexts count]; i++)
    {
        NSMutableDictionary * name = [_weekTexts objectAtIndex:i];
        [rowNames addObject:[name objectForKey:@"weekTitle"]];
    }
    
    sortedArray = [rowNames sortedArrayUsingComparator:^(id firstObject, id secondObject) {
        return [((NSString *)firstObject) compare:((NSString *)secondObject) options:NSNumericSearch]; }];
    
    sectionNames = @[
                     NSLocalizedString(@"1-й триместр", nil),
                     NSLocalizedString(@"2-й триместр", nil),
                     NSLocalizedString(@"3-й триместр", nil)
                     ];
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = NSLocalizedString(@"Календарь контроллер", nil);
}
    
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
    
#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [sectionNames count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return [sectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 13;
    }
    else if (section == 1) {
        return 14;
    }
    else {
        return 13;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 60;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CalendarCell" forIndexPath:indexPath];
    
    if (indexPath.section == 0) {
        
        cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];
    }
    else if (indexPath.section == 1) {
        cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row + 13];
    }
    else {
        cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row + 27];
    }
    
    for (int i = 0; i < [_weekTexts count]; i++)
    {
        NSMutableDictionary * name = [_weekTexts objectAtIndex:i];
        NSMutableString * current = [name objectForKey:@"weekTitle"];
        
        if ([current isEqualToString:cell.textLabel.text]) {
            _week = [[NSMutableDictionary alloc] init];
            _childImage = [name objectForKey:@"childImage"];
        }
    }
    cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Thin" size:22];
    cell.imageView.image = [UIImage imageNamed:_childImage];
    /*
    CALayer * l = [cell.imageView layer];
    [l setMasksToBounds:YES];
    [l setCornerRadius:22.0];
    //[l setBorderWidth:1.0f];
    //[l setBorderColor:[[UIColor whiteColor] CGColor]];
     */
    
    cell.imageView.contentMode = UIViewContentModeScaleAspectFill;
    cell.detailTextLabel.text = nil;
    return cell;
}



#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showWeek"]) {
        WeekViewController * weekViewController = segue.destinationViewController;
        
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString * str = cell.textLabel.text;
        
        NSInteger sectionNumber = indexPath.section;
        weekViewController.weekTitle = str;
        weekViewController.sectionNumber = sectionNumber;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}


#pragma mark - Intro View

- (void)showIntro {
    
    self.introIsShown = YES;
    
    BOOL isRunningTallPhone = ([UIDevice currentDevice].userInterfaceIdiom == UIUserInterfaceIdiomPhone && [UIScreen mainScreen].bounds.size.height == 568);
    
    int titlePositionY;
    int descPositionY;
    int titleViewY;
    
    if (isRunningTallPhone) {
        titlePositionY = 220;
        descPositionY = 200;
        titleViewY = 90;
    }
    else {
        titlePositionY = 180;
        descPositionY = 160;
        titleViewY = 50;
    }
    
    
    EAIntroPage * page1 = [EAIntroPage page];
    page1.title = NSLocalizedString(@"Добро пожаловать!", nil);
    page1.desc = NSLocalizedString(sampleDescription1, nil);
    //page1.bgImage = [UIImage imageNamed:@"bg2"];
    page1.titlePositionY = titlePositionY;
    page1.descPositionY = descPositionY;
    
    EAIntroPage * page2 = [EAIntroPage page];
    page2.title = NSLocalizedString(@"Есть все возможности!", nil);
    page2.desc = NSLocalizedString(sampleDescription2, nil);
    //page2.bgImage = [UIImage imageNamed:@"bg2"];
    page2.titlePositionY = titlePositionY;
    page2.descPositionY = descPositionY;
    
    EAIntroPage * page3 = [EAIntroPage page];
    page3.title = NSLocalizedString(@"Выбирай позу с умом!", nil);
    page3.desc = NSLocalizedString(sampleDescription3, nil);
    //page3.bgImage = [UIImage imageNamed:@"bg2"];
    page3.titlePositionY = titlePositionY;
    page3.descPositionY = descPositionY;
    
    EAIntroPage * page4 = [EAIntroPage page];
    page4.title = NSLocalizedString(@"introPageTitle4", nil);
    page4.desc = NSLocalizedString(sampleDescription4, nil);
    page4.titlePositionY = titlePositionY;
    page4.descPositionY = descPositionY;
    
    
    EAIntroView *intro = [[EAIntroView alloc] initWithFrame:self.view.bounds andPages:@[page1, page2, page3, page4]];
    [intro setDelegate:self];
    UIImageView * titleView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"IconIntro"]];
    intro.titleView = titleView;
    intro.titleViewY = titleViewY;
    intro.backgroundColor = PINK_COLOR; // pink background
    intro.pageControlY = 30;
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    [btn setFrame:CGRectMake(220, [UIScreen mainScreen].bounds.size.height - 60, 100, 20)];
    [btn setTitle:NSLocalizedString(@"Пропустить", nil) forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    //btn.layer.borderWidth = 1.0f;
    //btn.layer.cornerRadius = 5;
    //btn.layer.borderColor = [[UIColor whiteColor] CGColor];
    intro.skipButton = btn;
    
    //[intro showInView:self.view animateDuration:0.5];
    
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [intro showInView:appDelegate.window animateDuration:0.5];
}

- (void)introDidFinish:(EAIntroView *)introView {
    
    [self.tabBarController.tabBar setHidden:NO];
    self.tabBarController.tabBar.alpha = 0.0f;
    
    [UIView animateWithDuration:0.5 animations:^{ [self setNeedsStatusBarAppearanceUpdate];
        self.tabBarController.tabBar.alpha = 1.0f;
    }];
    
    self.introIsShown = NO;
}

#pragma mark - Advertising handling

-(void)loadInternalAD {
    UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"AD" bundle:nil];
    ADViewController *controller = [storyboard instantiateInitialViewController];
    [controller setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self presentViewController:controller animated:YES completion:nil];
}

@end

