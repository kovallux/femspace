//
//  FirstViewController.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/12/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "AllPosesViewController.h"
#import "PoseTableViewController.h"
#import "WEPopoverController.h"
#import "WEPopover.h"
#import <QuartzCore/QuartzCore.h>
#import "Constants.h"
#import "PersonalViewController.h"

@interface AllPosesViewController ()

@end

@implementation AllPosesViewController

@synthesize popoverController;
@synthesize filterIndex;

- (void)awakeFromNib
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.clearsSelectionOnViewWillAppear = NO;
        self.preferredContentSize = CGSizeMake(320.0, 600.0);
    }
    [super awakeFromNib];
}

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
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        self.poseViewController = (PoseTableViewController *)[[self.splitViewController.viewControllers lastObject] topViewController];
    }
    
    popoverClass = [WEPopoverController class];
    filterIndex = 2;
    
    _posesList1 = @[NSLocalizedString(@"Поза «Богиня»", nil),
                   NSLocalizedString(@"Поза «Двойные качели»", nil),
                   NSLocalizedString(@"Поза «Кошка»", nil),
                   NSLocalizedString(@"Поза «Куртизанка»", nil),
                   NSLocalizedString(@"Поза «Лотос»", nil),
                   NSLocalizedString(@"Поза «Миссионерская поза»", nil),
                   NSLocalizedString(@"Поза «Раскрытый цветок»", nil),
                   NSLocalizedString(@"Поза «Секрет»", nil),
                   NSLocalizedString(@"Поза «Спящая красавица»", nil),
                   NSLocalizedString(@"Поза «Тростник»", nil),
                   ];
    
    _posesList2 = @[NSLocalizedString(@"Поза «Амазонка»", nil),
                   NSLocalizedString(@"Поза «Андромаха»", nil),
                   NSLocalizedString(@"Поза «Бабочка»", nil),
                   NSLocalizedString(@"Поза «В ритме танца»", nil),
                   NSLocalizedString(@"Поза «Догги-стайл»", nil),
                   NSLocalizedString(@"Поза «Качели»", nil),
                   NSLocalizedString(@"Поза «Наковальня»", nil),
                   NSLocalizedString(@"Поза «Тигрица»", nil),
                   ];
    
    _posesList3 = @[NSLocalizedString(@"Поза «Ложка»", nil),
                   NSLocalizedString(@"Поза «Перпендикуляр»", nil),
                   NSLocalizedString(@"Поза «Полет чайки»", nil),
                   NSLocalizedString(@"Поза «Союз пчел»", nil),
                   NSLocalizedString(@"Поза «Удобный куннилингус»", nil),
                   ];
    
    _posesListArray = [[NSArray alloc] initWithObjects:
                       _posesList1,
                       _posesList2,
                       _posesList3,
                       nil];
    
    _sectionTitles = [[NSArray alloc] initWithObjects:
                      NSLocalizedString(@"firstHeaderSectionTitle", nil),
                      NSLocalizedString(@"secondHeaderSectionTitle", nil),
                      NSLocalizedString(@"thirdHeaderSectionTitle", nil),
                      nil];
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = NSLocalizedString(@"Позы для беременных", nil);
    //NSString * labelString = [NSString stringWithFormat:NSLocalizedString(@"Позы %d-го триместра", nil), _trimesterNumberNext];
    //self.navigationItem.title = labelString;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (_trimesterNumberNext == 1) {
        return 1;
    }
    else if (_trimesterNumberNext == 2) {
        return 1;
    }
    else if (_trimesterNumberNext == 3) {
        return 1;
    }
    else {
        return 3;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (_trimesterNumberNext == 1) {
        return [_posesList1 count];
    }
    else if (_trimesterNumberNext == 2) {
        return [_posesList2 count];
    }
    else if (_trimesterNumberNext == 3) {
        return [_posesList3 count];
    }
    else {
        NSArray * sectionArray = [NSArray arrayWithArray:[_posesListArray objectAtIndex:section]];
        return [sectionArray count];
    }
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    NSString * headerText;
    if (_trimesterNumberNext == 1) {
        headerText = [_sectionTitles objectAtIndex:0];
    }
    else if (_trimesterNumberNext == 2) {
        headerText = [_sectionTitles objectAtIndex:1];
    }
    else if (_trimesterNumberNext == 3) {
        headerText = [_sectionTitles objectAtIndex:2];
    }
    else {
        headerText = [_sectionTitles objectAtIndex:section];
    }
    
    NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0]};
    CGRect rect = [headerText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:attributes
                                                                       context:nil];
    _sectionHeight = rect.size.height;
    
    return _sectionHeight + 20;
}


- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    
    NSString * headerText;
    if (_trimesterNumberNext == 1) {
        headerText = [_sectionTitles objectAtIndex:0];
    }
    else if (_trimesterNumberNext == 2) {
        headerText = [_sectionTitles objectAtIndex:1];
    }
    else if (_trimesterNumberNext == 3) {
        headerText = [_sectionTitles objectAtIndex:2];
    }
    else {
        headerText = [_sectionTitles objectAtIndex:section];
    }
    
    UIView * headerView = [[UIView alloc] init];
    
    NSMutableParagraphStyle * paragraph = [[NSMutableParagraphStyle alloc] init];
    paragraph.hyphenationFactor = 1;
    paragraph.alignment = NSTextAlignmentJustified;
    //NSString * capitalText = [_sectionText uppercaseString];
    NSMutableAttributedString * string = [[NSMutableAttributedString alloc] initWithString:headerText attributes:[NSDictionary dictionaryWithObjectsAndKeys:paragraph, NSParagraphStyleAttributeName, nil]];
    
    NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:15.0]};
    CGRect rect = [headerText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:attributes
                                                                       context:nil];
    _sectionHeight = rect.size.height;
    
    UILabel * poseFirstSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, 290, _sectionHeight)];
    poseFirstSectionLabel.font = [UIFont systemFontOfSize:15.0];
    poseFirstSectionLabel.numberOfLines = 0;
    poseFirstSectionLabel.backgroundColor = [UIColor clearColor];
    poseFirstSectionLabel.textColor = GRAY_COLOR;
    poseFirstSectionLabel.attributedText = string;
    
    [headerView addSubview:poseFirstSectionLabel];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    NSMutableArray * poseTexts = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"PosesData", nil) ofType:@"plist"]];
    
    NSArray * textArray = [[NSArray alloc] init];
    
    if (_trimesterNumberNext == 1) {
        textArray = _posesList1;
    }
    else if (_trimesterNumberNext == 2) {
        textArray = _posesList2;
    }
    else if (_trimesterNumberNext == 3) {
        textArray = _posesList3;
    }
    else {
        if (indexPath.section == 0) {
            textArray = _posesList1;
        }
        if (indexPath.section == 1) {
            textArray = _posesList2;
        }
        if (indexPath.section == 2) {
            textArray = _posesList3;
        }
    }
    
    if (filterIndex == 0) {
        for(int i = 0; i < [poseTexts count]; i++)
        {
            NSMutableDictionary * name = [poseTexts objectAtIndex:i];
            NSMutableString * currentCat = [name objectForKey:@"title"];
            
            if ([currentCat isEqualToString:[textArray objectAtIndex:indexPath.row]]) {
                
                if ([[name objectForKey:@"her"] isEqualToString:@"+"]) {
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
                }
                else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
                }
            }
        }
    }
    else if (filterIndex == 1) {
        for(int i = 0; i < [poseTexts count]; i++)
        {
            NSMutableDictionary * name = [poseTexts objectAtIndex:i];
            NSMutableString * currentCat = [name objectForKey:@"title"];
            
            if ([currentCat isEqualToString:[textArray objectAtIndex:indexPath.row]]) {
                
                if ([[name objectForKey:@"he"] isEqualToString:@"+"]) {
                    cell.textLabel.textColor = PINK_COLOR;
                    cell.textLabel.font = [UIFont boldSystemFontOfSize:FONT_SIZE];
                }
                else {
                    cell.textLabel.textColor = [UIColor blackColor];
                    cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
                }
            }
        }
    }
    else {
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
    }
    
    NSArray * sortedArray = [textArray sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];
    return cell;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        UIView * footerView  = [[UIView alloc] init];
        
        UIButton * paidContentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [paidContentButton setFrame:CGRectMake(10, 20, 300, 44)];
        [paidContentButton setTitle:NSLocalizedString(@"Платный функционал", nil) forState:UIControlStateNormal];
        [paidContentButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [paidContentButton addTarget:self action:@selector(goToPaidContent) forControlEvents:UIControlEventTouchUpInside];
        // Add border to button
        paidContentButton.layer.borderWidth = 1.0f;
        paidContentButton.layer.borderColor = [PINK_COLOR CGColor];
        paidContentButton.layer.cornerRadius = 8.0f;
        [footerView addSubview:paidContentButton];
        
        return footerView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == 2) {
        return 60;
    }
    else {
        return 0;
    }
    
}


