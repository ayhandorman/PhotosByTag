//
//  ViewController.m
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import "HomeViewController.h"
#import "PhotoViewController.h"
#import "Reachability.h"
#import "ImageCache.h"
#import "StringOperations.h"
#import "PhotoCell.h"
#import "PhotoAPI.h"

@interface HomeViewController ()
{
    
    NSString *flickrRestServiceUrl;

    NSString *flickrPhotoUrlFormat;

    NSMutableArray *photoList;
    
    int currentPageNo;
    
}

@end

@implementation HomeViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    
    return UIStatusBarStyleLightContent;
    
}


- (void)setDefaults
{
    
    flickrRestServiceUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrRestServiceUrl"];

    flickrPhotoUrlFormat = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrPhotoUrlFormat"];
    
    photoList = [[NSMutableArray alloc] init];
    
    currentPageNo = 1;
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self setDefaults];
    
    [self performSelector:@selector(testInternetConnection) withObject:nil afterDelay:.1];
    
}


- (void)testInternetConnection
{
    
    // <checks if the service is available>
    
    __weak typeof(self) weakSelf = self;
    
    Reachability *reach = [Reachability reachabilityWithHostname:flickrRestServiceUrl];
    
    // service is available
    reach.reachableBlock = ^(Reachability *reach)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [weakSelf getPhotos];
            
        });
        
    };
    
    // service is unavailable
    reach.unreachableBlock = ^(Reachability*reach)
    {
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            UIAlertController *alert = [UIAlertController
                                        alertControllerWithTitle:NSLocalizedString(@"error", nil)
                                        message:NSLocalizedString(@"service_unavailable", nil)
                                        preferredStyle:UIAlertControllerStyleAlert];
            
            UIAlertAction *ok = [UIAlertAction
                                 actionWithTitle:NSLocalizedString(@"ok", nil)
                                 style:UIAlertActionStyleDefault
                                 handler:nil];
            
            [alert addAction:ok];
            
            [weakSelf presentViewController:alert animated:YES completion:nil];
            
        });
        
    };
    
    [reach startNotifier];
    
    // </checks if the service is available>
    
}


- (void)getPhotos
{
    
    // <queries photos by specified tag>
    
    [self.indicatorLoading startAnimating];
    
    [PhotoAPI photosByTag:^(NSArray *photos) {
        
        photoList = [photos copy];
        
        [self.tablePhotos reloadData];
        
        [self.indicatorLoading stopAnimating];
        
    } failure:^(NSError *error) {
        
        [self.indicatorLoading stopAnimating];
        
        UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:NSLocalizedString(@"error", nil)
                                    message:error.localizedDescription
                                    preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction *ok = [UIAlertAction
                             actionWithTitle:NSLocalizedString(@"ok", nil)
                             style:UIAlertActionStyleDefault
                             handler:nil];
        
        [alert addAction:ok];
        
        [self presentViewController:alert animated:YES completion:nil];
        
    } tag: @"moda"];
    
    // </queries photos by specified tag>
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    if (tableView == self.tablePhotos)
    {
        
        return photoList.count;
        
    }
    else
    {
        
        return 0;
        
    }
    
}


- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tablePhotos)
    {
        
        static NSString *cellIdentifier = @"cellPhoto";
        
        PhotoCell *cell = (PhotoCell*)[tableView dequeueReusableCellWithIdentifier:cellIdentifier forIndexPath:indexPath];
        
        if (cell == nil) cell = [[PhotoCell alloc] init];
        
        Photo *photo = [photoList objectAtIndex:indexPath.row];
        
        NSString *photoUrl = [NSString stringWithFormat:flickrPhotoUrlFormat, photo.farm, photo.server, photo.id, photo.secret, @"_q"];
        
        cell.imgPhotoPreview.image = nil;
        
        // checking for a cached version of the image to list
        [ImageCache loadImage:photoUrl complete:^(UIImage *image) {
            
            cell.imgPhotoPreview.image = image;
            
            cell.imgPhotoPreview.layer.cornerRadius = 5;
            
            cell.imgPhotoPreview.layer.borderWidth = 0;
            
        }];
        
        cell.lblPhotoTitle.text = photo.title;
        
        return cell;
        
    }
    else
    {
        
        return [UITableViewCell alloc];
        
    }
    
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView == self.tablePhotos)
    {
        
        PhotoViewController *pvc = (PhotoViewController *)[self.storyboard instantiateViewControllerWithIdentifier:@"viewPhoto"];
        
        pvc.photo = [photoList objectAtIndex:indexPath.row];
        
        pvc.modalTransitionStyle = UIModalTransitionStylePartialCurl;
        
        [self presentViewController:pvc animated:YES completion:nil];
        
    }
    
    [tableView deselectRowAtIndexPath:[tableView indexPathForSelectedRow] animated:NO];
    
}


- (void)didReceiveMemoryWarning
{
    
    [super didReceiveMemoryWarning];
    
}


@end
