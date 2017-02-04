//
//  PhotoViewController.h
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Photo.h"

@interface PhotoViewController : UIViewController

@property (strong, nonatomic) Photo *photo;

@property (strong, nonatomic) IBOutlet UILabel *lblTitle;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *indicatorLoading;
@property (strong, nonatomic) IBOutlet UIImageView *imgPhoto;

- (IBAction)btnBackClick:(id)sender;

@end
