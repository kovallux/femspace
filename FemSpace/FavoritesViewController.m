//
//  FavoritesViewController.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/18/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "FavoritesViewController.h"
#import "AppDelegate.h"
#import "PoseTableViewController.h"
#import "Constants.h"
#import "UIImage+Resize.h"

@interface FavoritesViewController ()

@end

@implementation FavoritesViewController

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
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    //self.navigationItem.leftBarButtonItem = self.editButtonItem;
    
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
    self.navigationItem.title = NSLocalizedString(@"☆ Избранное ☆", nil);
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Favorites.plist", nil)]];
    
    NSFileManager * fileManager = [NSFileManager defaultManager];
    
    if([fileManager fileExistsAtPath:favSaveFilePath] /* && [_favoritePoses count] != 0 */)
    {
        _favoritePoses = [[NSMutableArray alloc] initWithContentsOfFile:favSaveFilePath];
        //NSLog(@"File exists.");
        
        [_noFavoritesView removeFromSuperview];
        [_imageView removeFromSuperview];
        [_noFavoritesLabel removeFromSuperview];
        
        self.tableView.separatorColor = SEPARATOR_COLOR;
        [self.tableView reloadData];
        
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.navigationItem.leftBarButtonItem.enabled = YES;
    } else {
        _favoritePoses = nil;
        //NSLog(@"File does not exist.");
        
        _noFavoritesView = [[UIView alloc] init];
        [_noFavoritesView setFrame:CGRectMake(0, 0, 320, 480)];
        _noFavoritesView.backgroundColor = SEPARATOR_COLOR;
        
        UIImage * image = [UIImage imageNamed:@"noFavorites"];
        CGFloat width = image.size.width;
        CGFloat height = image.size.height;
        
        /*
        CGRect screenBound = [[UIScreen mainScreen] bounds];
        CGSize screenSize = screenBound.size;
        CGFloat screenWidth = screenSize.width;
        CGFloat screenHeight = screenSize.height;
        */
         
        _imageView = [[UIImageView alloc] initWithImage:image];
        [_imageView setFrame:CGRectMake(130, 170, width, height)];
        _imageView.alpha = 0.1f;
        
        _noFavoritesLabel = [[UILabel alloc] initWithFrame:CGRectMake(50, 230, 220, 50)];
        _noFavoritesLabel.backgroundColor = [UIColor clearColor];
        _noFavoritesLabel.textAlignment = NSTextAlignmentCenter;
        _noFavoritesLabel.textColor = [UIColor blackColor];
        _noFavoritesLabel.shadowColor = [UIColor whiteColor];
        _noFavoritesLabel.shadowOffset = CGSizeMake(-1.0,-1.0);
        _noFavoritesLabel.alpha = 0.3f;
        _noFavoritesLabel.text = NSLocalizedString(@"Нет избранных поз", nil);
        
        [self.view addSubview:_noFavoritesView];
        [self.view addSubview:_imageView];
        [self.view addSubview:_noFavoritesLabel];
        
        self.tableView.separatorColor = [UIColor clearColor];
        self.navigationItem.leftBarButtonItem = self.editButtonItem;
        self.navigationItem.leftBarButtonItem.enabled = NO;
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
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [_favoritePoses count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"Cell0" forIndexPath:indexPath];
    
    //NSArray * sortedArray = [_favoritePoses sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    //cell.textLabel.text = [sortedArray objectAtIndex:indexPath.row];
    
    NSMutableArray * allPoses = [NSMutableArray arrayWithContentsOfFile:[[NSBundle mainBundle] pathForResource:NSLocalizedString(@"PosesData", nil) ofType:@"plist"]];
    for(int i = 0; i < [allPoses count]; i++)
    {
        NSMutableDictionary * name = [allPoses objectAtIndex:i];
        NSMutableString * currentCat = [name objectForKey:@"title"];
        
        if ([currentCat isEqualToString:[_favoritePoses objectAtIndex:indexPath.row]]) {
            
            UIImage * image = [UIImage imageNamed:[name objectForKey:@"image"]];
            CGSize size = CGSizeMake(64, 44);
            UIImage * scaledImage = [image resizedImage:size interpolationQuality:kCGInterpolationHigh];
            //UIImage * thumbImage = [image thumbnailImage:44 transparentBorder:0 cornerRadius:0 interpolationQuality:kCGInterpolationNone];
            
            
            /*
            //	==============================================================
            //	resizedImage
            //	==============================================================
            
                CGImageRef			imageRef = [image CGImage];
                CGImageAlphaInfo	alphaInfo = CGImageGetAlphaInfo(imageRef);
                CGRect thumbRect = CGRectMake(0, 0, 64, 44);
            
                if (alphaInfo == kCGImageAlphaNone)
                    alphaInfo = kCGImageAlphaNoneSkipLast;
                
                // Build a bitmap context that's the size of the thumbRect
                CGContextRef bitmap = CGBitmapContextCreate(
                                                            NULL,
                                                            thumbRect.size.width,		// width
                                                            thumbRect.size.height,		// height
                                                            CGImageGetBitsPerComponent(imageRef),	// really needs to always be 8
                                                            4 * thumbRect.size.width,	// rowbytes
                                                            CGImageGetColorSpace(imageRef),
                                                            alphaInfo
                                                            );
                
                // Draw into the context, this scales the image
                CGContextDrawImage(bitmap, thumbRect, imageRef);
                
                // Get an image from the context and a UIImage
                CGImageRef	ref = CGBitmapContextCreateImage(bitmap);
                UIImage*	result = [UIImage imageWithCGImage:ref];
                
                CGContextRelease(bitmap);	// ok if NULL
                CGImageRelease(ref);
             */
            
            //cell.imageView.layer.magnificationFilter = kCAFilterNearest;
            cell.imageView.image = scaledImage;
            cell.imageView.contentMode = UIViewContentModeScaleToFill;
            
            //UIImageView *imageView = [[UIImageView alloc] initWithImage:[name objectForKey:@"image"]];
            //imageView.frame = CGRectMake(0, 0, 44, 44);
            //[cell.contentView addSubview:imageView];
        }
    }
    
    cell.textLabel.text = [_favoritePoses objectAtIndex:indexPath.row];
    return cell;
}


