//
//  PoseTableViewController.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/13/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "PoseTableViewController.h"
#import "BDKNotifyHUD.h"
#import <QuartzCore/QuartzCore.h>
#import "AppDelegate.h"
#import "Constants.h"
#import "Comments.h"
#import "CommentsViewController.h"
@import Social;

@interface PoseTableViewController ()

@property (strong, nonatomic) BDKNotifyHUD * notify;
@property (strong, nonatomic) NSString * imageName;
@property (strong, nonatomic) NSString * notificationTextAdded;
@property (strong, nonatomic) NSString * notificationTextRemoved;

// VK properties
@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) NSString * string;
@property (nonatomic, strong) NSURL * URL;

@end


@implementation PoseTableViewController

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
    
    NSArray * pathsComments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryComments = [pathsComments objectAtIndex:0];
    NSString * endFileNameComments = [NSString stringWithFormat:@"%@.plist", _poseTitle];
    NSString * commentsSaveFilePath = [[NSString alloc] initWithString:[documentsDirectoryComments stringByAppendingPathComponent:endFileNameComments]];
    
    NSFileManager * fileManagerComments = [NSFileManager defaultManager];
    
    if([fileManagerComments fileExistsAtPath:commentsSaveFilePath]) {
        
        _commentsArray = [NSMutableArray arrayWithContentsOfFile:commentsSaveFilePath];
        
    }
    else {
        _commentsArray = [[NSMutableArray alloc] init];
    }
    
    //NSLog(@"_commentsArray: %@", _commentsArray);
        
    self.navigationItem.title = _poseTitle;
    self.notificationTextAdded = NSLocalizedString(@"Добавлено!", nil);
    self.notificationTextRemoved = NSLocalizedString(@"Удалено!", nil);
    self.imageName = @"Checkmark.png";
    
    _poseSectionNames = @[NSLocalizedString(@"АКТИВНОСТЬ В ЭТОЙ ПОЗЕ", nil),
                          NSLocalizedString(@"КАК ПРАКТИКОВАТЬ СЕКС", nil),
                          NSLocalizedString(@"ПРЕИМУЩЕСТВА ЭТОЙ ПОЗЫ", nil),
                          NSLocalizedString(@"РИСК ЭТОЙ ПОЗЫ", nil),
                          ];

    
    _poseTexts = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"PosesData", nil) ofType:@"plist"]];

    for(int i = 0; i < [_poseTexts count]; i++)
    {
        NSMutableDictionary * name = [_poseTexts objectAtIndex:i];
        NSMutableString * currentCat = [name objectForKey:@"title"];
        
        if ([currentCat isEqualToString:_poseTitle]) {
            
            _pose = [[NSMutableDictionary alloc] init];
            [_pose setObject:[name objectForKey:@"image"] forKey:@"image"];
            [_pose setObject:[name objectForKey:@"title"] forKey:@"title"];
            [_pose setObject:[name objectForKey:@"description"] forKey:@"description"];
            [_pose setObject:[name objectForKey:@"he"] forKey:@"he"];
            [_pose setObject:[name objectForKey:@"her"] forKey:@"her"];
            [_pose setObject:[name objectForKey:@"process"] forKey:@"process"];
            [_pose setObject:[name objectForKey:@"advantage"] forKey:@"advantage"];
            [_pose setObject:[name objectForKey:@"risk"] forKey:@"risk"];
        }
    }
    
    NSDictionary * attributes = @{NSFontAttributeName: [UIFont systemFontOfSize:FONT_SIZE]};
    CGRect rect = [[_pose objectForKey:@"description"] boundingRectWithSize:CGSizeMake(300, MAXFLOAT)
                                                             options:NSStringDrawingUsesLineFragmentOrigin
                                                          attributes:attributes
                                                             context:nil];
    _rectHeight = rect.size.height;
    
    
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Favorites.plist", nil)]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSMutableArray * favoritePoses;
    
    if([fileManager fileExistsAtPath:favSaveFilePath])
    {
        favoritePoses = [[NSMutableArray alloc] initWithContentsOfFile:favSaveFilePath];
        
        if ([favoritePoses containsObject:_poseTitle]) {
            _favoritesButtonTitle = FAV_REMOVE;
        }
    }
    
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
}

-(void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear:animated];
    
    [self setFavoritesButtonTitle];
    
    [self.view setNeedsDisplay];
    [self.view setNeedsLayout];
    [self.tableView reloadData];
}

