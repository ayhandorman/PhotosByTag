//
//  Photo.m
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import "Photo.h"

@implementation Photo

- (instancetype)initWithAttributes:(NSDictionary *)attributes {
    
    self = [super init];
    
    if (!self) {
        
        return nil;
        
    }
    
    self.id = [attributes valueForKey:@"id"];
    
    self.owner = [attributes valueForKey:@"owner"];
    
    self.secret = [attributes valueForKey:@"secret"];
    
    self.server = [attributes valueForKey:@"server"];
    
    self.farm = [attributes valueForKey:@"farm"];
    
    self.title = [attributes valueForKey:@"title"];
    
    self.ispublic = [[attributes valueForKey:@"ispublic"] boolValue];
    
    self.isfriend = [[attributes valueForKey:@"isfriend"] boolValue];
    
    self.isfamily = [[attributes valueForKey:@"isfamily"] boolValue];
    
    return self;
    
}

@end
