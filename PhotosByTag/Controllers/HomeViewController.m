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
#import "Flickr.h"

@interface HomeViewController ()
{
    
    id <PhotoAPI> photoAPI;
    
    NSString *flickrRestServiceUrl;

    NSString *flickrPhotoUrlFormat;

    NSMutableArray *photoList;
    
    int currentPageNo;
    
    BOOL loadingPhotos;
    
    CGRect screenRect;
    
}

@end

@implementation HomeViewController


- (UIStatusBarStyle)preferredStatusBarStyle
{
    
    return UIStatusBarStyleLightContent;
    
}


- (void)setDefaults
{
    
    photoAPI = [[Flickr alloc] init];
    
    flickrRestServiceUrl = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrRestServiceUrl"];

    flickrPhotoUrlFormat = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrPhotoUrlFormat"];
    
    photoList = [[NSMutableArray alloc] init];
    
    currentPageNo = 1;
    
    loadingPhotos = NO;
    
    screenRect = [[UIScreen mainScreen] bounds];
    
}


- (void)setUI
{
    
    self.viewNotification.layer.cornerRadius = 10;
    
    self.viewNotification.layer.borderWidth = 2;
    
    self.viewNotification.layer.borderColor = [UIColor whiteColor].CGColor;
    
    CGRect frame = self.viewNotification.frame;
    
    frame.origin.y = screenRect.size.height;
    
    self.viewNotification.frame = frame;
    
}


- (void)viewDidLoad
{
    
    [super viewDidLoad];
    
    [self setDefaults];
    
    [self setUI];
    
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
    
    NSLog(@"currentPageNo: %d", currentPageNo);
    
    // <queries photos by specified tag>
    
    [self.indicatorLoading startAnimating];
    
    loadingPhotos = YES;
    
    [photoAPI photosByTag:^(NSArray *photos) {
        
        [self.indicatorLoading stopAnimating];
        
        if (photos.count > 0)
        {
            
            if (currentPageNo == 1)
            {
                
                [photoList addObjectsFromArray:photos];
                
                [self.tablePhotos reloadData];
                
            }
            else
            {
                
                NSMutableArray *indexPaths = [NSMutableArray array];
                
                NSInteger currentCount = photoList.count;
                
                for (int i = 0; i < photos.count; i++) {
                    
                    [indexPaths addObject:[NSIndexPath indexPathForRow:currentCount+i inSection:0]];
                    
                }
            
                [photoList addObjectsFromArray:photos];

                [self.tablePhotos beginUpdates];
                
                [self.tablePhotos insertRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationTop];
                
                [self.tablePhotos endUpdates];
                
            }
            
            CGRect frame = self.viewNotification.frame;
            
            frame.origin.y = screenRect.size.height - frame.size.height - 23;
            
            [UIView animateWithDuration:.4 delay:.2 options:UIViewAnimationOptionCurveEaseOut animations:^{
                
                self.viewNotification.frame = frame;
                
            } completion:nil];
            
            currentPageNo++;
            
        }
        
        loadingPhotos = NO;
        
    } failure:^(NSError *error) {
        
        loadingPhotos = NO;
        
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
        
    } tag:@"moda" page:currentPageNo];
    
    // </queries photos by specified tag>
    
}


-(void) scrollViewDidScroll:(UIScrollView *)sView
{
    
    if (sView == self.tablePhotos)
    {
        
        CGRect frame = self.viewNotification.frame;
        
        if (frame.origin.y < screenRect.size.height)
        {
            
            [UIView animateWithDuration:.2 animations:^{
                
                self.viewNotification.frame = CGRectMake(frame.origin.x, screenRect.size.height, frame.size.width, frame.size.height);
                
            }];
            
        }
    
        if (photoList.count > 10 &&
            sView.contentOffset.y >= sView.contentSize.height - sView.frame.size.height &&
            !loadingPhotos)
        {
            
            [self getPhotos];
            
        }
        
    }
    
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
