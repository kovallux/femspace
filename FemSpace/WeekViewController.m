//
//  Week.m
//  FemSpace
//
//  Created by Сергей Коваль on 4/3/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "WeekViewController.h"
#import "Constants.h"
#import "HCYoutubeParser.h"
#import <QuartzCore/QuartzCore.h>
#import <MediaPlayer/MediaPlayer.h>
#import "PoseTableViewController.h"
#import "AllPosesViewController.h"

#define SPINNER_SIZE 25

@interface WeekViewController () {
    NSArray * sectionNames;
    CGFloat screenWidth;
}

@end

@implementation WeekViewController

@synthesize youTubeWebView;

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    CGRect screenBound = [[UIScreen mainScreen] bounds];
    CGSize screenSize = screenBound.size;
    screenWidth = screenSize.width;
    
    sectionNames = @[
                     NSLocalizedString(@"ЧЕКЛИСТ (отмечайте сделанное!)", nil),
                     //NSLocalizedString(@"Секс позы", nil),
                     NSLocalizedString(@"Ребенок", nil),
                     NSLocalizedString(@"А ты знала, что...", nil),
                     NSLocalizedString(@"Твое тело", nil),
                     NSLocalizedString(@"Обрати внимание", nil)
                     ];
    
    _weekTexts = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"PregnaCalendar", nil) ofType:@"plist"]];
    
    for(int i = 0; i < [_weekTexts count]; i++)
    {
        NSMutableDictionary * name = [_weekTexts objectAtIndex:i];
        NSMutableString * currentCat = [name objectForKey:@"weekTitle"];
        
        if ([currentCat isEqualToString:_weekTitle]) {
            
            _week = [[NSMutableDictionary alloc] init];
            _childImage = [name objectForKey:@"childImage"];
            _bodyImage = [name objectForKey:@"bodyImage"];
            _didYouKnowImage = [name objectForKey:@"didYouKnowImage"];
            _checklist1 = [name objectForKey:@"checklist1"];
            _checklist2 = [name objectForKey:@"checklist2"];
            _checklist3 = [name objectForKey:@"checklist3"];
            _checklist4 = [name objectForKey:@"checklist4"];
            _yourChildText = [name objectForKey:@"yourChildText"];
            _didYouKnowText = [name objectForKey:@"didYouKnowText"];
            _yourBodyText = [name objectForKey:@"yourBodyText"];
            _payAttentionText = [name objectForKey:@"payAttentionText"];
            _videoUrl = [name objectForKey:@"videoUrl"];
            
            if ([_checklist4 isEqualToString:@""]) {
                _checklist4Exists = NO;
                //NSLog(@"_checklist4Exists = NO");
            }
            else {
                _checklist4Exists = YES;
                //NSLog(@"_checklist4Exists = YES");
            }
            
            if (![UIImage imageNamed:_bodyImage]) {
                _bodyImageExists = NO;
            }
            else {
                _bodyImageExists = YES;
            }
            
            if (![UIImage imageNamed:_didYouKnowImage]) {
                _didYouKnowImageExists = NO;
            }
            else {
                _didYouKnowImageExists = YES;
            }
            
            if ([_videoUrl isEqualToString:@""]) {
                _videoUrlExists = NO;
            }
            else {
                _videoUrlExists = YES;
            }
        }
    }
    
    UIImage * childImage = [UIImage imageNamed:_childImage];
    _imageHeight = childImage.size.height;
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = PINK_COLOR;
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    self.navigationItem.title = [_weekTitle uppercaseString];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [sectionNames count];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [sectionNames objectAtIndex:section];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        if (indexPath.row == 3) {
            return _checklist4Exists ? 44 : 0;
        }
        else {
            return 44;
        }
    }
    /*
    else if (indexPath.section == 1) {
        return 44;
    }
     */
    else if (indexPath.section == 1) {
        NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_SMALL]};
        CGRect rect = [_yourChildText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:attributes
                                                   context:nil];
        return rect.size.height + 10;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_SMALL]};
            CGRect rect = [_didYouKnowText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes
                                                        context:nil];
            return rect.size.height + 10;
        }
        else {
            return _didYouKnowImageExists ? 200 : 0;
        }
        
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_SMALL]};
            CGRect rect = [_yourBodyText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                        options:NSStringDrawingUsesLineFragmentOrigin
                                                     attributes:attributes
                                                        context:nil];
            return rect.size.height + 10;
        }
        else {
            return _bodyImageExists ? 200 : 0;
        }
    }
    else if (indexPath.section == 4) {
        if (indexPath.row == 0) {
            NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE_SMALL]};
            CGRect rect = [_payAttentionText boundingRectWithSize:CGSizeMake(290, MAXFLOAT)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attributes
                                                      context:nil];
            return rect.size.height + 10;
        }
        else {
            return _videoUrlExists ? 180 : 0;
        }
    }
    else {
        return 44;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
        UIView * headerView = [[UIView alloc] init];
         
        UIImageView * childImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_childImage]];
        childImage.frame = CGRectMake(60, 10, 200, 200);
        childImage.contentMode = UIViewContentModeScaleAspectFill;
        CALayer * l = [childImage layer];
        [l setMasksToBounds:YES];
        [l setCornerRadius:50.0];
        [l setBorderWidth:3.0];
        [l setBorderColor:[[UIColor whiteColor] CGColor]];
        childImage.alpha = 1.0f;
        [headerView addSubview:childImage];
        
        UILabel * poseFirstSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 220, 300, 30)];
        poseFirstSectionLabel.font = [UIFont systemFontOfSize:14.0];
        poseFirstSectionLabel.numberOfLines = 1;
        poseFirstSectionLabel.backgroundColor = [UIColor clearColor];
        poseFirstSectionLabel.textAlignment = NSTextAlignmentLeft;
        NSString * lableText = [[NSString alloc] initWithFormat:@"%@", [sectionNames objectAtIndex:0]];
        [lableText uppercaseString];
        poseFirstSectionLabel.text = lableText;
        poseFirstSectionLabel.textColor = GRAY_COLOR;
        [poseFirstSectionLabel.text uppercaseString];
        [headerView addSubview:poseFirstSectionLabel];
        
        return headerView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 250;
    }
    else {
        return 20;
    }
}

