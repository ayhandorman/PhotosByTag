//
//  PhotoCell.h
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PhotoCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *imgPhotoPreview;
@property (strong, nonatomic) IBOutlet UILabel *lblPhotoTitle;


@end
