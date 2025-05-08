//
//  CommentsVC.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/27/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "CommentsViewController.h"
#import "Constants.h"
#import <QuartzCore/QuartzCore.h>

@interface CommentsViewController ()

@end

@implementation CommentsViewController

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

    UIBarButtonItem *btnRefresh = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addCommentButton:)];
    [self.navigationItem setRightBarButtonItems:[NSArray arrayWithObjects:self.editButtonItem, btnRefresh, nil]];
    
    self.view.backgroundColor = LIGHT_GRAY_COLOR;
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:favSaveFilePath]) {
        _messages = [NSMutableArray arrayWithContentsOfFile:favSaveFilePath];
        NSString * title = [NSString stringWithFormat:@"%@: %lu %@", NSLocalizedString(@"Комментарии", nil), (unsigned long)[_messages count], NSLocalizedString(@"шт", nil)];
        self.navigationItem.title = title;
    }
    else {
        _messages = [[NSMutableArray alloc] init];
        
        self.navigationItem.title = NSLocalizedString(@"Комментарии", nil);
        
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Введите комментарий", nil) message:nil delegate:self cancelButtonTitle:NSLocalizedString(@"Отменить", nil) otherButtonTitles:NSLocalizedString(@"Сохранить", nil), nil];
        alert.alertViewStyle = UIAlertViewStylePlainTextInput;
        alert.tag = 0;
        
        // TODO: текстовое поле в 2 строки
        UITextField * alertTextField = [alert textFieldAtIndex:0];
        alertTextField.keyboardType = UIKeyboardTypeDefault;
        alertTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
        alertTextField.placeholder = NSLocalizedString(@"Ваш комментарий", nil);
        
        [alert show];
    }
    
    
    NSArray * paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory1 = [paths1 objectAtIndex:0];
    NSString * endFileName1 = [NSString stringWithFormat:@"%@-dates.plist", _poseTitle];
    NSString * favSaveFilePath1 = [[NSString alloc] initWithString:[documentsDirectory1 stringByAppendingPathComponent:endFileName1]];
    NSFileManager * fileManager1 = [NSFileManager defaultManager];
    
    if([fileManager1 fileExistsAtPath:favSaveFilePath1]) {
        _messageDates = [NSMutableArray arrayWithContentsOfFile:favSaveFilePath1];
    }
    else {
        _messageDates = [[NSMutableArray alloc] init];
    }
}

-(void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:YES];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:237/255.0f green:22/255.0f blue:81/255.0f alpha:1.0f];
    self.navigationController.navigationBar.translucent = NO;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"CommentsCell" forIndexPath:indexPath];
    
    cell.textLabel.text = [_messages objectAtIndex:indexPath.row];
    cell.textLabel.textColor = PINK_COLOR;
    cell.textLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [_messageDates objectAtIndex:indexPath.row];
    cell.detailTextLabel.textColor = [UIColor lightGrayColor];
    
    return cell;
}

//- (void)addGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);
//- (void)removeGestureRecognizer:(UIGestureRecognizer*)gestureRecognizer NS_AVAILABLE_IOS(3_2);

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {

    NSDictionary * attributes = @{NSFontAttributeName: [UIFont boldSystemFontOfSize:FONT_SIZE]};
    CGRect rect = [[_messages objectAtIndex:indexPath.row] boundingRectWithSize:CGSizeMake(280, MAXFLOAT)
                                                                options:NSStringDrawingUsesLineFragmentOrigin
                                                             attributes:attributes
                                                                context:nil];
    return rect.size.height + 40;
}


// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}



// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [_messages removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
        NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
        
        if ([_messages count] == 0) {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:favSaveFilePath error:NULL];
        }
        else {
            [_messages writeToFile:favSaveFilePath atomically:YES];
        }
        
        // Request table view to reload
        [tableView reloadData];
        
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }
}



// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
    NSString * item = [_messages objectAtIndex:fromIndexPath.row];
    [_messages removeObject:item];
    [_messages insertObject:item atIndex:toIndexPath.row];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
    [_messages writeToFile:favSaveFilePath atomically:YES];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (BOOL)tableView:(UITableView *)tableView shouldShowMenuForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

- (BOOL)tableView:(UITableView *)tableView canPerformAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    return (action == @selector(copy:));
}

- (void)tableView:(UITableView *)tableView performAction:(SEL)action forRowAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender
{
    if (action == @selector(copy:)) {
        
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        
        UIPasteboard * pasteboard = [UIPasteboard generalPasteboard];
        [pasteboard setString:cell.textLabel.text];
        NSLog(@"in real life, we'd now copy somehow");
    }
}

#pragma mark - Add New Comment

- (void)addCommentButton:(id)sender
{
    //NSLog(@"addCommentButton works");
    
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
        
        // Add comment to file
        [_messages addObject:detailString];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * endFileName = [NSString stringWithFormat:@"%@.plist", _poseTitle];
        NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:endFileName]];
        [_messages writeToFile:favSaveFilePath atomically:YES];
        //NSLog(@"_messages: %@", _messages);
        
        // Add date to file
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterFullStyle;
        NSString * datelabel = [NSString stringWithFormat:@"%@", [dateFormatter stringFromDate:[NSDate date]]];
        [_messageDates addObject:datelabel];
        
        NSArray * paths1 = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory1 = [paths1 objectAtIndex:0];
        NSString * endFileName1 = [NSString stringWithFormat:@"%@-dates.plist", _poseTitle];
        NSString * favSaveFilePath1 = [[NSString alloc] initWithString:[documentsDirectory1 stringByAppendingPathComponent:endFileName1]];
        [_messageDates writeToFile:favSaveFilePath1 atomically:YES];
        
        [self.tableView reloadData];
        
        NSString * title = [NSString stringWithFormat:@"%@: %lu %@", NSLocalizedString(@"Комментарии", nil), (unsigned long)[_messages count], NSLocalizedString(@"шт", nil)];
        self.navigationItem.title = title;
    }
}

@end
