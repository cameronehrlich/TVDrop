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

+ (instancetype)requestPath:(NSString *)path withType:(AKRequestType)type
{
    AKRequest *request = [[AKRequest alloc] init];
    [request setPath:path];
    [request setRequestType:type];
    return request;
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

- (void)setBody:(NSString *)body
{
    if (!body) {
        [self.parameters removeObjectForKey:@"Content-Length"];
        _body = body;
        return;
    }
    
    [self addParameterKey:@"Content-Length" withValue:[NSString stringWithFormat:@"%lu", (unsigned long)[body length]]];
    _body = body;
}

-(void)setPath:(NSString *)path
{
    _path = [path stringByReplacingOccurrencesOfString:@"/" withString:@""];
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
    [self addParameterKey:@"User-Agent" withValue:@"MediaControl/1.0"];

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
