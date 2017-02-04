//
//  PhotoAPI.m
//  PhotosByTag
//
//  Created by Ayhan Dorman on 04/02/2017.
//  Copyright © 2017 Modanisa. All rights reserved.
//

#import "PhotoAPI.h"

@implementation PhotoAPI

static NSString *flickrRestServiceUrlFormat;

static NSString *flickrAPIKey;

NSDictionary *errorCodes;

NSURLSessionDataTask *dataTask;


+ (void) initialize
{
    
    flickrRestServiceUrlFormat = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrRestServiceUrlFormat"];
    
    flickrAPIKey = [[NSBundle mainBundle] objectForInfoDictionaryKey:@"FlickrAPIKey"];
    
    errorCodes = [[NSDictionary alloc]initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"ErrorCodes" ofType:@"plist"]];
    
}


+ (NSURLSessionDataTask*) photosByTag:(void (^)(NSArray *photos))getPhotos failure:(void (^)(NSError *error))failure tag:(NSString*)tag
{
    
    NSString *urlString = [NSString stringWithFormat:flickrRestServiceUrlFormat, @"flickr.photos.search", flickrAPIKey, tag];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] initWithURL:[NSURL URLWithString:urlString]];
    
    [request setTimeoutInterval:60.0];
    
    [request addValue:@"gzip" forHTTPHeaderField:@"Accept-Encoding"]; 
    
    [request setHTTPMethod:@"GET"];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    dispatch_async(dispatch_queue_create("photo list", NULL), ^{
        
        dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error)
        {
            
            if (data.length > 0 && error == nil)
            {
                
                NSDictionary *dict = [NSJSONSerialization
                                      JSONObjectWithData:data
                                      options:NSJSONReadingMutableContainers|NSJSONReadingMutableLeaves
                                      error:&error];
                
                if (error)
                {
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        failure(error);
                        
                    });
                    
                }
                else
                {
                    
                    
                    dispatch_async(dispatch_get_main_queue(), ^{
                        
                        NSString *resultKey = [dict objectForKey:@"stat"];
                        
                        if ([resultKey isEqualToString:@"ok"])
                        {
                            
                            @try {
                                
                                NSArray *photos = [[dict objectForKey:@"photos"] objectForKey:@"photo"];
                                
                                NSMutableArray *photosOut = [[NSMutableArray alloc] init];
                                
                                for (NSDictionary *_photo in photos) {
                                    
                                    Photo *photo = [[Photo alloc] initWithAttributes:_photo];
                                    
                                    [photosOut addObject:photo];
                                    
                                }
                                
                                getPhotos(photosOut);
                                
                            }
                            @catch (NSException *exception) {
                                
                                NSString *errorCode = @"1";
                                
                                NSError *errorParser = [[NSError alloc] initWithDomain:@"com.PhotosByTag" code:200 userInfo:@{NSLocalizedDescriptionKey: [errorCodes objectForKey:errorCode]}];
                                
                                failure(errorParser);
                                
                            }
                            
                        }
                        else
                        {
                            
                            NSString *errorCode = [dict objectForKey:@"code"];
                            
                            NSError *error = [[NSError alloc] initWithDomain:@"com.PhotosByTag" code:200 userInfo:@{NSLocalizedDescriptionKey: [errorCodes objectForKey:errorCode]}];
                            
                            failure(error);
                            
                        }
                        
                    });
                    
                }
                
            }
            else
            {
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    
                    failure(error);
                    
                });
                
            }
            
        }];
        
        [dataTask resume];
        
    });
    
    return nil;
    
}


@end