- (void) setFavoritesButtonTitle
{
    NSArray * pathsComments = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectoryComments = [pathsComments objectAtIndex:0];
    NSString * endFileNameComments = [NSString stringWithFormat:@"%@.plist", _poseTitle];
    NSString * commentsSaveFilePath = [[NSString alloc] initWithString:[documentsDirectoryComments stringByAppendingPathComponent:endFileNameComments]];
    
    NSFileManager * fileManagerComments = [NSFileManager defaultManager];
    
    if([fileManagerComments fileExistsAtPath:commentsSaveFilePath]) {
        
        _commentsArray = [NSMutableArray arrayWithContentsOfFile:commentsSaveFilePath];
        
        NSString * title = [NSString stringWithFormat:@"%@: %lu %@", NSLocalizedString(@"Комментарии", nil), (unsigned long)[_commentsArray count], NSLocalizedString(@"шт", nil)];
        _addCommentsButtonTitle = title;
    }
    else {
        _addCommentsButtonTitle = NSLocalizedString(@"Добавить комментарий", nil);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [_poseSectionNames count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return [_poseSectionNames objectAtIndex:section];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 2;
    }
    else if (section == 1) {
        return 1;
    }
    else if (section == 2) {
        return 1;
    }
    else {
        return 1;
    }
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{

    
    
    if (indexPath.section == 0) {
        
        if (indexPath.row == 0) {
            static NSString * CellIdentifier = @"CellPose00";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            cell.detailTextLabel.text = [_pose objectForKey:@"he"];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:22.0];
            cell.detailTextLabel.textColor = PINK_COLOR;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = NSLocalizedString(@"Он", nil);
            return cell;
        }
        else {
            static NSString * CellIdentifier = @"CellPose0";
            UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
            if (cell == nil) {
                cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:CellIdentifier];
            }
            cell.detailTextLabel.text = [_pose objectForKey:@"her"];
            cell.detailTextLabel.font = [UIFont systemFontOfSize:22.0];
            cell.detailTextLabel.textColor = PINK_COLOR;
            cell.textLabel.textColor = [UIColor grayColor];
            cell.textLabel.text = NSLocalizedString(@"Она", nil);
            return cell;
        }
    }
    else if (indexPath.section == 1) {
        static NSString * CellIdentifier = @"CellPose1";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [_pose objectForKey:@"process"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        return cell;
    }
    else if (indexPath.section == 2) {
        static NSString * CellIdentifier = @"CellPose2";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [_pose objectForKey:@"advantage"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        return cell;
    }
    else {
        static NSString * CellIdentifier = @"CellPose3";
        UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        }
        cell.textLabel.text = [_pose objectForKey:@"risk"];
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        return cell;
    }
    
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        
    UIView * headerView = [[UIView alloc] init];
        
        UIView * blueBackground = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, _rectHeight + 10)];
        blueBackground.backgroundColor = BLUE_COLOR;
        
        UILabel * poseLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 300, _rectHeight + 10)];
        poseLabel.font = [UIFont systemFontOfSize:FONT_SIZE];
        poseLabel.numberOfLines = 0;
        poseLabel.backgroundColor = BLUE_COLOR;
        poseLabel.textAlignment = NSTextAlignmentLeft;
        poseLabel.text = [_pose objectForKey:@"description"];
        poseLabel.textColor = PINK_COLOR;
    
    UIImage * poseImage = [UIImage imageNamed:[_pose objectForKey:@"image"]];
    UIImageView * poseImageView = [[UIImageView alloc] initWithImage:poseImage];
    poseImageView.frame = CGRectMake(0, _rectHeight + 10, 320, 200);
    poseImageView.contentMode = UIViewContentModeScaleAspectFill;
    
        UILabel * poseFirstSectionLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 210 + _rectHeight, 300, 30)];
        poseFirstSectionLabel.font = [UIFont systemFontOfSize:14.0];
        poseFirstSectionLabel.numberOfLines = 1;
        poseFirstSectionLabel.backgroundColor = [UIColor clearColor];
        poseFirstSectionLabel.textAlignment = NSTextAlignmentLeft;
        NSString * lableText = [[NSString alloc] initWithFormat:@"%@", [_poseSectionNames objectAtIndex:0]];
        [lableText uppercaseString];
        poseFirstSectionLabel.text = lableText;
        poseFirstSectionLabel.textColor = GRAY_COLOR;
        [poseFirstSectionLabel.text uppercaseString];
    
    [headerView addSubview:blueBackground];
    [headerView addSubview:poseImageView];
    [headerView addSubview:poseLabel];
    [headerView addSubview:poseFirstSectionLabel];
    
    return headerView;
        
    }
    else {
        return nil;
    }
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section {
    
    if (section == [_poseSectionNames count] - 1) {
        UIView * footerView  = [[UIView alloc] init];
        
        UIButton * favoritesButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [favoritesButton setFrame:CGRectMake(10, 10, 300, 44)];
        [favoritesButton setTitle:_favoritesButtonTitle forState:UIControlStateNormal];
        [favoritesButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [favoritesButton addTarget:self action:@selector(addToFavorites:) forControlEvents:UIControlEventTouchUpInside];
        // Add border to button
        favoritesButton.layer.borderWidth = 1.0f;
        favoritesButton.layer.borderColor = [PINK_COLOR CGColor];
        favoritesButton.layer.cornerRadius = 8.0f;
        [footerView addSubview:favoritesButton];
        
        UIButton * commentsButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        [commentsButton setFrame:CGRectMake(10, 30 + favoritesButton.frame.size.height, 300, 44)];
        [commentsButton setTitle:_addCommentsButtonTitle forState:UIControlStateNormal];
        [commentsButton.titleLabel setFont:[UIFont systemFontOfSize:18]];
        [commentsButton addTarget:self action:@selector(goToComments:) forControlEvents:UIControlEventTouchUpInside];
        // Add border to button
        commentsButton.layer.borderWidth = 1.0f;
        commentsButton.layer.borderColor = [PINK_COLOR CGColor];
        commentsButton.layer.cornerRadius = 8.0f;
        [footerView addSubview:commentsButton];
        
        return footerView;
    }
    else {
        return nil;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    if (section == 0) {
        return 240 + _rectHeight;
    }
    else {
        return 20;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    
    if (section == [_poseSectionNames count] - 1) {
        return 150;
    }
    else {
        return 0;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 1) {
        NSDictionary * attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE]};
        CGRect rect = [[_pose objectForKey:@"process"] boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                                    attributes:attributes
                                                                       context:nil];
        return rect.size.height + 10;
    }
    if (indexPath.section == 2) {
        NSDictionary * attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE]};
        CGRect rect = [[_pose objectForKey:@"advantage"] boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:attributes
                                                                 context:nil];
        return rect.size.height + 10;
    }
    if (indexPath.section == 3) {
        NSDictionary * attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE]};
        CGRect rect = [[_pose objectForKey:@"risk"] boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                                              attributes:attributes
                                                                 context:nil];
        return rect.size.height + 10;
    }
    else {
        return 44.0f;
    }
}

