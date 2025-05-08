//
//  PregnaIAPHelper.m
//  FemSpace
//
//  Created by Сергей Коваль on 3/31/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import "PregnaIAPHelper.h"

@implementation PregnaIAPHelper

+ (PregnaIAPHelper *)sharedInstance {
    static dispatch_once_t once;
    static PregnaIAPHelper * sharedInstance;
    dispatch_once(&once, ^{
        NSSet * productIdentifiers = [NSSet setWithObjects:
                                      @"com.kovallux.PregnaSutraiPhoneEN.ChildData",
                                      @"com.kovallux.PregnaSutraiPhoneEN.PregnancyCalendar",
                                      nil];
        sharedInstance = [[self alloc] initWithProductIdentifiers:productIdentifiers];
    });
    return sharedInstance;
}

@end
