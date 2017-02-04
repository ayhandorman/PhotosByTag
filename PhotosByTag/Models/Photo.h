//
//  Photo.h
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Photo : NSObject

@property (strong, nonatomic) NSString *id;
@property (strong, nonatomic) NSString *owner;
@property (strong, nonatomic) NSString *secret;
@property (strong, nonatomic) NSString *server;
@property (strong, nonatomic) NSString *farm;
@property (strong, nonatomic) NSString *title;
@property (strong, nonatomic) NSString *ispublic;
@property (strong, nonatomic) NSString *isfriend;
@property (strong, nonatomic) NSString *isfamily;

- (instancetype)initWithAttributes:(NSDictionary *)attributes;

@end