- (IBAction)addToFavorites:(id)sender
{
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Favorites.plist", nil)]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    NSMutableArray * favoritePoses;
    
    if([fileManager fileExistsAtPath:favSaveFilePath])
    {
        favoritePoses = [[NSMutableArray alloc] initWithContentsOfFile:favSaveFilePath];
        
        if ([favoritePoses containsObject:_poseTitle]) {
            
            [favoritePoses removeObject:_poseTitle];
            
            if ([favoritePoses count] == 0) {
                NSFileManager * fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:favSaveFilePath error:NULL];
            }
            else {
                [favoritePoses writeToFile:favSaveFilePath atomically:YES];
            }
            
            //[favoritePoses writeToFile:favSaveFilePath atomically:YES];
            _favoritesButtonTitle = FAV_ADD;
            [self.tableView reloadData];
            
            // Create the HUD object; view can be a UIImageView, an icon... you name it
            BDKNotifyHUD *hud = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:self.imageName] text:self.notificationTextRemoved];
            hud.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
            AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
            [appDelegate.window addSubview:hud];
            [hud presentWithDuration:1.0f speed:0.5f inView:self.view completion:^{
                [hud removeFromSuperview];
            }];
        }
        else {
            [favoritePoses addObject:_poseTitle];
            
            if ([favoritePoses count] == 0) {
                NSFileManager * fileManager = [NSFileManager defaultManager];
                [fileManager removeItemAtPath:favSaveFilePath error:NULL];
            }
            else {
                [favoritePoses writeToFile:favSaveFilePath atomically:YES];
            }
            
            //[favoritePoses writeToFile:favSaveFilePath atomically:YES];
            _favoritesButtonTitle = FAV_REMOVE;
            [self.tableView reloadData];
            
            // Notification.
            [self displayNotification];
            
            //NSLog(@"File exists");
        }
        
    } else {
        
        favoritePoses = [[NSMutableArray alloc] init];
        [favoritePoses addObject:_poseTitle];
        
        if ([favoritePoses count] == 0) {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:favSaveFilePath error:NULL];
        }
        else {
            [favoritePoses writeToFile:favSaveFilePath atomically:YES];
        }
        
        //[favoritePoses writeToFile:favSaveFilePath atomically:YES];
        _favoritesButtonTitle = FAV_REMOVE;
        [self.tableView reloadData];
        
        // Notification.
        [self displayNotification];
        
        //NSLog(@"File does not exist");
    }
}