-(NSIndexPath *)tableView:(UITableView *)tableView willSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        return indexPath;
    }
    /*
    else if (indexPath.section == 1) {
        return indexPath;
    }
     */
    else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 4;
    }
    /*
    else if (section == 1) {
        return 1;
    }
     */
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 2;
    }
    else if (section == 3) {
        return 2;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"checklistCell" forIndexPath:indexPath];
        if (indexPath.row == 0) {
            cell.textLabel.text = _checklist1;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist1" stringByAppendingString:_weekTitle]] == NO) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if (indexPath.row == 1) {
            cell.textLabel.text = _checklist2;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist2" stringByAppendingString:_weekTitle]] == NO) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else if (indexPath.row == 2) {
            cell.textLabel.text = _checklist3;
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist3" stringByAppendingString:_weekTitle]] == NO) {
                cell.accessoryType = UITableViewCellAccessoryNone;
            }
            else {
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
        else {
            if ([_checklist4 isEqualToString:@""]) {
                cell.textLabel.text = @"No checkmark4...";
                cell.imageView.image = [UIImage imageNamed:@"lock"];
            }
            else {
                cell.textLabel.text = _checklist4;
                if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist4" stringByAppendingString:_weekTitle]] == NO) {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                else {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                }
            }
        }
        return cell;
    }
    /*
    else if (indexPath.section == 1) {
        NSInteger trimesterNumber = _sectionNumber + 1;
        NSString * labelString = [NSString stringWithFormat:NSLocalizedString(@"Все позы %d-го триместра", nil), trimesterNumber];
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"allPosesCell" forIndexPath:indexPath];
        cell.textLabel.text = [labelString uppercaseString];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16];
        return cell;
    }
     */
    else if (indexPath.section == 1) {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekCell" forIndexPath:indexPath];
        cell.textLabel.text = _yourChildText;
        return cell;
    }
    else if (indexPath.section == 2) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekCell" forIndexPath:indexPath];
            cell.textLabel.text = _didYouKnowText;
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell1" forIndexPath:indexPath];
            if (![UIImage imageNamed:_didYouKnowImage]) {
                cell.textLabel.text = @"No image...";
                cell.imageView.image = [UIImage imageNamed:@"lock"];
            }
            else {
                UIImageView * childImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_didYouKnowImage]];
                childImage.frame = CGRectMake(0, 0, screenWidth, 200);
                childImage.contentMode = UIViewContentModeScaleAspectFit;
                childImage.clipsToBounds = YES;
                [cell.contentView addSubview:childImage];
            }
            return cell;
        }
    }
    else if (indexPath.section == 3) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekCell" forIndexPath:indexPath];
            cell.textLabel.text = _yourBodyText;
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"imageCell2" forIndexPath:indexPath];
            if (![UIImage imageNamed:_bodyImage]) {
                cell.textLabel.text = @"No image...";
                cell.imageView.image = [UIImage imageNamed:@"lock"];
            }
            else {
                UIImageView * childImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:_bodyImage]];
                childImage.frame = CGRectMake(0, 0, screenWidth, 200);
                childImage.contentMode = UIViewContentModeScaleAspectFill;
                childImage.clipsToBounds = YES;
                [cell.contentView addSubview:childImage];
            }
            return cell;
        }
    }
    else {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"weekCell" forIndexPath:indexPath];
            cell.textLabel.text = _payAttentionText;
            return cell;
        }
        else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"videoCell" forIndexPath:indexPath];
            cell.textLabel.textColor = [UIColor lightGrayColor];
            if ([_videoUrl isEqualToString:@""]) {
                cell.textLabel.text = @"No video...";
                cell.imageView.image = [UIImage imageNamed:@"lock"];
            }
            else {
                UIActivityIndicatorView * _activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
                //_activityView.frame = CGRectMake(100, 71, 37, 37);
                
                // Get center of cell (vertically)
                int center = cell.frame.size.height / 2;
                
                // Size (width) of the text in the cell
                UIFont * font = [UIFont systemFontOfSize:FONT_SIZE];
                NSDictionary * attributes = @{NSFontAttributeName: font};
                
                // How big is this string when drawn in this font?
                CGSize size = [cell.textLabel.text sizeWithAttributes:attributes];
                
                // Locate spinner in the center of the cell at end of text
                [_activityView setFrame:CGRectMake(size.width + SPINNER_SIZE, center - SPINNER_SIZE / 2, SPINNER_SIZE, SPINNER_SIZE)];
                [_activityView startAnimating];
                //[cell.contentView addSubview:_activityView];
                [cell.contentView insertSubview:_activityView atIndex:1];
                
                NSURL * url = [NSURL URLWithString:_videoUrl];
                [HCYoutubeParser thumbnailForYoutubeURL:url
                                          thumbnailSize:YouTubeThumbnailDefaultHighQuality
                                          completeBlock:^(UIImage *image, NSError *error) {
                                              if (!error) {
                                                  UIImageView * imageView = [[UIImageView alloc] initWithImage:image];
                                                  imageView.frame = CGRectMake(0, 0, screenWidth, 180);
                                                  imageView.contentMode = UIViewContentModeScaleAspectFill;
                                                  imageView.clipsToBounds = YES;
                                                  [cell.contentView addSubview:imageView];
                                                  
                                                  UIButton * addButton = [[UIButton alloc] initWithFrame:CGRectMake((screenWidth - 88)/2, 46, 88, 88)];
                                                  addButton.alpha = 1.0f;
                                                  [addButton setImage:[UIImage imageNamed:@"play_button.png"] forState:UIControlStateNormal];
                                                  addButton.showsTouchWhenHighlighted = YES;
                                                  [addButton addTarget:self action:@selector(playVideo:) forControlEvents:UIControlEventTouchUpInside];
                                                  [cell.contentView insertSubview:addButton aboveSubview:imageView];
                                              }
                                              else {
                                                  UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Video Error"
                                                                                                  message:[error localizedDescription]
                                                                                                 delegate:nil
                                                                                        cancelButtonTitle:@"Dismiss"
                                                                                        otherButtonTitles:nil];
                                                  [alert show];
                                              }
                                          }];
            }
            return cell;
        }
    }
}

