//
//  PhotoAPI.h
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Photo.h"

@interface PhotoAPI : NSObject

+ (NSURLSessionDataTask*) photosByTag:(void (^)(NSArray *photos))getPhotos failure:(void (^)(NSError *error))failure tag:(NSString*)tag;

@end