#pragma mark - Навигация

/*
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPad) {
        
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString * str = cell.textLabel.text;
        
        self.poseViewController.poseTitle = str;
        self.poseViewController.favoritesButtonTitle = NSLocalizedString(@"Добавить в Избранное", nil);
        
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"showPoseDetail"]) {
        self.poseViewController = segue.destinationViewController;
        
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString * str = cell.textLabel.text;
        
        self.poseViewController.poseTitle = str;
        self.poseViewController.favoritesButtonTitle = NSLocalizedString(@"Добавить в Избранное", nil);
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

- (void) goToPaidContent
{

    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"scrollToPaidContent"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    self.tabBarController.selectedIndex = 3;
}

#pragma mark - Popover

- (IBAction)onButtonFilterClick:(id)sender {
	
	if (!self.popoverController) {
		WEPopover * contentViewController = [[WEPopover alloc] initWithStyle:UITableViewStylePlain];
        contentViewController.contentDelegate = self;
        contentViewController.checkmark = filterIndex;
        
		self.popoverController = [[popoverClass alloc] initWithContentViewController:contentViewController];
		self.popoverController.delegate = self;
		self.popoverController.passthroughViews = [NSArray arrayWithObject:self.navigationController.navigationBar];
		
		[self.popoverController presentPopoverFromBarButtonItem:sender
									   permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
	}
    else {
		[self.popoverController dismissPopoverAnimated:YES];
		self.popoverController = nil;
	}
}


- (WEPopoverContainerViewProperties *)improvedContainerViewProperties {
	
	WEPopoverContainerViewProperties * props = [WEPopoverContainerViewProperties alloc];
	NSString *bgImageName = nil;
	CGFloat bgMargin = 0.0;
	CGFloat bgCapSize = 0.0;
	CGFloat contentMargin = 4.0;
	
	bgImageName = @"popoverBg.png";
	
	// These constants are determined by the popoverBg.png image file and are image dependent
	bgMargin = 13; // margin width of 13 pixels on all sides popoverBg.png (62 pixels wide - 36 pixel background) / 2 == 26 / 2 == 13
	bgCapSize = 31; // ImageSize/2  == 62 / 2 == 31 pixels
	
	props.leftBgMargin = bgMargin;
	props.rightBgMargin = bgMargin;
	props.topBgMargin = bgMargin;
	props.bottomBgMargin = bgMargin;
	props.leftBgCapSize = bgCapSize;
	props.topBgCapSize = bgCapSize;
	props.bgImageName = bgImageName;
	props.leftContentMargin = contentMargin;
	props.rightContentMargin = contentMargin - 1; // Need to shift one pixel for border to look correct
	props.topContentMargin = contentMargin;
	props.bottomContentMargin = contentMargin;
	
	props.arrowMargin = 4.0;
	
	props.upArrowImageName = @"popoverArrowUp.png";
	props.downArrowImageName = @"popoverArrowDown.png";
	props.leftArrowImageName = @"popoverArrowLeft.png";
	props.rightArrowImageName = @"popoverArrowRight.png";
	return props;
}

#pragma mark -
#pragma mark WEPopoverControllerDelegate implementation

- (void)popoverControllerDidDismissPopover:(WEPopoverController *)thePopoverController {
	//Safe to release the popover here
	self.popoverController = nil;
    //[popoverController dismissPopoverAnimated:YES];
}

- (BOOL)popoverControllerShouldDismissPopover:(WEPopoverController *)thePopoverController {
	//The popover is automatically dismissed if you click outside it, unless you return NO here
	return YES;
}

#pragma mark - ACPopoverContentDelegate implementation

- (void)userSelectedRowInPopover:(NSUInteger)row {
    if (self.popoverController) {
        [self.popoverController dismissPopoverAnimated:YES];
        self.popoverController = nil;
        filterIndex = row;
        [self.tableView reloadData];
        //NSLog(@"Indexpath: %lu", (unsigned long)row);
    }
}

@end
