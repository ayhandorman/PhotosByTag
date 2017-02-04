//
//  ViewController.h
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeViewController : UIViewController

@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoading;
@property (strong, nonatomic) IBOutlet UITableView *tablePhotos;

@end

