//
//  StringOperations.m
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import "StringOperations.h"

@implementation StringOperations

+ (NSString*)decodeUTF8String:(NSString*)string
{
    
    return [NSString stringWithCString:[string UTF8String] encoding:NSUTF8StringEncoding];
    
}

@end
