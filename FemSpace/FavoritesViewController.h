//
//  FavoritesViewController.h
//  FemSpace
//
//  Created by Сергей Коваль on 3/18/14.
//  Copyright (c) 2014 kovallux Dev. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface FavoritesViewController : UITableViewController

@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIView * noFavoritesView;
@property (nonatomic, strong) UILabel  * noFavoritesLabel;

@property (nonatomic, strong) NSMutableArray * favoritePoses;

@end
