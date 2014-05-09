//
//  AKServiceManager.h
//  AirplayKit
//
//  Created by Andy Roth on 1/18/11.
//  Copyright 2011 Roozy. All rights reserved.
//

#import "AKDevice.h"
#import <CocoaAsyncSocket/AsyncSocket.h>
#import <ReactiveCocoa.h>

@class AKAirplayManager;

@protocol AKAirplayManagerDelegate <NSObject>

@optional
- (void)airplayManager:(AKAirplayManager *)manager didFindDevice:(AKDevice *)device;
- (void)airplayManager:(AKAirplayManager *)manager didConnectToDevice:(AKDevice *)device;
@end

@interface AKAirplayManager : NSObject <NSNetServiceBrowserDelegate, NSNetServiceDelegate, AsyncSocketDelegate>

@property (nonatomic, assign) id <AKAirplayManagerDelegate> delegate;
@property (nonatomic, strong) AKDevice                 *connectedDevice;
@property (nonatomic, strong) AsyncSocket              *socket;
@property (nonatomic, strong) NSNetServiceBrowser      *serviceBrowser;
@property (nonatomic, strong) NSMutableSet             *foundServices;

- (void)findDevices;
- (void)connectToDevice:(AKDevice *)device;

@end
