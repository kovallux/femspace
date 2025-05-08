//
//  main.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/12/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"


int main(int argc, char * argv[])
{

    [[NSUserDefaults standardUserDefaults] setObject:[NSArray arrayWithObjects:@"en_US", nil] forKey:@"AppleLanguages"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    @autoreleasepool {
        return UIApplicationMain(argc, argv, nil, NSStringFromClass([AppDelegate class]));
    }
}