#pragma mark - Table Editing

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
        [_favoritePoses removeObjectAtIndex:indexPath.row];
        
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        
        
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString * documentsDirectory = [paths objectAtIndex:0];
        NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Favorites.plist", nil)]];
        
        if ([_favoritePoses count] == 0) {
            NSFileManager * fileManager = [NSFileManager defaultManager];
            [fileManager removeItemAtPath:favSaveFilePath error:NULL];
        }
        else {
            [_favoritePoses writeToFile:favSaveFilePath atomically:YES];
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
    NSString * item = [_favoritePoses objectAtIndex:fromIndexPath.row];
    [_favoritePoses removeObject:item];
    [_favoritePoses insertObject:item atIndex:toIndexPath.row];
    
    NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString * documentsDirectory = [paths objectAtIndex:0];
    NSString * favSaveFilePath = [[NSString alloc] initWithString:[documentsDirectory stringByAppendingPathComponent:NSLocalizedString(@"Favorites.plist", nil)]];
    [_favoritePoses writeToFile:favSaveFilePath atomically:YES];
}



// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}



#pragma mark - Table Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showPoseDetail"]) {
        PoseTableViewController * poseViewController = segue.destinationViewController;
        
        NSIndexPath * indexPath = [self.tableView indexPathForSelectedRow];
        UITableViewCell * cell = [self.tableView cellForRowAtIndexPath:indexPath];
        NSString * str = cell.textLabel.text;
        
        poseViewController.poseTitle = str;
        poseViewController.favoritesButtonTitle = NSLocalizedString(@"Удалить из Избранного", nil);
        
        self.navigationItem.backBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}


@end