- (IBAction)goToComments:(id)sender
{
    CommentsViewController * commentsView = [self.storyboard instantiateViewControllerWithIdentifier:@"CommentsTable"];
    commentsView.poseTitle = [_pose objectForKey:@"title"];
    [self.navigationController pushViewController:commentsView animated:YES];
    self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
}


#pragma mark - Action Sheet methods


-(IBAction)alertAction:(id)sender
{
    UIActionSheet *popupQuery = [[UIActionSheet alloc] initWithTitle:nil
                                                            delegate:self
                                                   cancelButtonTitle:NSLocalizedString(@"Отменить", nil)
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:
                                 NSLocalizedString(@"Отправить в Facebook", nil),
                                 NSLocalizedString(@"Отправить в Twitter", nil),
                                 NSLocalizedString(@"Отправить в Vkontakte", nil),
                                 NSLocalizedString(@"Отправить по Email", nil),
                                 nil];
    popupQuery.actionSheetStyle = UIActionSheetStyleBlackTranslucent;
    [popupQuery showInView:[UIApplication sharedApplication].keyWindow];
}

-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex {
	
    if (buttonIndex == 0) {
        NSLog(@"Отправленно в Facebook");
        [self postToFacebook];
    }
    else if (buttonIndex == 1) {
        NSLog(@"Отправленно в Tweeter");
        [self postToTwitter];
    }
    else if (buttonIndex == 2) {
        NSLog(@"Отправленно в Vkontakte");
    }
    else if (buttonIndex == 3) {
        NSLog(@"Отправленно по Email");
        [self sendToEmail];
    }
    else {
        NSLog(@"Отмена");
    }
    
    //actionSheet.actionSheetStyle = UIActionSheetStyleAutomatic;
}

