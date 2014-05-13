//
//  AKRequest.m
//  TVDrop
//
//  Created by Cameron Ehrlich on 5/12/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import "AKRequest.h"

@implementation AKRequest

- (instancetype)init
{
    self = [super init];
    if (self) {
        //
    }
    return self;
}

- (NSString *)stringForType:(AKRequestType)type
{
    NSDictionary *typeTable =
    @{
      @(AKRequestTypeGET)   : @"GET",
      @(AKRequestTypePOST)  : @"POST",
      @(AKRequestTypePUT)   : @"PUT"
    };
    
    return [typeTable objectForKey:@(type)];
}

- (void)addParameterKey:(NSString *)key withValue:(NSString *)value;
{
    if (!self.parameters) {
        self.parameters = [NSMutableDictionary dictionary];
    }
    [self.parameters setObject:value forKey:key];
}

- (NSData *)requestData
{
    return [[self requestString] dataUsingEncoding:NSUTF8StringEncoding];
}


- (NSString *)requestString
{
    if (![self.parameters objectForKey:@"User-Agent"]) {
        [self addParameterKey:@"User-Agent" withValue:@"MediaControl/1.0"];
    }

    NSMutableString *contructionString = [[NSMutableString alloc] init];
    
    [contructionString appendFormat:@"%@ /%@ %@%@", [self stringForType:self.requestType], self.path, @"HTTP/1.1", @"\r\n"];
    
    for (NSString *key in [self.parameters allKeys]) {
        [contructionString appendFormat:@"%@: %@%@", key, [self.parameters objectForKey:key], @"\r\n"];
    }
    
    if ([self.body length] > 0) {
        [contructionString appendString:@"\r\n"];
        [contructionString appendFormat:@"%@", self.body];
    }
    
    // Trailing linebreak
    [contructionString appendString:@"\r\n"];
    
    return [contructionString copy];
}

@end
