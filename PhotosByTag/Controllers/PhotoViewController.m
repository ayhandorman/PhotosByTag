//
//  PhotoViewController.m
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import "PhotoViewController.h"
#import "ImageCache.h"

@interface PhotoViewController ()
{
    
    NSString *flickrPhotoUrlFormat;
    
}

@end

@implementation PhotoViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    
    return UIStatusBarStyleLightContent;
    
}


- (void)setDefaults
{
    
    flickrPhotoUrlFormat = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrPhotoUrlFormat"];
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self setDefaults];
    
    [self getPhoto];
    
}


- (void)getPhoto
{
    
    self.lblTitle.text = self.photo.title;
    
    NSString *photoUrl = [NSString stringWithFormat:flickrPhotoUrlFormat, self.photo.farm, self.photo.server, self.photo.id, self.photo.secret, @""];
    
    [self.indicatorLoading startAnimating];
    
    // checking for a cached version of the image to list
    [ImageCache loadImage:photoUrl complete:^(UIImage *image) {
        
        self.imgPhoto.image = image;
        
        self.imgPhoto.layer.borderWidth = 0;
        
        [self.indicatorLoading stopAnimating];
        
    }];
    
}


- (IBAction)btnBackClick:(id)sender
{
    
    [self dismissViewControllerAnimated:YES completion:nil];
    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
}

@end