- (void) postToFacebook {
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]) {
        SLComposeViewController * composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
        
        NSString * heValue = NSLocalizedString(@"Он", nil);
        NSString * herValue = NSLocalizedString(@"Она", nil);
        NSString * appName = NSLocalizedString(@"ПрегнаСутра для iOS", nil);
        NSString * initialText = [NSString stringWithFormat:
                                  @"%@\n%@\n\n%@\n%@: %@\n%@: %@\n\n%@\n%@\n\n%@\n%@\n\n%@\n%@\n\n%@",
                                  [_pose objectForKey:@"title"], [_pose objectForKey:@"description"],
                                  [_poseSectionNames objectAtIndex:0],
                                  heValue, [_pose objectForKey:@"he"],
                                  herValue, [_pose objectForKey:@"her"],
                                  [_poseSectionNames objectAtIndex:1], [_pose objectForKey:@"process"],
                                  [_poseSectionNames objectAtIndex:2], [_pose objectForKey:@"advantage"],
                                  [_poseSectionNames objectAtIndex:3], [_pose objectForKey:@"risk"],
                                  appName];
        //[composeController setInitialText:[_pose objectForKey:@"description"]];
        [composeController setInitialText:initialText];
        [composeController addImage:[UIImage imageNamed:[_pose objectForKey:@"image"]]];
        [composeController addURL: [NSURL URLWithString:@"https://itunes.apple.com/us/app/mamalubov-kalendar-beremennosti/id853565736?ls=1&mt=8"]];
        
        [composeController setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                                message:@"Post Cancelled"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    [[[UIAlertView alloc] initWithTitle:@"Facebook"
                                                message:@"Posted to Facebook successfully"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:composeController animated:YES completion:nil];
    }
}

- (void) postToTwitter
{
    if([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]) {
        SLComposeViewController * composeController = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        
        [composeController setInitialText:[_pose objectForKey:@"description"]];
        [composeController addImage:[UIImage imageNamed:[_pose objectForKey:@"image"]]];
        [composeController addURL: [NSURL URLWithString:@"https://itunes.apple.com/us/app/mamalubov-kalendar-beremennosti/id853565736?ls=1&mt=8"]];
        
        [composeController setCompletionHandler:^(SLComposeViewControllerResult result) {
            
            switch (result) {
                case SLComposeViewControllerResultCancelled:
                    NSLog(@"Post Canceled");
                    [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                                message:@"Post Cancelled"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                    break;
                case SLComposeViewControllerResultDone:
                    NSLog(@"Post Sucessful");
                    [[[UIAlertView alloc] initWithTitle:@"Twitter"
                                                message:@"Posted to Twitter successfully"
                                               delegate:nil
                                      cancelButtonTitle:@"OK"
                                      otherButtonTitles:nil]
                     show];
                    break;
                    
                default:
                    break;
            }
        }];
        
        [self presentViewController:composeController animated:YES completion:nil];
    }
}

 
#pragma mark - Contact Us methods

- (void)sendToEmail
{
    
    if ([MFMailComposeViewController canSendMail])
    {
        // Email Subject
        NSString * emailTitle = [NSString stringWithFormat:
                                 NSLocalizedString(@"%@ — ПрегнаСутра для iOS", nil), [_pose objectForKey:@"title"]];
        
        // Email Content
        NSString * heValue = NSLocalizedString(@"Он", nil);
        NSString * herValue = NSLocalizedString(@"Она", nil);
        NSString * appName = NSLocalizedString(@"ПрегнаСутра для iOS", nil);
        NSString * initialText = [NSString stringWithFormat:
                                  @"<html><head></head><body style='font-weight:bold;'>"
                                  @"<p><strong>%@</strong><br>%@</p>"
                                  @"<p><strong>%@</strong><br>%@: <strong>%@</strong><br>%@: <strong>%@</strong></p>"
                                  @"<p><strong>%@</strong><br>%@</p>"
                                  @"<p><strong>%@</strong><br>%@</p>"
                                  @"<p><strong>%@</strong><br>%@</p>"
                                  @"<p><strong>%@</strong></p>"
                                  @"</body></html>",
                                  [_pose objectForKey:@"title"], [_pose objectForKey:@"description"],
                                  [_poseSectionNames objectAtIndex:0],
                                  heValue, [_pose objectForKey:@"he"],
                                  herValue, [_pose objectForKey:@"her"],
                                  [_poseSectionNames objectAtIndex:1], [_pose objectForKey:@"process"],
                                  [_poseSectionNames objectAtIndex:2], [_pose objectForKey:@"advantage"],
                                  [_poseSectionNames objectAtIndex:3], [_pose objectForKey:@"risk"],
                                  appName];
        // To address
        //NSArray *toRecipents = [NSArray arrayWithObject:@""];
        
        MFMailComposeViewController *mc = [[MFMailComposeViewController alloc] init];
        mc.mailComposeDelegate = self;
        [mc setSubject:emailTitle];
        [mc setMessageBody:initialText isHTML:YES];
        [mc setToRecipients:nil];
        
        // Email image
        UIImage *myImage = [UIImage imageNamed:[_pose objectForKey:@"image"]];
        NSData *imageData = UIImagePNGRepresentation(myImage);
        [mc addAttachmentData:imageData mimeType:@"image/png" fileName:[_pose objectForKey:@"image"]];
        
        // Present mail view controller on screen
        [self presentViewController:mc animated:YES completion:NULL];
    }
    else
    {
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"Failure"
                                                        message:@"Your device doesn't support the composer sheet"
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
    
    
    //[[Crashlytics sharedInstance] crash];
    
    
}

- (void) mailComposeController:(MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error
{
    switch (result)
    {
        case MFMailComposeResultCancelled:
        {
            NSLog(@"Mail cancelled");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail cancelled"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        case MFMailComposeResultSaved:
        {
            NSLog(@"Mail saved");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail saved"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        case MFMailComposeResultSent:
        {
            NSLog(@"Mail sent");
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail sent"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        case MFMailComposeResultFailed:
        {
            NSLog(@"Mail sent failure: %@", [error localizedDescription]);
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail error"
                                                            message:nil
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
        }
            break;
        default:
            break;
    }
    
    // Close the Mail Interface
    [self dismissViewControllerAnimated:YES completion:NULL];
}

#pragma mark - Notififcation methods

- (BDKNotifyHUD *)notify {
    if (_notify != nil) return _notify;
    _notify = [BDKNotifyHUD notifyHUDWithImage:[UIImage imageNamed:self.imageName] text:self.notificationTextAdded];
    _notify.center = CGPointMake(self.view.center.x, self.view.center.y - 20);
    return _notify;
}

- (void)displayNotification {
    if (self.notify.isAnimating) return;
    
    //[self.view addSubview:self.notify];
    AppDelegate * appDelegate = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    [appDelegate.window addSubview:self.notify];
    [self.notify presentWithDuration:1.0f speed:0.5f inView:self.view completion:^{
        [self.notify removeFromSuperview];
    }];
}

@end
