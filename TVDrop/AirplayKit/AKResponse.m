//
//  AKResponse.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 5/14/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "AKResponse.h"

@implementation AKResponse

+ (instancetype)responseWithData:(NSData *)data
{
    AKResponse *response = [[AKResponse alloc] init];
    
    NSString *decodedData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    NSArray *partitions = [decodedData componentsSeparatedByString:@"\r\n\r\n"];
    
    NSString *headersPartition = [partitions objectAtIndex:0];
    
    response.body = [[partitions objectAtIndex:1] length] > 1 ? [partitions objectAtIndex:1] : nil;

    NSArray *headerFields = [headersPartition componentsSeparatedByString:@"\n"];
    
    for (NSString *header in headerFields) {
        if ([header rangeOfString:@"HTTP"].location == 0){
            response.status = [[[header componentsSeparatedByString:@" "] objectAtIndex:1] integerValue];
        }else if ([header rangeOfString:@"Content-Type"].location == 0){
            response.contentType = [[[header componentsSeparatedByString:@" "] objectAtIndex:1] stringByReplacingOccurrencesOfString:@" " withString:@""];
        }
    }
    return response;
}

@end