- (void)playVideo:(id)sender {

    // Gets an dictionary with each available youtube url
    NSDictionary *videos = [HCYoutubeParser h264videosWithYoutubeURL:[NSURL URLWithString:_videoUrl]];
    
    // Presents a MoviePlayerController with the youtube quality medium
    MPMoviePlayerViewController *mp = [[MPMoviePlayerViewController alloc] initWithContentURL:[NSURL URLWithString:[videos objectForKey:@"medium"]]];
    [self presentViewController:mp animated:YES completion:NULL];
}


#pragma mark - Navigation

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist1" stringByAppendingString:_weekTitle]] == NO) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"checklist1" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[@"checklist1" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        if (indexPath.row == 1) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist2" stringByAppendingString:_weekTitle]] == NO) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"checklist2" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[@"checklist2" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        if (indexPath.row == 2) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist3" stringByAppendingString:_weekTitle]] == NO) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"checklist3" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[@"checklist3" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
        if (indexPath.row == 3) {
            if ([[NSUserDefaults standardUserDefaults] boolForKey:[@"checklist4" stringByAppendingString:_weekTitle]] == NO) {
                UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryCheckmark;
                [[NSUserDefaults standardUserDefaults] setBool:YES forKey:[@"checklist4" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
            else {
                UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
                cell.accessoryType = UITableViewCellAccessoryNone;
                [[NSUserDefaults standardUserDefaults] setBool:NO forKey:[@"checklist4" stringByAppendingString:_weekTitle]];
                [[NSUserDefaults standardUserDefaults] synchronize];
            }
        }
    }
    /*
    if (indexPath.section == 1) {
        AllPosesViewController * firstViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"firstViewController"];
        int trimesterNumber = _sectionNumber + 1;
        NSString * labelString = [NSString stringWithFormat:@"Позы %d-го триместра", trimesterNumber];
        firstViewController.trimesterNumberNext = [NSString stringWithFormat:@"%d", trimesterNumber];
        NSLog(@"_trimesterNumber: %@", [NSString stringWithFormat:@"%d", trimesterNumber]);
        [self.navigationController pushViewController:firstViewController animated:YES];
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        self.navigationItem.title = labelString;
    }
     */
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPoseDetail2"]) {
        AllPosesViewController * allPosesViewController = segue.destinationViewController;
        
        NSInteger trimesterNumber = _sectionNumber + 1;
        allPosesViewController.trimesterNumberNext = trimesterNumber;
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

@end
