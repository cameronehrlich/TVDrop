//
//  AKRequest.h
//  TVDrop
//
//  Created by Cameron Ehrlich on 5/12/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface AKRequest : NSObject

typedef NS_ENUM(NSUInteger, AKRequestType) {
    AKRequestTypeGET,
    AKRequestTypePOST,
    AKRequestTypePUT
};

@property (nonatomic, strong) NSMutableDictionary   *parameters;
@property (nonatomic, strong) NSString              *path;
@property (nonatomic, strong) NSString              *body;
@property (nonatomic, assign) AKRequestType         requestType;

+ (instancetype)requestPath:(NSString *)path withType:(AKRequestType)type;

- (void)addParameterKey:(NSString *)key withValue:(NSString *)value;

- (NSString *)requestString;
- (NSData *)requestData;

@end
