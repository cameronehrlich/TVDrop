//
//  AKResponse.h
//  TVDrop
//
//  Created by Cameron Ehrlich on 5/14/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AKResponse : NSObject

@property (nonatomic, strong) NSDictionary *headers;
@property (nonatomic, strong) NSString *body;
@property (nonatomic, assign) NSInteger status;
@property (nonatomic, strong) NSString *contentType;

+ (instancetype)responseWithData:(NSData *)data;

@end
