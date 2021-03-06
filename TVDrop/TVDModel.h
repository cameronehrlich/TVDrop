//
//  TVDModel.h
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import <NSString+RMURLEncoding.h>
#import <GCDWebServer.h>
#import <GCDWebServer/GCDWebServerFileResponse.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <GCDWebServer/GCDWebServerStreamedResponse.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <ReactiveCocoa/ReactiveCocoa.h>
#import "AirplayKit/AKAirplayManager.h"
#import "AirplayKit/AKDevice.h"

@interface TVDModel : NSView <AKAirplayManagerDelegate, AKDeviceDelegate, GCDWebServerDelegate>

@property (nonatomic, strong) AKAirplayManager *airplayManager;
@property (nonatomic, strong) GCDWebServer     *webServer;
@property (nonatomic, strong) NSSet            *foundDevices;
@property (nonatomic, strong) NSURL            *fileURL;

+ (instancetype)sharedInstance;

- (void)startFindingDevices;
- (void)playFileAtURL:(NSURL *)fileURL;

- (NSArray *)allTypes;
- (NSArray *)imageTypes;
- (NSArray *)videoTypes;
- (NSArray *)musicTypes;

@end
