//
//  BirthCalendar.m
//  PregnaSutra
//
//  Created by Сергей Коваль on 3/23/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "Comments.h"
#import "PTSMessagingCell.h"
#import "Constants.h"
#import "RDRStickyKeyboardView.h"

static NSString * const CellIdentifier = @"cell";

@interface Comments ()

@end

@implementation Comments

/*
- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}
 */

- (void)viewDidLoad
{
    [super viewDidLoad];

    UIButton * addButton = [UIButton buttonWithType:UIButtonTypeContactAdd];
    [addButton addTarget:self action:@selector(addCommentButton:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:addButton];
    self.navigationItem.rightBarButtonItem = rightBarButtonItem;
    
    self.view.backgroundColor = LIGHT_GRAY_COLOR;
    [self _setupSubviews];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:favSaveFilePath]) {
        _messages = [NSArray arrayWithContentsOfFile:favSaveFilePath];
        NSString * title = [NSString stringWithFormat:@"%@: %lu %@", NSLocalizedString(@"Комментарии", nil), (unsigned long)[_messages count], NSLocalizedString(@"шт", nil)];
        self.navigationItem.title = title;
    }
    else {
        _messages = [[NSMutableArray alloc] init];
        
        self.navigationItem.title = NSLocalizedString(@"Комментарии", nil);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите комментарий", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;
        
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        alertTextField.placeholder = NSLocalizedString(@"Ваш комментарий", nil);
        [alert show];
    }
}

- (void)_setupSubviews
{
    // Setup tableview
    self.tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:CellIdentifier];
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundColor = LIGHT_GRAY_COLOR;
    self.tableView.contentInset = UIEdgeInsetsMake(0.0f, 0.0f, CGRectGetHeight(self.tabBarController.tabBar.frame), 0.0f);
    //[self.view addSubview:self.tableView];
    //[self.tableView reloadData];
    //[self.view setNeedsDisplay];
    //[self.view setNeedsLayout];

}

-(void)viewWillAppear:(BOOL)animated
{
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(setNeedsDisplay) name:@"ViewControllerShouldReloadNotification" object:nil];
    
    //[self _setupSubviews];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_messages count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //static NSString* cellIdentifier = @"messagingCell";
    
    PTSMessagingCell * cell = (PTSMessagingCell*) [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[PTSMessagingCell alloc] initMessagingCellWithReuseIdentifier:CellIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
    
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    CGSize messageSize = [PTSMessagingCell messageSize:[_messages objectAtIndex:indexPath.row]];
    return messageSize.height + 2*[PTSMessagingCell textMarginVertical] + 40.0f;
}

-(void)configureCell:(id)cell atIndexPath:(NSIndexPath *)indexPath {
    PTSMessagingCell * ccell = (PTSMessagingCell*)cell;
    
    ccell.sent = YES;
    //ccell.avatarImageView.image = [UIImage imageNamed:@"person1"];
    
    /*
    if (indexPath.row % 2 == 0) {
        ccell.sent = YES;
        ccell.avatarImageView.image = [UIImage imageNamed:@"person1"];
    } else {
        ccell.sent = NO;
        ccell.avatarImageView.image = [UIImage imageNamed:@"person2"];
    }
    */
    
    ccell.messageLabel.text = [_messages objectAtIndex:indexPath.row];
    ccell.timeLabel.text = @"2012-08-29";
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Add New Comment

- (void)addCommentButton:(id)sender
{
    NSLog(@"addCommentButton works");
    
    UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите комментарий", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil];
    alert.alertViewStyle = UIAlertViewStylePlainTextInput;
    alert.tag = 0;
    
    UITextField * alertTextField = [alert textFieldAtIndex:0];
    alertTextField.keyboardType = UIKeyboardTypeDefault;
    alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    alertTextField.placeholder = NSLocalizedString(@"Ваш комментарий", nil);
    [alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    NSString * detailString = [[alertView textFieldAtIndex:0] text];
    
    if ([detailString length] < 1 || buttonIndex == 0){
        NSLog(@"Отмена");
        return;
    }
    
    if (buttonIndex == 1) {
        
        //NSLog(@"Added: %@", detailString);
        
        [_messages addObject:detailString];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
        NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
        [_messages writeToFile:favSaveFilePath atomically:YES];
        
        NSLog(@"_messages: %@", _messages);
        
        [self.tableView reloadData];
        //NSIndexSet * sections = [NSIndexSet indexSetWithIndex:0];
        //[self.tableView reloadSections:sections withRowAnimation:UITableViewRowAnimationAutomatic];
        
        //[self.tableView removeFromSuperview];
        //[self _setupSubviews];
        //[self.view setNeedsDisplay];
        //[self.view setNeedsLayout];
        
        //[super reloadInputViews];
        
        //NSIndexPath * path1 = [NSIndexPath indexPathForRow:[_messages count] - 1 inSection:0];
        //NSArray * indexArray = [NSArray arrayWithObjects:path1, nil];
        
        //[self.tableView beginUpdates];
        //[self.tableView insertRowsAtIndexPaths:indexArray withRowAnimation:UITableViewRowAnimationRight];
        //[self.tableView endUpdates];
    }
}

@end
