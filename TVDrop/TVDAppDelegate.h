//
//  TVDAppDelegate.h
//  TVDrop
//
//  Created by Cameron Ehrlich on 4/29/14.
//  Copyright (c) 2014 Cameron Ehrlich. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AirplayKit/AKAirplayManager.h"
#import "AirplayKit/AKDevice.h"
#import <GCDWebServer.h>
#import <GCDWebServer/GCDWebServerFileResponse.h>
#import <GCDWebServer/GCDWebServerDataResponse.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import "TVDDropView.h"

@interface TVDAppDelegate : NSObject <NSApplicationDelegate, AKAirplayManagerDelegate, AKDeviceDelegate>

@property (nonatomic, assign) IBOutlet NSWindow *window;
@property (nonatomic, strong) IBOutlet NSPopUpButtonCell *dropdown;
@property (nonatomic, strong) IBOutlet TVDDropView *dropView;

@property (nonatomic, strong) AKAirplayManager *airplayManager;
@property (nonatomic, strong) AKDevice *connectedDevice;
@property (nonatomic, strong) GCDWebServer *webServer;
@property (nonatomic, strong) NSMutableSet *foundDevices;
@property (nonatomic, strong) NSURL *fileToPlayURL;

- (IBAction)browseButtonAction:(id)sender;

- (void)playFileAtURL:(NSURL *)fileURL;
-(void)connectAndPlay;

@end
