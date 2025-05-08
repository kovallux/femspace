//
//  ADViewController.m
//  Sonnik
//
//  Created by Sergey Koval on 09/03/16.
//  Copyright © 2016 kovallux dev, LLC. All rights reserved.
//

#import "ADViewController.h"
#import <StoreKit/SKStoreProductViewController.h>

@interface ADViewController () <SKStoreProductViewControllerDelegate>

@end

@implementation ADViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setNeedsStatusBarAppearanceUpdate];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (UIStatusBarStyle) preferredStatusBarStyle {
    return UIStatusBarStyleDefault;
}

#pragma mark - Helpers

-(IBAction)dismiss:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}

-(IBAction)launchPregnaSutra:(id)sender {
    [self openProduct:@"847629858"];
}

-(IBAction)launchVisualHear:(id)sender {
    [self openProduct:@"899882405"];
}

- (void)openProduct:(NSString*)productID {
    SKStoreProductViewController *storeProductViewController = [[SKStoreProductViewController alloc] init];
    [storeProductViewController setDelegate:self];
    storeProductViewController.title = @"Our apps";
    [storeProductViewController loadProductWithParameters:@{SKStoreProductParameterITunesItemIdentifier : productID} completionBlock:^(BOOL result, NSError *error) {
        if (error) {
            NSLog(@"Error %@ with User Info %@.", error, [error userInfo]);
            
        } else {
            [self presentViewController:storeProductViewController animated:YES completion:nil];
        }
    }];
}

#pragma mark - SKStoreProductViewControllerDelegate

- (void)productViewControllerDidFinish:(SKStoreProductViewController *)viewController {
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
